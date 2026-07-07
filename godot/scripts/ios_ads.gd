extends Node
## iOS AdMob 전면(Interstitial) 광고 어댑터.
##
## godot-admob(res://addons/AdmobPlugin)의 Admob 노드를 감싸, "게임 종료 시 전면광고 1회"
## 유스케이스만 노출한다(show_interstitial). iOS 네이티브에서만 동작하며, 그 외 플랫폼·헤드리스·
## 에디터에서는 AdMob 싱글톤이 없어 자동 no-op이다(Admob 노드가 Engine.has_singleton으로 가드).
##
## 아키텍처: 이 스크립트는 bootstrap 계층(순수 코어 아님)이다. 순수 코어
## (reversi_engine.gd / packages/product-core)는 AdMob을 참조하지 않는다(check_architecture.sh).
## 광고 ID/트리거는 AIT(apps/ait/src/ads.ts)와 동일하게 "게임 종료 시 1회"이며, 마켓별 ID는 분리한다.

const AdmobNode = preload("res://addons/AdmobPlugin/Admob.gd")
const AdmobConfigScript = preload("res://addons/AdmobPlugin/model/AdmobConfig.gd")

# 실 iOS 식별자 (app-store/app-store.config.json 의 ads.plannedNative)
const REAL_APP_ID := "ca-app-pub-2444587584524186~1005155551"
const REAL_INTERSTITIAL_UNIT_ID := "ca-app-pub-2444587584524186/8692073883"
# AdMob 공식 iOS 테스트 식별자 (개발/비릴리스 빌드 전용 — 실 유닛 테스트 클릭은 정책 위반)
const TEST_APP_ID := "ca-app-pub-3940256099942544~1458002511"
const TEST_INTERSTITIAL_UNIT_ID := "ca-app-pub-3940256099942544/4411468910"

var _admob: Admob
var _loaded: bool = false


func _ready() -> void:
	# iOS 네이티브에서만 초기화. 그 외(웹/안드로이드/데스크톱/헤드리스)에서는 no-op.
	if not OS.has_feature("ios"):
		return

	var use_real: bool = not OS.is_debug_build()

	_admob = AdmobNode.new()
	_admob.name = "Admob"
	_admob.is_real = use_real
	_admob.ios_real_application_id = REAL_APP_ID
	_admob.ios_debug_application_id = TEST_APP_ID
	_admob.ios_real_interstitial_id = REAL_INTERSTITIAL_UNIT_ID
	_admob.ios_debug_interstitial_id = TEST_INTERSTITIAL_UNIT_ID
	# 비맞춤형(NPA) 광고만 — IDFA·추적 미사용(App Store App Privacy: Tracking No 유지).
	_admob.personalization_state = AdmobConfigScript.PersonalizationState.DISABLED
	add_child(_admob)

	_admob.initialization_completed.connect(_on_initialization_completed)
	_admob.interstitial_ad_loaded.connect(_on_interstitial_loaded)
	_admob.interstitial_ad_failed_to_load.connect(_on_interstitial_failed)
	_admob.interstitial_ad_dismissed_full_screen_content.connect(_on_interstitial_dismissed)

	_admob.initialize()


## 게임 종료 시 호출. 로드돼 있으면 전면광고를 표시하고, 아직이면 이번 판은 건너뛰고
## 다음 판을 위해 미리 로드한다(AIT ads.ts 의 load→show→reload 와 동일한 UX).
func show_interstitial() -> void:
	if _admob == null:
		return
	if not _loaded:
		_load()
		return
	_admob.show_interstitial_ad()


func _load() -> void:
	if _admob != null:
		_admob.load_interstitial_ad()


func _on_initialization_completed(_status: InitializationStatus) -> void:
	_load()


func _on_interstitial_loaded(_ad_info: AdInfo, _response_info: ResponseInfo) -> void:
	_loaded = true


func _on_interstitial_failed(_ad_info: AdInfo, _error: LoadAdError) -> void:
	_loaded = false


func _on_interstitial_dismissed(_ad_info: AdInfo) -> void:
	# 노출 후 다음 판을 위해 미리 로드.
	_loaded = false
	_load()
