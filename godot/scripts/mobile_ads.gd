extends Node
## 모바일 AdMob 전면(Interstitial) 광고 어댑터. iOS와 Android를 함께 다룬다.
##
## godot-admob(res://addons/AdmobPlugin)의 Admob 노드를 감싸, "게임 종료 시 전면광고 1회"
## 유스케이스만 노출한다(show_interstitial). iOS·Android 네이티브에서만 동작하며, 그 외 플랫폼·
## 헤드리스·에디터에서는 AdMob 싱글톤이 없어 자동 no-op이다(Admob 노드가 Engine.has_singleton으로 가드).
##
## 아키텍처: bootstrap 계층(순수 코어 아님). 순수 코어(reversi_engine.gd / packages/product-core)는
## AdMob을 참조하지 않는다(check_architecture.sh).
##
## 주의: 이 노드는 main.gd 에서 "persistent_services" 그룹으로 추가된다. _build_ui() 의
## get_children() 정리에서 제외되어야 초기화 직후 삭제되지 않는다(그렇지 않으면 광고가 안 뜬다).
##
## 로그는 print()로 시스템 로그(iOS Console / Android logcat)에 남는다(로드 실패·no-fill 진단용).
## 로드 실패 시 재시도한다.

const AdmobNode = preload("res://addons/AdmobPlugin/Admob.gd")
const AdmobConfigScript = preload("res://addons/AdmobPlugin/model/AdmobConfig.gd")

# 실 iOS 식별자 (app-store/app-store.config.json 의 ads)
const IOS_REAL_APP_ID := "ca-app-pub-9932778305312246~3300846492"
const IOS_REAL_INTERSTITIAL_UNIT_ID := "ca-app-pub-9932778305312246/5917919124"
# 실 Android 식별자 (play-store/google-play.config.json 의 ads)
const ANDROID_REAL_APP_ID := "ca-app-pub-9932778305312246~6509011613"
const ANDROID_REAL_INTERSTITIAL_UNIT_ID := "ca-app-pub-9932778305312246/7985744813"
# AdMob 공식 테스트 식별자 (개발/비릴리스 빌드 전용 — 실 유닛 테스트 클릭은 정책 위반)
const IOS_TEST_APP_ID := "ca-app-pub-3940256099942544~1458002511"
const IOS_TEST_INTERSTITIAL_UNIT_ID := "ca-app-pub-3940256099942544/4411468910"
const ANDROID_TEST_APP_ID := "ca-app-pub-3940256099942544~3347511713"
const ANDROID_TEST_INTERSTITIAL_UNIT_ID := "ca-app-pub-3940256099942544/1033173712"

## AdMob 테스트 기기 ID.
## 실기기 로그의 "GADMobileAds...testDeviceIdentifiers = @[ @\"<ID>\" ]" 값을 넣으면,
## 실 광고 유닛으로도 테스트 광고가 떠서(no-fill·정책 위반 없이) 실기기에서 검증할 수 있다.
const TEST_DEVICE_IDS: Array[String] = []

## 로드 실패(no-fill 등) 후 재시도 간격(초).
const RETRY_DELAY_SEC := 30.0

var _admob: Admob
var _loaded: bool = false


func _log(message: String) -> void:
	print("[mobile_ads] ", message)


func _ready() -> void:
	# iOS·Android 네이티브에서만 초기화. 그 외(웹/데스크톱/헤드리스)에서는 no-op.
	var is_ios: bool = OS.has_feature("ios")
	var is_android: bool = OS.has_feature("android")
	if not is_ios and not is_android:
		return

	var use_real: bool = not OS.is_debug_build()
	var unit: String
	if is_ios:
		unit = IOS_REAL_INTERSTITIAL_UNIT_ID if use_real else IOS_TEST_INTERSTITIAL_UNIT_ID
	else:
		unit = ANDROID_REAL_INTERSTITIAL_UNIT_ID if use_real else ANDROID_TEST_INTERSTITIAL_UNIT_ID
	_log("init start: platform=%s, is_real=%s, interstitial_unit=%s" % ["ios" if is_ios else "android", use_real, unit])

	_admob = AdmobNode.new()
	_admob.name = "Admob"
	_admob.is_real = use_real
	_admob.ios_real_application_id = IOS_REAL_APP_ID
	_admob.ios_debug_application_id = IOS_TEST_APP_ID
	_admob.ios_real_interstitial_id = IOS_REAL_INTERSTITIAL_UNIT_ID
	_admob.ios_debug_interstitial_id = IOS_TEST_INTERSTITIAL_UNIT_ID
	_admob.android_real_application_id = ANDROID_REAL_APP_ID
	_admob.android_debug_application_id = ANDROID_TEST_APP_ID
	_admob.android_real_interstitial_id = ANDROID_REAL_INTERSTITIAL_UNIT_ID
	_admob.android_debug_interstitial_id = ANDROID_TEST_INTERSTITIAL_UNIT_ID
	# 비맞춤형(NPA) 광고만 — IDFA·추적 미사용(App Store App Privacy: Tracking No 유지).
	# Android도 같은 정책이라 관심사 기반 프로필을 만들지 않는다.
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
		return
	if not _loaded:
		_log("show 요청: 아직 미로드 → 이번 판 스킵하고 재로드")
		_load()
		return
	_log("show_interstitial_ad() 호출")
	_admob.show_interstitial_ad()


func _load() -> void:
	if _admob != null:
		_admob.load_interstitial_ad()


func _on_initialization_completed(_status: InitializationStatus) -> void:
	_log("initialization_completed")
	if not TEST_DEVICE_IDS.is_empty():
		var cfg: AdmobConfig = _admob.create_request_configuration()
		cfg.set_test_device_ids(TEST_DEVICE_IDS)
		_admob.set_request_configuration(cfg)
	_load()


func _on_interstitial_loaded(_ad_info: AdInfo, _response_info: ResponseInfo) -> void:
	_loaded = true
	_log("interstitial loaded")


func _on_interstitial_failed(_ad_info: AdInfo, error: LoadAdError) -> void:
	_loaded = false
	var detail: String = "(no error object)"
	if error != null:
		detail = "code=%d domain=%s msg=%s" % [error.get_code(), error.get_domain(), error.get_message()]
	_log("interstitial failed to load: %s (%.0fs 후 재시도)" % [detail, RETRY_DELAY_SEC])
	get_tree().create_timer(RETRY_DELAY_SEC).timeout.connect(_load, CONNECT_ONE_SHOT)


func _on_interstitial_showed(_ad_info: AdInfo) -> void:
	_log("interstitial showed")


func _on_interstitial_failed_to_show(_ad_info: AdInfo, _error: AdError) -> void:
	_loaded = false
	_load()


func _on_interstitial_dismissed(_ad_info: AdInfo) -> void:
	# 노출 후 다음 판을 위해 미리 로드.
	_loaded = false
	_load()
