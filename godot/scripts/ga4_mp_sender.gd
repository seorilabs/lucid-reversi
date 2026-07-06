extends Node

# GA4 Measurement Protocol 전송기(analytics 어댑터 뒤 얇은 REST 구현).
# 플랫폼 네이티브 브리지가 아니라 HTTPRequest 로 직접 POST 하므로 iOS/Web/AIT 공통으로 동작한다.
# 세션/DAU/잔존율은 GA4 가 client_id + session_id + engagement_time_msec 로 자동 집계한다.
# 예약 이벤트명(session_start/first_open/user_engagement 등)은 MP 로 보낼 수 없어 스킵하고,
# 세션 시작은 커스텀 game_open 으로 알린다(새 client_id 는 GA4 가 first_touch 로 처리).
#
# 전송 조건: config(measurement_id+api_secret) 존재 + 비-headless + **릴리스 빌드**만.
# (에디터/디버그·헤드리스 스모크에서는 실데이터 오염 방지를 위해 전송하지 않는다.)

const CONFIG_PATH := "res://analytics.config.json"
const CLIENT_ID_PATH := "user://ga4_client_id"
const MP_URL := "https://www.google-analytics.com/mp/collect"
const ENGAGEMENT_MSEC := 100
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
var _busy := false


func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_completed)
	_session_id = str(int(Time.get_unix_time_from_system()))
	_client_id = _load_or_make_client_id()
	_load_config()
	_enabled = _measurement_id != "" and _api_secret != "" \
		and DisplayServer.get_name() != "headless" and not OS.is_debug_build()
	if _enabled:
		send("game_open", {})


# 외부 주입용(config 파일 대신 코드로 주입할 때). _ready 전에 호출.
func set_config(measurement_id: String, api_secret: String) -> void:
	_measurement_id = measurement_id
	_api_secret = api_secret


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


# analytics 어댑터가 이 지점으로 이벤트를 포워딩한다.
func send(event_name: String, params: Dictionary) -> void:
	if not _enabled:
		return
	if RESERVED.has(event_name):
		return
	var p := params.duplicate()
	p["session_id"] = _session_id
	if not p.has("engagement_time_msec"):
		p["engagement_time_msec"] = ENGAGEMENT_MSEC
	_queue.append({"name": event_name, "params": p})
	_flush()


func _flush() -> void:
	if _busy or _queue.is_empty():
		return
	var batch := _queue.slice(0, 25)
	_queue = _queue.slice(25)
	var body := {"client_id": _client_id, "events": batch}
	var url := "%s?measurement_id=%s&api_secret=%s" % [MP_URL, _measurement_id, _api_secret]
	_busy = true
	var err := _http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		_busy = false


func _on_completed(_result: int, _code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	_busy = false
	_flush()
