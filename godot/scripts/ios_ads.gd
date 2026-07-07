extends Node
## iOS AdMob 전면(Interstitial) 광고 어댑터.
##
## godot-admob(res://addons/AdmobPlugin)의 Admob 노드를 감싸, "게임 종료 시 전면광고 1회"
## 유스케이스만 노출한다(show_interstitial). iOS 네이티브에서만 동작하며, 그 외 플랫폼·헤드리스·
## 에디터에서는 AdMob 싱글톤이 없어 자동 no-op이다(Admob 노드가 Engine.has_singleton으로 가드).
##
## 아키텍처: 이 스크립트는 bootstrap 계층(순수 코어 아님)이다. 순수 코어
## (reversi_engine.gd / packages/product-core)는 AdMob을 참조하지 않는다(check_architecture.sh).
##
## 진단: 단계별 print 로그를 남긴다(iOS 시스템 로그 → Mac Console.app에서 프로세스 필터 "lucidreversi",
## 검색 "[ios_ads]"). 로드 실패(no-fill 등) 시 일정 간격으로 재시도한다.

const AdmobNode = preload("res://addons/AdmobPlugin/Admob.gd")
const AdmobConfigScript = preload("res://addons/AdmobPlugin/model/AdmobConfig.gd")

# 실 iOS 식별자 (app-store/app-store.config.json 의 ads)
const REAL_APP_ID := "ca-app-pub-2444587584524186~1005155551"
const REAL_INTERSTITIAL_UNIT_ID := "ca-app-pub-2444587584524186/8692073883"
# AdMob 공식 iOS 테스트 식별자 (개발/비릴리스 빌드 전용 — 실 유닛 테스트 클릭은 정책 위반)
const TEST_APP_ID := "ca-app-pub-3940256099942544~1458002511"
const TEST_INTERSTITIAL_UNIT_ID := "ca-app-pub-3940256099942544/4411468910"

## AdMob 테스트 기기 ID.
## 실기기 첫 실행 시 Google Mobile Ads SDK가 시스템 로그에 다음을 출력한다:
##   "To get test ads on this device, set: GADMobileAds.sharedInstance.requestConfiguration
##    .testDeviceIdentifiers = @[ @\"<HASHED_ID>\" ];"
## 이 <HASHED_ID>를 여기에 넣으면, 실 광고 유닛으로도 "테스트 광고"가 떠서(no-fill·정책 위반 없이)
## 실기기에서 통합을 검증할 수 있다. 비워두면 실 광고를 그대로 요청한다.
const TEST_DEVICE_IDS: Array[String] = []

## 로드 실패(no-fill 등) 후 재시도 간격(초). 게임 종료 시점 외에도 백그라운드로 재로드를 시도한다.
const RETRY_DELAY_SEC := 30.0

var _admob: Admob
var _loaded: bool = false


func _log(message: String) -> void:
	print("[ios_ads] ", message)


func _ready() -> void:
	# iOS 네이티브에서만 초기화. 그 외(웹/안드로이드/데스크톱/헤드리스)에서는 no-op.
	if not OS.has_feature("ios"):
		return

	var use_real: bool = not OS.is_debug_build()
	var unit: String = REAL_INTERSTITIAL_UNIT_ID if use_real else TEST_INTERSTITIAL_UNIT_ID
	_log("init start: is_real=%s, interstitial_unit=%s, test_devices=%s" % [use_real, unit, str(TEST_DEVICE_IDS)])

	_admob = AdmobNode.new()
	_admob.name = "Admob"
	_admob.is_real = use_real
	_admob.ios_real_application_id = REAL_APP_ID
	_admob.ios_debug_application_id = TEST_APP_ID
	_admob.ios_real_interstitial_id = REAL_INTERSTITIAL_UNIT_ID
	_admob.ios_debug_interstitial_id = TEST_INTERSTITIAL_UNIT_ID
	# 비맞춤형(NPA) 광고만 — IDFA·추적 미사용(App Store App Privacy: Tracking No 유지).
	_admob.personalization_state = AdmobConfigScript.PersonalizationState.DISABLED
	if not TEST_DEVICE_IDS.is_empty():
		_admob.test_device_hashed_ids = TEST_DEVICE_IDS
	add_child(_admob)

	_admob.initialization_completed.connect(_on_initialization_completed)
	_admob.interstitial_ad_loaded.connect(_on_interstitial_loaded)
	_admob.interstitial_ad_failed_to_load.connect(_on_interstitial_failed)
	_admob.interstitial_ad_showed_full_screen_content.connect(_on_interstitial_showed)
	_admob.interstitial_ad_failed_to_show_full_screen_content.connect(_on_interstitial_failed_to_show)
	_admob.interstitial_ad_dismissed_full_screen_content.connect(_on_interstitial_dismissed)

	_admob.initialize()
	_log("initialize() called")


## 게임 종료 시 호출. 로드돼 있으면 전면광고를 표시하고, 아직이면 이번 판은 건너뛰고
## 다음 판을 위해 미리 로드한다(AIT ads.ts 의 load→show→reload 와 동일한 UX).
func show_interstitial() -> void:
	if _admob == null:
		_log("show 요청: 어댑터 미초기화(iOS 아님) → no-op")
		return
	if not _loaded:
		_log("show 요청: 아직 미로드 → 이번 판 스킵하고 재로드")
		_load()
		return
	_log("show_interstitial_ad() 호출")
	_admob.show_interstitial_ad()


func _load() -> void:
	if _admob != null:
		_log("load_interstitial_ad() 요청")
		_admob.load_interstitial_ad()


func _on_initialization_completed(_status: InitializationStatus) -> void:
	_log("initialization_completed")
	# auto_configure_on_initialize 가 test device 없는 config로 덮어쓴 뒤이므로, 여기서 다시 등록한다.
	if not TEST_DEVICE_IDS.is_empty():
		var cfg: AdmobConfig = _admob.create_request_configuration()
		cfg.set_test_device_ids(TEST_DEVICE_IDS)
		_admob.set_request_configuration(cfg)
		_log("test devices registered via request configuration: %s" % str(TEST_DEVICE_IDS))
	_load()


func _on_interstitial_loaded(_ad_info: AdInfo, _response_info: ResponseInfo) -> void:
	_loaded = true
	_log("interstitial LOADED (표시 준비 완료)")


func _on_interstitial_failed(_ad_info: AdInfo, error: LoadAdError) -> void:
	_loaded = false
	var detail: String = "(no error object)"
	if error != null:
		detail = "code=%d domain=%s msg=%s" % [error.get_code(), error.get_domain(), error.get_message()]
	_log("interstitial FAILED to load: %s → %.0fs 후 재시도" % [detail, RETRY_DELAY_SEC])
	get_tree().create_timer(RETRY_DELAY_SEC).timeout.connect(_load, CONNECT_ONE_SHOT)


func _on_interstitial_showed(_ad_info: AdInfo) -> void:
	_log("interstitial showed (full screen content)")


func _on_interstitial_failed_to_show(_ad_info: AdInfo, _error: AdError) -> void:
	_loaded = false
	_log("interstitial FAILED to show → 재로드")
	_load()


func _on_interstitial_dismissed(_ad_info: AdInfo) -> void:
	# 노출 후 다음 판을 위해 미리 로드.
	_loaded = false
	_log("interstitial dismissed → 다음 판 위해 재로드")
	_load()
