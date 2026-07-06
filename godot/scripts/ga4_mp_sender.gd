extends Node

# GA4 Measurement Protocol 전송기(analytics 어댑터 뒤 얇은 REST 구현).
# 플랫폼 네이티브 브리지가 아니라 HTTPRequest 로 직접 POST 하므로 iOS/Web/AIT 공통으로 동작한다.
# 세션/DAU/잔존율은 GA4 가 client_id + session_id + engagement_time_msec 로 자동 집계한다.
# 예약 이벤트명(session_start/first_open/user_engagement 등)은 MP 로 보낼 수 없어 스킵하고,
# 세션 시작은 커스텀 game_open 으로 알린다(새 client_id 는 GA4 가 first_touch 로 처리).
#
# 전송 조건: config(measurement_id+api_secret) 유효 + 비-headless + **릴리스 빌드**만.
# (에디터/디버그·헤드리스 스모크에서는 실데이터 오염 방지를 위해 전송하지 않으며,
#  비활성 경로에서는 client_id/session 식별자 파일도 디스크에 만들지 않는다.)
#
# 주의: GA4 MP 사양상 api_secret 은 URL 쿼리로 전달한다(web stream secret 은 클라이언트 노출 전제,
#       계정 비밀번호급이 아님). 전송은 릴리스 빌드에서만 일어나므로 디버그 로그 노출 경로는 없다.

const CONFIG_PATH := "res://analytics.config.json"
const CLIENT_ID_PATH := "user://ga4_client_id"
const SESSION_PATH := "user://ga4_session"
const SESSION_TIMEOUT := 1800  # 30분 비활성 → 새 세션(GA4 표준 근사). 매 실행 재발급 방지.
const MP_URL := "https://www.google-analytics.com/mp/collect"
const ENGAGEMENT_MSEC := 100
const BATCH_SIZE := 25
const MAX_QUEUE := 200  # 네트워크 장기 장애 시 무한 누적 방지(오래된 이벤트부터 드롭)
const RESERVED := {
	"first_open": true, "first_visit": true, "session_start": true, "user_engagement": true,
	"screen_view": true, "in_app_purchase": true, "app_remove": true, "app_update": true,
	"ad_impression": true, "ad_click": true, "error": true,
}

var _measurement_id := ""
var _api_secret := ""
var _client_id := ""
var _session_id := ""
var _enabled := false
var _http: HTTPRequest
var _queue: Array = []
var _in_flight: Array = []
var _busy := false


func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_completed)
	_load_config()
	_enabled = _config_valid() and DisplayServer.get_name() != "headless" and not OS.is_debug_build()
	# 비활성이면 client_id/session 식별자 생성·디스크 쓰기·전송을 모두 건너뛴다.
	if not _enabled:
		return
	_client_id = _load_or_make_client_id()
	_session_id = _load_or_make_session_id()
	send("game_open", {})


# 외부 주입용(config 파일 대신 코드로 주입할 때). _ready 전에 호출.
func set_config(measurement_id: String, api_secret: String) -> void:
	_measurement_id = measurement_id
	_api_secret = api_secret


func _config_valid() -> bool:
	if _measurement_id == "" or _api_secret == "":
		return false
	# measurement_id 는 GA4 규칙상 "G-" 접두. 오타(measurementId 등)로 조용히 꺼지는 실패를 드러낸다.
	if not _measurement_id.begins_with("G-"):
		push_warning("[GA4] measurement_id 형식 오류(G- 접두 필요) — analytics 전송 비활성화.")
		return false
	return true


func _load_config() -> void:
	if _measurement_id != "":
		return
	if not FileAccess.file_exists(CONFIG_PATH):
		return
	var f := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		_measurement_id = String(parsed.get("measurement_id", ""))
		_api_secret = String(parsed.get("api_secret", ""))


func _load_or_make_client_id() -> String:
	if FileAccess.file_exists(CLIENT_ID_PATH):
		var f := FileAccess.open(CLIENT_ID_PATH, FileAccess.READ)
		if f != null:
			var existing := f.get_as_text().strip_edges()
			if existing != "":
				return existing
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var cid := "%d.%d" % [rng.randi(), int(Time.get_unix_time_from_system())]
	var w := FileAccess.open(CLIENT_ID_PATH, FileAccess.WRITE)
	if w != null:
		w.store_string(cid)
	return cid


# 마지막 활동 후 30분이 지나지 않았으면 이전 session_id 를 이어 쓴다(매 실행 재발급 방지).
func _load_or_make_session_id() -> String:
	var now := int(Time.get_unix_time_from_system())
	if FileAccess.file_exists(SESSION_PATH):
		var f := FileAccess.open(SESSION_PATH, FileAccess.READ)
		if f != null:
			var parts := f.get_as_text().strip_edges().split(":")
			if parts.size() == 2 and parts[0] != "" and now - int(parts[1]) < SESSION_TIMEOUT:
				_save_session(parts[0], now)
				return parts[0]
	var sid := str(now)
	_save_session(sid, now)
	return sid


func _save_session(sid: String, ts: int) -> void:
	var w := FileAccess.open(SESSION_PATH, FileAccess.WRITE)
	if w != null:
		w.store_string("%s:%d" % [sid, ts])


# 이벤트 정규화(reserved 스킵 + session_id/engagement 부여). 순수 로직 — 테스트 대상.
func _build_event(event_name: String, params: Dictionary) -> Dictionary:
	if RESERVED.has(event_name):
		return {}
	var p := params.duplicate()
	p["session_id"] = _session_id
	if not p.has("engagement_time_msec"):
		p["engagement_time_msec"] = ENGAGEMENT_MSEC
	return {"name": event_name, "params": p}


# 배치 분할(앞 size 개 / 나머지). 순수 로직 — 테스트 대상.
static func _split_batch(queue: Array, size: int) -> Dictionary:
	return {"batch": queue.slice(0, size), "rest": queue.slice(size)}


# analytics 어댑터가 이 지점으로 이벤트를 포워딩한다.
func send(event_name: String, params: Dictionary) -> void:
	if not _enabled:
		return
	var evt := _build_event(event_name, params)
	if evt.is_empty():
		return
	_queue.append(evt)
	if _queue.size() > MAX_QUEUE:
		_queue = _queue.slice(_queue.size() - MAX_QUEUE)  # 오래된 이벤트부터 드롭
	_flush()


func _flush() -> void:
	if _busy or _queue.is_empty():
		return
	var split := _split_batch(_queue, BATCH_SIZE)
	_in_flight = split["batch"]
	_queue = split["rest"]
	var body := {"client_id": _client_id, "events": _in_flight}
	var url := "%s?measurement_id=%s&api_secret=%s" % [MP_URL, _measurement_id, _api_secret]
	_busy = true
	var err := _http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		# 즉시 실패(요청 시작 불가) → 배치를 큐 앞으로 되돌려 다음 기회에 재시도.
		_queue = _in_flight + _queue
		_in_flight = []
		_busy = false


func _on_completed(result: int, _code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	# 네트워크 실패면 전송 중이던 배치를 큐 앞으로 되돌린다(MAX_QUEUE 가 폭주를 막는다).
	if result != HTTPRequest.RESULT_SUCCESS:
		_queue = _in_flight + _queue
	_in_flight = []
	_busy = false
	_flush()
