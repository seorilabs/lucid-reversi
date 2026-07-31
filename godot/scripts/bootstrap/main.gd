extends Control

const ReversiEngine = preload("res://scripts/reversi_engine.gd")
const ReversiAnalytics = preload("res://scripts/analytics.gd")
const GA4_SENDER_SCRIPT = preload("res://scripts/ga4_mp_sender.gd")
const IOS_ADS_SCRIPT = preload("res://scripts/ios_ads.gd")
const PLACE_SFX = preload("res://assets/audio/place.wav")
const FLIP_SFX = preload("res://assets/audio/flip.wav")
const BIG_FLIP_SFX = preload("res://assets/audio/big_flip.wav")
const CLASSIC_BLACK_TEXTURE = preload("res://assets/reversi/themes/classic_black.svg")
const CLASSIC_WHITE_TEXTURE = preload("res://assets/reversi/themes/classic_white.svg")
const ARCTIC_BLACK_TEXTURE = preload("res://assets/reversi/themes/arctic_black.svg")
const ARCTIC_WHITE_TEXTURE = preload("res://assets/reversi/themes/arctic_white.svg")
const EMBER_BLACK_TEXTURE = preload("res://assets/reversi/themes/ember_black.svg")
const EMBER_WHITE_TEXTURE = preload("res://assets/reversi/themes/ember_white.svg")
const UI_FONT = preload("res://assets/fonts/DoHyeon-Regular.ttf")
const JAPANESE_FONT = preload("res://assets/fonts/MPLUSRounded1c-Regular.ttf")

const SAVE_PATH := "user://save_v1.json"
const PREFS_PATH := "user://prefs_v1.json"
const SUPPORT_EMAIL := "cs@seorilabs.com"
const PRIVACY_POLICY_URL := ""
const CELL_SIZE := 84
const CELL_GAP := 2
const BOARD_PADDING := 4
const BOARD_TARGET_CONTENT_SIZE := CELL_SIZE * ReversiEngine.DEFAULT_BOARD_SIZE + CELL_GAP * (ReversiEngine.DEFAULT_BOARD_SIZE - 1)
const PLAY_BUTTON_HEIGHT := 58
const ACTION_BUTTON_HEIGHT := 52
const SETTINGS_CHOICE_HEIGHT := 52
const FLIP_HALF_DURATION := 0.11
const FLIP_WAVE_SECONDS_PER_CELL := 0.045
const FLIP_TILT_RADIANS := 0.11
const FLIP_EDGE_SCALE := Vector2(0.04, 1.12)
const FLIP_HIGHLIGHT_COLOR := Color(1.0, 0.92, 0.68, 1.0)
const FLIP_SWAP_ALPHA := 0.55
const DIFFICULTY_IDS := ["EASY", "MEDIUM", "HARD"]
const BOARD_SIZE_IDS := ["6", "8", "10"]
const BOARD_SIZE_LABELS := ["6×6", "8×8", "10×10"]
const THEME_IDS := ["classic", "arctic", "ember"]
const THEME_LABELS := ["CLASSIC", "ARCTIC", "EMBER"]
const STONE_THEME_IDS := ["classic", "arctic", "ember"]
const STONE_THEME_LABELS := ["CLASSIC", "ARCTIC", "EMBER"]
const LOCALE_IDS := ["ko", "en", "ja"]
const LOCALE_LABELS := ["한국어", "EN", "日本語"]
const FONT_SCALE_IDS := ["1.0", "1.15", "1.3"]
const FONT_SCALE_LABELS := ["100%", "115%", "130%"]
const TEXT := {
	"ko": {
		"app_title": "루시드 리버시",
		"you": "나",
		"ai": "AI",
		"black": "흑",
		"white": "백",
		"none": "없음",
		"easy": "쉬움",
		"medium": "보통",
		"hard": "어려움",
		"easy_short": "쉬움",
		"medium_short": "보통",
		"hard_short": "어려움",
		"new_game": "새 게임",
		"confirm_new_game_title": "대국을 새로 시작할까요?",
		"confirm_new_game_body": "진행 중인 대국은 저장되지 않습니다.",
		"confirm_yes": "확인",
		"confirm_no": "취소",
		"undo": "무르기",
		"restart": "다시",
		"board": "보드",
		"settings": "설정",
		"close": "닫기",
		"sound": "소리",
		"haptic": "진동",
		"difficulty_setting": "난이도",
		"board_size_setting": "보드 크기",
		"board_theme_title": "보드",
		"stone_theme_title": "돌",
		"language_setting": "언어",
		"about_title": "정보",
		"about_app_version": "%s · 버전 %s",
		"support_email": "지원 이메일 · %s",
		"privacy_policy": "개인정보 처리방침",
		"font_scale_setting": "글자 크기",
		"reduce_motion": "모션 줄이기",
		"show_moves": "착수 표시",
		"board_theme": "보드 %s",
		"stone_theme": "돌 %s",
		"locale": "언어 %s",
		"theme_classic": "기본",
		"theme_arctic": "빙하",
		"theme_ember": "노을",
		"status_game_over": "게임 종료",
		"status_flip": "뒤집는 중",
		"status_ai_thinking": "AI 생각 중",
		"status_pass": "패스",
		"status_your_move": "내 차례",
		"status_ai_turn": "AI 차례",
		"turn_final": "종료",
		"turn_player": "차례",
		"turn_ai": "AI",
		"focus_even": "균형",
		"focus_player_leads": "우세 +%d",
		"focus_ai_leads": "추격 -%d",
		"focus_valid": "착수 %d",
		"result_win": "승리",
		"result_draw": "무승부",
		"result_lose": "패배",
		"result_detail": "흑 %d / 백 %d",
		"stats_summary": "%s %d승 %d무 %d패",
	},
	"en": {
		"app_title": "LUCID REVERSI",
		"you": "YOU",
		"ai": "AI",
		"black": "BLACK",
		"white": "WHITE",
		"none": "NONE",
		"easy": "EASY",
		"medium": "MEDIUM",
		"hard": "HARD",
		"easy_short": "EASY",
		"medium_short": "MED",
		"hard_short": "HARD",
		"new_game": "NEW",
		"confirm_new_game_title": "START A NEW GAME?",
		"confirm_new_game_body": "Your current game will be discarded.",
		"confirm_yes": "CONFIRM",
		"confirm_no": "CANCEL",
		"undo": "UNDO",
		"restart": "RESTART",
		"board": "BOARD",
		"settings": "SET",
		"close": "CLOSE",
		"sound": "SOUND",
		"haptic": "HAPTIC",
		"difficulty_setting": "LEVEL",
		"board_size_setting": "BOARD SIZE",
		"board_theme_title": "BOARD",
		"stone_theme_title": "STONE",
		"language_setting": "LANG",
		"about_title": "ABOUT",
		"about_app_version": "%s · VERSION %s",
		"support_email": "SUPPORT · %s",
		"privacy_policy": "PRIVACY POLICY",
		"font_scale_setting": "TEXT SIZE",
		"reduce_motion": "REDUCE MOTION",
		"show_moves": "MOVES",
		"board_theme": "BOARD %s",
		"stone_theme": "STONE %s",
		"locale": "LANG %s",
		"theme_classic": "CLASSIC",
		"theme_arctic": "ARCTIC",
		"theme_ember": "EMBER",
		"status_game_over": "GAME OVER",
		"status_flip": "FLIP",
		"status_ai_thinking": "AI THINKING",
		"status_pass": "PASS",
		"status_your_move": "YOUR MOVE",
		"status_ai_turn": "AI TURN",
		"turn_final": "FINAL",
		"turn_player": "TURN",
		"turn_ai": "AI",
		"focus_even": "EVEN",
		"focus_player_leads": "LEAD +%d",
		"focus_ai_leads": "CHASE -%d",
		"focus_valid": "VALID %d",
		"result_win": "WIN",
		"result_draw": "DRAW",
		"result_lose": "LOSE",
		"result_detail": "BLACK %d / WHITE %d",
		"stats_summary": "%s %dW %dD %dL",
	},
	"ja": {
		"app_title": "ルーシッドリバーシ",
		"you": "あなた",
		"ai": "AI",
		"black": "黒",
		"white": "白",
		"none": "なし",
		"easy": "かんたん",
		"medium": "ふつう",
		"hard": "むずかしい",
		"easy_short": "かんたん",
		"medium_short": "ふつう",
		"hard_short": "むずかしい",
		"new_game": "新しい対局",
		"confirm_new_game_title": "新しい対局を始めますか？",
		"confirm_new_game_body": "進行中の対局は保存されません。",
		"confirm_yes": "決定",
		"confirm_no": "キャンセル",
		"undo": "一手戻す",
		"restart": "もう一度",
		"board": "盤面",
		"settings": "設定",
		"close": "閉じる",
		"sound": "サウンド",
		"haptic": "振動",
		"difficulty_setting": "難易度",
		"board_size_setting": "盤面サイズ",
		"board_theme_title": "盤面",
		"stone_theme_title": "石",
		"language_setting": "言語",
		"about_title": "情報",
		"about_app_version": "%s · バージョン %s",
		"support_email": "サポート · %s",
		"privacy_policy": "プライバシーポリシー",
		"font_scale_setting": "文字サイズ",
		"reduce_motion": "動きを減らす",
		"show_moves": "着手表示",
		"board_theme": "盤面 %s",
		"stone_theme": "石 %s",
		"locale": "言語 %s",
		"theme_classic": "クラシック",
		"theme_arctic": "氷河",
		"theme_ember": "夕焼け",
		"status_game_over": "対局終了",
		"status_flip": "反転中",
		"status_ai_thinking": "AI思考中",
		"status_pass": "パス",
		"status_your_move": "あなたの番",
		"status_ai_turn": "AIの番",
		"turn_final": "終了",
		"turn_player": "手番",
		"turn_ai": "AI",
		"focus_even": "互角",
		"focus_player_leads": "優勢 +%d",
		"focus_ai_leads": "劣勢 -%d",
		"focus_valid": "着手 %d",
		"result_win": "勝利",
		"result_draw": "引き分け",
		"result_lose": "敗北",
		"result_detail": "黒 %d / 白 %d",
		"stats_summary": "%s %d勝 %d分 %d敗",
	},
}

const BG_COLOR := Color(0.025, 0.035, 0.055, 1.0)
const HUD_COLOR := Color(0.075, 0.095, 0.14, 1.0)
const HUD_DARK := Color(0.045, 0.06, 0.09, 1.0)
const TEXT_PRIMARY := Color(0.96, 0.98, 1.0, 1.0)
const TEXT_MUTED := Color(0.74, 0.80, 0.88, 1.0)
const ACCENT := Color(1.0, 0.82, 0.18, 1.0)
const DANGER := Color(0.96, 0.31, 0.35, 1.0)
const SUCCESS := Color(0.28, 0.88, 0.54, 1.0)

var state: Dictionary
var preferences: Dictionary = {}
var player_stone := ReversiEngine.BLACK
var difficulty := "MEDIUM"
var ai_move_pending := false
var input_locked := false
# 한 판당 전면 광고 1회만 노출하기 위한 가드 (게임 종료 시 트리거).
var _interstitial_shown_this_game := false
# 결과 카드는 대국 종료 순간에만 1회 연출하고 재렌더·복원에서는 정적으로 표시한다.
var _result_animation_played_this_game := false
var analytics: ReversiAnalytics
var _ios_ads: Node
var _haptic_probe: Callable
var _interstitial_probe: Callable
var _save_path := SAVE_PATH
var _prefs_path := PREFS_PATH
var _motion_tween_count := 0
var _result_entry_animation_count := 0
var _winner_emphasis_animation_count := 0

var cell_buttons: Array = []
var cell_piece_views: Array = []
var cell_hint_views: Array = []
var player_score_label: Label
var ai_score_label: Label
var player_info_label: Label
var ai_info_label: Label
var player_stone_view: TextureRect
var ai_stone_view: TextureRect
var turn_badge: Label
var status_label: Label
var move_count_label: Label
var settings_button: Button
var settings_overlay: ColorRect
var settings_panel: PanelContainer
var sound_toggle: CheckButton
var haptic_toggle: CheckButton
var gameplay_strip: PanelContainer
var black_button: Button
var white_button: Button
var undo_button: Button
var new_game_button: Button
var difficulty_buttons: Array = []
var board_size_buttons: Array = []
var board_theme_buttons: Array = []
var stone_theme_buttons: Array = []
var locale_buttons: Array = []
var font_scale_buttons: Array = []
var reduce_motion_toggle: CheckButton
var show_moves_toggle: CheckButton
var result_overlay: ColorRect
var result_panel: PanelContainer
var result_winner_stone_view: TextureRect
var result_title_label: Label
var result_score_label: Label
var result_detail_label: Label
var result_stats_label: Label
var new_game_confirmation_overlay: ColorRect
var new_game_confirmation_title_label: Label
var new_game_confirmation_body_label: Label
var new_game_confirmation_confirm_button: Button
var new_game_confirmation_cancel_button: Button
var _pending_new_game_stone: int = ReversiEngine.NONE
var footer_primary_label: Label
var footer_secondary_label: Label
var black_meter: ColorRect
var white_meter: ColorRect
var _shell_open_override := Callable()


func _ready() -> void:
	analytics = ReversiAnalytics.new()
	# GA4 Measurement Protocol 전송기(Node)를 씬 트리에 붙여 어댑터에 주입한다.
	# 실제 전송은 config 존재 + 릴리스 빌드 + 비-headless 일 때만(전송기가 판단). _ready 에서 game_open 발생.
	var ga4_sender := GA4_SENDER_SCRIPT.new()
	ga4_sender.add_to_group("persistent_services")
	add_child(ga4_sender)
	analytics.set_sender(ga4_sender)
	# App Store(iOS) AdMob 전면광고 어댑터. iOS 네이티브에서만 초기화되고 그 외에는 no-op.
	_ios_ads = IOS_ADS_SCRIPT.new()
	_ios_ads.add_to_group("persistent_services")
	add_child(_ios_ads)
	preferences = _load_or_create_preferences()
	_load_or_start()
	_build_ui()
	_render()
	call_deferred("_maybe_play_ai_turn")


func _load_or_start() -> void:
	var loaded := _load_state()
	if loaded.is_empty():
		var preferred_settings: Dictionary = preferences.get(
			"settings",
			ReversiEngine.default_settings(),
		)
		var preferred_board_size := ReversiEngine.normalize_board_size(
			int(preferred_settings.get("board_size", ReversiEngine.DEFAULT_BOARD_SIZE))
		)
		state = ReversiEngine.create_new_game(
			player_stone,
			difficulty,
			preferred_board_size,
		)
	else:
		state = loaded
		player_stone = int(state.get("player_stone", ReversiEngine.BLACK))
		# 이미 종료된 게임을 복원한 경우: 그 game_over 는 지난 세션에서 이미 집계됐으므로
		# 이번 실행에서 광고·analytics on_game_over 를 다시 트리거하지 않는다(오버레이 표시만).
		if bool(state.get("game_over", false)):
			_interstitial_shown_this_game = true
			_result_animation_played_this_game = true
	_apply_preferences_to_state()


func _build_ui() -> void:
	for child in get_children():
		# GA4 전송기·광고 어댑터 같은 백그라운드 서비스 노드는 UI 재구성 시 삭제하지 않는다.
		# (_build_ui 는 _ready 외에 테마/난이도/언어 변경에서도 재호출되며 get_children 을 전부 지운다.
		#  이걸 지우면 광고가 초기화 직후 사라지고 GA4 전송기도 game_open 이후 이벤트를 못 보낸다.)
		if child.is_in_group("persistent_services"):
			continue
		child.queue_free()

	theme = _make_ui_theme()

	var background := ColorRect.new()
	background.color = _theme_color("bg")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var screen := MarginContainer.new()
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	var safe: Dictionary = _safe_area_margins()
	screen.add_theme_constant_override("margin_left", 12 + int(safe["left"]))
	screen.add_theme_constant_override("margin_top", 10 + int(safe["top"]))
	screen.add_theme_constant_override("margin_right", 12 + int(safe["right"]))
	screen.add_theme_constant_override("margin_bottom", 8 + int(safe["bottom"]))
	add_child(screen)

	var root := VBoxContainer.new()
	root.name = "GameRoot"
	root.alignment = BoxContainer.ALIGNMENT_BEGIN
	root.add_theme_constant_override("separation", 6)
	screen.add_child(root)

	_build_top_bar(root)
	_build_score_strip(root)
	_build_status_bar(root)
	_build_board(root)
	_build_play_focus_strip(root)
	_build_result_overlay()
	_build_settings_overlay()
	_build_new_game_confirmation_overlay()


func _build_top_bar(root: VBoxContainer) -> void:
	var bar := HBoxContainer.new()
	bar.custom_minimum_size = Vector2(0, 42)
	bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bar.add_theme_constant_override("separation", 8)
	root.add_child(bar)

	var title := Label.new()
	title.text = _t("app_title")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", _font_size(26))
	title.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(title, 2, _theme_color("text_primary"))
	bar.add_child(title)

	settings_button = _make_action_button(_t("settings"), func() -> void: _show_settings_menu(), false)
	settings_button.custom_minimum_size = Vector2(104, ACTION_BUTTON_HEIGHT)
	bar.add_child(settings_button)


func _build_score_strip(root: VBoxContainer) -> void:
	var strip := PanelContainer.new()
	strip.custom_minimum_size = Vector2(0, 78)
	strip.add_theme_stylebox_override("panel", _make_style(_theme_color("hud_dark"), 1, Color(1, 1, 1, 0.08), 8))
	root.add_child(strip)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	strip.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	var player_panel := _make_compact_score_panel(_t("you"), player_stone)
	player_score_label = player_panel["score"]
	player_info_label = player_panel["info"]
	player_stone_view = player_panel["stone"]
	row.add_child(player_panel["panel"])

	turn_badge = Label.new()
	turn_badge.custom_minimum_size = Vector2(126, 58)
	turn_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	turn_badge.add_theme_font_size_override("font_size", _font_size(18))
	turn_badge.add_theme_color_override("font_color", Color(0.06, 0.055, 0.035, 1.0))
	_apply_text_visibility(turn_badge, 1, Color(0.06, 0.055, 0.035, 1.0))
	turn_badge.add_theme_stylebox_override("normal", _make_style(_theme_color("accent"), 1, Color(1, 1, 1, 0.18), 8))
	row.add_child(turn_badge)

	var ai_panel := _make_compact_score_panel(_t("ai"), ReversiEngine.opponent(player_stone))
	ai_score_label = ai_panel["score"]
	ai_info_label = ai_panel["info"]
	ai_stone_view = ai_panel["stone"]
	row.add_child(ai_panel["panel"])


func _make_compact_score_panel(name_text: String, stone: int) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(250, 58)
	panel.add_theme_stylebox_override("panel", _make_style(_theme_color("hud"), 1, Color(1, 1, 1, 0.08), 8))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 5)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	var stone_view := TextureRect.new()
	stone_view.custom_minimum_size = Vector2(42, 42)
	stone_view.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	stone_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stone_view.texture = _texture_for_stone(stone)
	row.add_child(stone_view)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 0)
	row.add_child(text_box)

	var info := Label.new()
	info.text = "%s / %s" % [name_text, _piece_label(stone)]
	info.add_theme_font_size_override("font_size", _font_size(13))
	info.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(info, 1, _theme_color("text_muted"))
	text_box.add_child(info)

	var score := Label.new()
	score.text = "2"
	score.add_theme_font_size_override("font_size", _font_size(30))
	score.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(score, 2, _theme_color("text_primary"))
	text_box.add_child(score)

	return {
		"panel": panel,
		"score": score,
		"info": info,
		"stone": stone_view,
	}


func _build_status_bar(root: VBoxContainer) -> void:
	var status := HBoxContainer.new()
	status.custom_minimum_size = Vector2(0, 30)
	status.alignment = BoxContainer.ALIGNMENT_CENTER
	status.add_theme_constant_override("separation", 8)
	root.add_child(status)

	status_label = Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.add_theme_font_size_override("font_size", _font_size(17))
	status_label.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(status_label, 1, _theme_color("text_muted"))
	status.add_child(status_label)

	move_count_label = Label.new()
	move_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	move_count_label.add_theme_font_size_override("font_size", _font_size(16))
	move_count_label.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(move_count_label, 1, _theme_color("text_muted"))
	status.add_child(move_count_label)


func _build_board(root: VBoxContainer) -> void:
	var board_size := _current_board_size()
	var cell_size := cell_size_for_board(board_size)
	var piece_margin := maxi(5, int(round(float(cell_size) / 12.0)))
	var hint_margin := maxi(16, int(round(float(cell_size) / 3.0)))
	var board_frame := PanelContainer.new()
	var board_frame_size := board_frame_size_for_board(board_size)
	board_frame.custom_minimum_size = Vector2(board_frame_size, board_frame_size)
	board_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	board_frame.add_theme_stylebox_override("panel", _make_style(_theme_color("board_frame"), 2, _theme_color("board_frame_border"), 6))
	root.add_child(board_frame)

	var board_margin := MarginContainer.new()
	board_margin.add_theme_constant_override("margin_left", BOARD_PADDING)
	board_margin.add_theme_constant_override("margin_top", BOARD_PADDING)
	board_margin.add_theme_constant_override("margin_right", BOARD_PADDING)
	board_margin.add_theme_constant_override("margin_bottom", BOARD_PADDING)
	board_frame.add_child(board_margin)

	var board_surface := PanelContainer.new()
	board_surface.name = "BoardSurface"
	board_surface.add_theme_stylebox_override(
		"panel",
		_make_style(_theme_color("board_grid"), 0, Color.TRANSPARENT, 2),
	)
	board_margin.add_child(board_surface)

	var board := GridContainer.new()
	board.name = "BoardGrid"
	board.columns = board_size
	board.add_theme_constant_override("h_separation", CELL_GAP)
	board.add_theme_constant_override("v_separation", CELL_GAP)
	board_surface.add_child(board)

	cell_buttons.clear()
	cell_piece_views.clear()
	cell_hint_views.clear()
	for x in range(board_size):
		var button_row: Array = []
		var piece_row: Array = []
		var hint_row: Array = []
		for y in range(board_size):
			var cell_x := x
			var cell_y := y
			var button := Button.new()
			button.custom_minimum_size = Vector2(cell_size, cell_size)
			button.focus_mode = Control.FOCUS_NONE
			button.clip_contents = true
			button.text = ""
			button.pressed.connect(func() -> void: _on_cell_pressed(cell_x, cell_y))

			var piece := TextureRect.new()
			piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
			piece.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			piece.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			piece.set_anchors_preset(Control.PRESET_FULL_RECT)
			piece.offset_left = piece_margin
			piece.offset_top = piece_margin
			piece.offset_right = -piece_margin
			piece.offset_bottom = -piece_margin
			button.add_child(piece)

			var hint := PanelContainer.new()
			hint.visible = false
			hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hint.set_anchors_preset(Control.PRESET_FULL_RECT)
			hint.offset_left = hint_margin
			hint.offset_top = hint_margin
			hint.offset_right = -hint_margin
			hint.offset_bottom = -hint_margin
			hint.add_theme_stylebox_override("panel", _make_style(_theme_color("hint"), 1, _theme_color("hint_border"), 14))
			button.add_child(hint)

			board.add_child(button)
			button_row.append(button)
			piece_row.append(piece)
			hint_row.append(hint)
		cell_buttons.append(button_row)
		cell_piece_views.append(piece_row)
		cell_hint_views.append(hint_row)


func _build_play_focus_strip(root: VBoxContainer) -> void:
	gameplay_strip = PanelContainer.new()
	gameplay_strip.custom_minimum_size = Vector2(0, 48)
	gameplay_strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gameplay_strip.add_theme_stylebox_override("panel", _make_style(_theme_color("hud_dark"), 1, Color(1, 1, 1, 0.08), 8))
	root.add_child(gameplay_strip)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 7)
	gameplay_strip.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	footer_primary_label = Label.new()
	footer_primary_label.custom_minimum_size = Vector2(112, 0)
	footer_primary_label.add_theme_font_size_override("font_size", _font_size(18))
	footer_primary_label.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(footer_primary_label, 2, _theme_color("text_primary"))
	row.add_child(footer_primary_label)

	var meter_panel := PanelContainer.new()
	meter_panel.custom_minimum_size = Vector2(0, 28)
	meter_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meter_panel.add_theme_stylebox_override("panel", _make_style(_theme_color("meter_bg"), 1, Color(1, 1, 1, 0.08), 6))
	row.add_child(meter_panel)

	var meter_margin := MarginContainer.new()
	meter_margin.add_theme_constant_override("margin_left", 6)
	meter_margin.add_theme_constant_override("margin_top", 6)
	meter_margin.add_theme_constant_override("margin_right", 6)
	meter_margin.add_theme_constant_override("margin_bottom", 6)
	meter_panel.add_child(meter_margin)

	var meter := HBoxContainer.new()
	meter.add_theme_constant_override("separation", 3)
	meter_margin.add_child(meter)

	black_meter = ColorRect.new()
	black_meter.custom_minimum_size = Vector2(12, 0)
	black_meter.color = _stone_theme_color("black_meter")
	black_meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meter.add_child(black_meter)

	white_meter = ColorRect.new()
	white_meter.custom_minimum_size = Vector2(12, 0)
	white_meter.color = _stone_theme_color("white_meter")
	white_meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meter.add_child(white_meter)

	var controls_strip := PanelContainer.new()
	controls_strip.custom_minimum_size = Vector2(0, 74)
	controls_strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_strip.add_theme_stylebox_override("panel", _make_style(_theme_color("hud"), 1, Color(1, 1, 1, 0.07), 8))
	root.add_child(controls_strip)

	var controls_margin := MarginContainer.new()
	controls_margin.add_theme_constant_override("margin_left", 10)
	controls_margin.add_theme_constant_override("margin_top", 6)
	controls_margin.add_theme_constant_override("margin_right", 10)
	controls_margin.add_theme_constant_override("margin_bottom", 6)
	controls_strip.add_child(controls_margin)

	var controls_row := HBoxContainer.new()
	controls_row.alignment = BoxContainer.ALIGNMENT_CENTER
	controls_row.add_theme_constant_override("separation", 8)
	controls_margin.add_child(controls_row)

	var left_spacer := Control.new()
	left_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_row.add_child(left_spacer)

	black_button = _make_segment_button(_t("black"), func() -> void: _request_new_game(ReversiEngine.BLACK))
	black_button.custom_minimum_size = Vector2(112, PLAY_BUTTON_HEIGHT)
	controls_row.add_child(black_button)

	white_button = _make_segment_button(_t("white"), func() -> void: _request_new_game(ReversiEngine.WHITE))
	white_button.custom_minimum_size = Vector2(112, PLAY_BUTTON_HEIGHT)
	controls_row.add_child(white_button)

	undo_button = _make_action_button(_t("undo"), func() -> void: _on_undo_pressed())
	undo_button.custom_minimum_size = Vector2(128, PLAY_BUTTON_HEIGHT)
	controls_row.add_child(undo_button)

	new_game_button = _make_action_button(_t("new_game"), func() -> void: _request_new_game(player_stone), true)
	new_game_button.custom_minimum_size = Vector2(172, PLAY_BUTTON_HEIGHT)
	controls_row.add_child(new_game_button)

	var right_spacer := Control.new()
	right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_row.add_child(right_spacer)

	footer_secondary_label = Label.new()
	footer_secondary_label.custom_minimum_size = Vector2(96, 0)
	footer_secondary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	footer_secondary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer_secondary_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	footer_secondary_label.add_theme_font_size_override("font_size", _font_size(16))
	footer_secondary_label.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(footer_secondary_label, 1, _theme_color("text_muted"))
	right_spacer.add_child(footer_secondary_label)


func _build_result_overlay() -> void:
	result_overlay = ColorRect.new()
	result_overlay.visible = false
	result_overlay.color = Color(0.005, 0.008, 0.014, 0.78)
	result_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(result_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	result_overlay.add_child(center)

	result_panel = PanelContainer.new()
	result_panel.custom_minimum_size = Vector2(420, 300)
	result_panel.pivot_offset = result_panel.custom_minimum_size * 0.5
	result_panel.add_theme_stylebox_override("panel", _make_style(_theme_color("hud_dark"), 2, Color(1, 1, 1, 0.14), 10))
	center.add_child(result_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 20)
	result_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	result_title_label = Label.new()
	result_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title_label.add_theme_font_size_override("font_size", _font_size(36))
	result_title_label.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(result_title_label, 3, _theme_color("text_primary"))
	box.add_child(result_title_label)

	result_winner_stone_view = TextureRect.new()
	result_winner_stone_view.custom_minimum_size = Vector2(72, 72)
	result_winner_stone_view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	result_winner_stone_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result_winner_stone_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result_winner_stone_view.pivot_offset = result_winner_stone_view.custom_minimum_size * 0.5
	box.add_child(result_winner_stone_view)

	result_score_label = Label.new()
	result_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_score_label.add_theme_font_size_override("font_size", _font_size(42))
	result_score_label.add_theme_color_override("font_color", _theme_color("accent"))
	_apply_text_visibility(result_score_label, 3, _theme_color("accent"))
	box.add_child(result_score_label)

	result_detail_label = Label.new()
	result_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_detail_label.add_theme_font_size_override("font_size", _font_size(16))
	result_detail_label.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(result_detail_label, 1, _theme_color("text_muted"))
	box.add_child(result_detail_label)

	result_stats_label = Label.new()
	result_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_stats_label.add_theme_font_size_override("font_size", _font_size(18))
	result_stats_label.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(result_stats_label, 1, _theme_color("text_primary"))
	box.add_child(result_stats_label)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 8)
	box.add_child(buttons)

	buttons.add_child(_make_action_button(_t("restart"), func() -> void: _start_new_game(player_stone), true))
	buttons.add_child(_make_action_button(_t("board"), func() -> void: result_overlay.visible = false, false))


func _build_settings_overlay() -> void:
	settings_overlay = ColorRect.new()
	settings_overlay.visible = false
	settings_overlay.color = Color(0.005, 0.008, 0.014, 0.58)
	settings_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	settings_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_overlay.gui_input.connect(_on_settings_overlay_gui_input)
	add_child(settings_overlay)

	var anchor := MarginContainer.new()
	anchor.set_anchors_preset(Control.PRESET_FULL_RECT)
	anchor.add_theme_constant_override("margin_left", 12)
	anchor.add_theme_constant_override("margin_top", 58)
	anchor.add_theme_constant_override("margin_right", 12)
	anchor.add_theme_constant_override("margin_bottom", 12)
	settings_overlay.add_child(anchor)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	anchor.add_child(row)

	settings_panel = PanelContainer.new()
	settings_panel.custom_minimum_size = Vector2(420, 0)
	settings_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_panel.add_theme_stylebox_override("panel", _make_style(_theme_color("hud_dark"), 2, Color(1, 1, 1, 0.14), 10))
	row.add_child(settings_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	settings_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)

	var title := Label.new()
	title.text = _t("settings")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", _font_size(22))
	title.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(title, 2, _theme_color("text_primary"))
	header.add_child(title)
	header.add_child(_make_action_button(_t("close"), func() -> void: _hide_settings_menu(), false))

	box.add_child(_make_choice_section(
		_t("difficulty_setting"),
		DIFFICULTY_IDS,
		[_t("easy_short"), _t("medium_short"), _t("hard_short")],
		difficulty,
		Callable(self, "_set_difficulty_from_choice"),
		difficulty_buttons
	))

	box.add_child(_make_choice_section(
		_t("board_size_setting"),
		BOARD_SIZE_IDS,
		BOARD_SIZE_LABELS,
		str(_current_board_size()),
		Callable(self, "_set_board_size_from_choice"),
		board_size_buttons
	))

	sound_toggle = _make_toggle_button(_t("sound"), "sound")
	box.add_child(sound_toggle)
	haptic_toggle = _make_toggle_button(_t("haptic"), "haptic")
	box.add_child(haptic_toggle)
	show_moves_toggle = _make_toggle_button(_t("show_moves"), "show_moves")
	box.add_child(show_moves_toggle)
	reduce_motion_toggle = _make_toggle_button(_t("reduce_motion"), "reduce_motion")
	box.add_child(reduce_motion_toggle)

	box.add_child(_make_choice_section(
		_t("font_scale_setting"),
		FONT_SCALE_IDS,
		FONT_SCALE_LABELS,
		_current_font_scale_id(),
		Callable(self, "_set_font_scale_from_choice"),
		font_scale_buttons
	))

	var theme_labels: Array = []
	for theme_id in THEME_IDS:
		theme_labels.append(_theme_display_label(str(theme_id)))
	box.add_child(_make_choice_section(
		_t("board_theme_title"),
		THEME_IDS,
		theme_labels,
		_current_theme_id(),
		Callable(self, "_set_theme"),
		board_theme_buttons
	))

	var stone_theme_labels: Array = []
	for theme_id in STONE_THEME_IDS:
		stone_theme_labels.append(_theme_display_label(str(theme_id)))
	box.add_child(_make_choice_section(
		_t("stone_theme_title"),
		STONE_THEME_IDS,
		stone_theme_labels,
		_current_stone_theme_id(),
		Callable(self, "_set_stone_theme"),
		stone_theme_buttons
	))

	var language_section := _make_choice_section(
		_t("language_setting"),
		LOCALE_IDS,
		LOCALE_LABELS,
		_current_locale_id(),
		Callable(self, "_set_locale"),
		locale_buttons
	)
	language_section.name = "LanguageSection"
	box.add_child(language_section)
	box.add_child(_make_about_section(PRIVACY_POLICY_URL))


func _build_new_game_confirmation_overlay() -> void:
	new_game_confirmation_overlay = ColorRect.new()
	new_game_confirmation_overlay.visible = false
	new_game_confirmation_overlay.color = Color(0.005, 0.008, 0.014, 0.78)
	new_game_confirmation_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	new_game_confirmation_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(new_game_confirmation_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	new_game_confirmation_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440, 220)
	panel.add_theme_stylebox_override("panel", _make_style(_theme_color("hud_dark"), 2, Color(1, 1, 1, 0.14), 10))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	new_game_confirmation_title_label = Label.new()
	new_game_confirmation_title_label.text = _t("confirm_new_game_title")
	new_game_confirmation_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_game_confirmation_title_label.add_theme_font_size_override("font_size", _font_size(26))
	new_game_confirmation_title_label.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(new_game_confirmation_title_label, 2, _theme_color("text_primary"))
	box.add_child(new_game_confirmation_title_label)

	new_game_confirmation_body_label = Label.new()
	new_game_confirmation_body_label.text = _t("confirm_new_game_body")
	new_game_confirmation_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_game_confirmation_body_label.add_theme_font_size_override("font_size", _font_size(17))
	new_game_confirmation_body_label.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(new_game_confirmation_body_label, 1, _theme_color("text_muted"))
	box.add_child(new_game_confirmation_body_label)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 8)
	box.add_child(buttons)

	new_game_confirmation_cancel_button = _make_action_button(
		_t("confirm_no"),
		func() -> void: _cancel_new_game_confirmation(),
		false,
	)
	buttons.add_child(new_game_confirmation_cancel_button)
	new_game_confirmation_confirm_button = _make_action_button(
		_t("confirm_yes"),
		func() -> void: _confirm_new_game(),
		true,
	)
	buttons.add_child(new_game_confirmation_confirm_button)


func _make_segment_button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(124, ACTION_BUTTON_HEIGHT)
	button.text = text
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", _font_size(21))
	button.pressed.connect(action)
	return button


func _make_action_button(text: String, action: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(128, ACTION_BUTTON_HEIGHT)
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", _font_size(20))
	var bg := _theme_color("accent") if primary else _theme_color("hud")
	var fg := Color(0.055, 0.048, 0.025, 1.0) if primary else _theme_color("text_primary")
	button.add_theme_stylebox_override("normal", _make_style(bg, 1, Color(1, 1, 1, 0.13), 6))
	button.add_theme_stylebox_override("hover", _make_style(bg.lightened(0.08), 1, Color(1, 1, 1, 0.22), 6))
	button.add_theme_stylebox_override("pressed", _make_style(bg.darkened(0.08), 1, Color(0, 0, 0, 0.22), 6))
	button.add_theme_color_override("font_color", fg)
	button.add_theme_color_override("font_hover_color", fg)
	button.add_theme_color_override("font_pressed_color", fg)
	_apply_text_visibility(button, 1, fg)
	button.pressed.connect(action)
	return button


func _make_about_section(privacy_policy_url: String) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.name = "AboutSection"
	section.add_theme_constant_override("separation", 5)

	var title := Label.new()
	title.name = "AboutTitle"
	title.text = _t("about_title")
	title.add_theme_font_size_override("font_size", _font_size(16))
	title.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(title, 1, _theme_color("text_muted"))
	section.add_child(title)

	var app_version := Label.new()
	app_version.name = "AboutAppVersion"
	app_version.text = _t("about_app_version") % [
		_t("app_title"),
		str(ProjectSettings.get_setting("application/config/version", "")),
	]
	app_version.add_theme_font_size_override("font_size", _font_size(16))
	app_version.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(app_version, 1, _theme_color("text_primary"))
	section.add_child(app_version)

	var support_button := _make_action_button(
		_t("support_email") % SUPPORT_EMAIL,
		func() -> void: _open_external_uri("mailto:%s" % SUPPORT_EMAIL),
	)
	support_button.name = "SupportEmailButton"
	section.add_child(support_button)

	var normalized_privacy_url := privacy_policy_url.strip_edges()
	if !normalized_privacy_url.is_empty():
		var privacy_button := _make_action_button(
			_t("privacy_policy"),
			func() -> void: _open_external_uri(normalized_privacy_url),
		)
		privacy_button.name = "PrivacyPolicyButton"
		section.add_child(privacy_button)
	return section


func _open_external_uri(uri: String) -> void:
	if uri.is_empty():
		return
	if _shell_open_override.is_valid():
		_shell_open_override.call(uri)
		return
	OS.shell_open(uri)


func _make_choice_section(title_text: String, option_ids: Array, option_labels: Array, selected_id: String, action: Callable, button_store: Array) -> VBoxContainer:
	button_store.clear()
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 5)

	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", _font_size(16))
	title.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(title, 1, _theme_color("text_muted"))
	section.add_child(title)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	section.add_child(row)

	for index in range(option_ids.size()):
		var option_id := str(option_ids[index])
		var label := str(option_labels[index])
		var button := _make_choice_button(label, option_id == selected_id)
		button.pressed.connect(action.bind(option_id))
		row.add_child(button)
		button_store.append({
			"id": option_id,
			"button": button,
		})

	return section


func _make_choice_button(text: String, active: bool) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, SETTINGS_CHOICE_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = text
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", _font_size(19))
	button.button_pressed = active
	_apply_segment_style(button, active)
	return button


func _make_toggle_button(text: String, key: String) -> CheckButton:
	var toggle := CheckButton.new()
	toggle.custom_minimum_size = Vector2(0, ACTION_BUTTON_HEIGHT)
	toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toggle.text = text
	toggle.focus_mode = Control.FOCUS_NONE
	toggle.add_theme_font_size_override("font_size", _font_size(19))
	var settings: Dictionary = state.get("settings", ReversiEngine.default_settings())
	toggle.button_pressed = bool(settings.get(key, true))
	toggle.add_theme_stylebox_override("normal", _make_style(_theme_color("hud"), 1, Color(1, 1, 1, 0.10), 6))
	toggle.add_theme_stylebox_override("hover", _make_style(_theme_color("hud").lightened(0.08), 1, Color(1, 1, 1, 0.18), 6))
	toggle.add_theme_color_override("font_color", _theme_color("text_primary"))
	toggle.add_theme_color_override("font_hover_color", _theme_color("text_primary"))
	_apply_text_visibility(toggle, 1, _theme_color("text_primary"))
	toggle.toggled.connect(func(enabled: bool) -> void:
		var current_settings: Dictionary = state.get("settings", ReversiEngine.default_settings())
		current_settings[key] = enabled
		state["settings"] = current_settings
		_save_preferences()
		if key == "show_moves":
			_render()
	)
	return toggle


func _show_settings_menu() -> void:
	if settings_overlay != null:
		settings_overlay.visible = true


func _hide_settings_menu() -> void:
	if settings_overlay != null:
		settings_overlay.visible = false


func _on_settings_overlay_gui_input(event: InputEvent) -> void:
	if !_settings_overlay_tap_should_close(event):
		return
	_hide_settings_menu()
	settings_overlay.accept_event()


func _settings_overlay_tap_should_close(event: InputEvent) -> bool:
	if settings_overlay == null or !settings_overlay.visible:
		return false
	var position := Vector2.ZERO
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if !mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return false
		position = mouse_event.position
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if !touch_event.pressed:
			return false
		position = touch_event.position
	else:
		return false
	return !_settings_panel_contains_point(position)


func _settings_panel_contains_point(position: Vector2) -> bool:
	return settings_panel != null and settings_panel.get_global_rect().has_point(position)


func _has_game_in_progress() -> bool:
	return !bool(state.get("game_over", false)) and !state.get("move_history", []).is_empty()


func _request_new_game(stone: int) -> void:
	if !_has_game_in_progress():
		_start_new_game(stone)
		return
	_pending_new_game_stone = stone
	new_game_confirmation_overlay.visible = true


func _cancel_new_game_confirmation() -> void:
	_pending_new_game_stone = ReversiEngine.NONE
	new_game_confirmation_overlay.visible = false
	_update_mode_buttons()


func _confirm_new_game() -> void:
	var stone: int = _pending_new_game_stone
	_cancel_new_game_confirmation()
	if stone == ReversiEngine.NONE:
		return
	_start_new_game(stone)


func _start_new_game(stone: int, persist: bool = true) -> void:
	ai_move_pending = false
	input_locked = false
	_interstitial_shown_this_game = false
	_result_animation_played_this_game = false
	var current_settings := _current_settings()
	var current_stats := ReversiEngine.normalize_stats(state.get("stats", {}))
	var board_size := ReversiEngine.normalize_board_size(
		int(current_settings.get("board_size", ReversiEngine.DEFAULT_BOARD_SIZE))
	)
	var rebuild_board := cell_buttons.size() != board_size
	player_stone = stone
	state = ReversiEngine.create_new_game(player_stone, difficulty, board_size)
	current_settings["board_size"] = board_size
	state["settings"] = current_settings
	state["stats"] = current_stats
	if rebuild_board:
		_build_ui()
	_sync_identity_labels()
	if persist:
		_save_state()
	_render()
	if analytics != null:
		analytics.on_game_start(difficulty, player_stone)
	call_deferred("_maybe_play_ai_turn")


static func cell_size_for_board(board_size: int) -> int:
	var normalized_size := ReversiEngine.normalize_board_size(board_size)
	return maxi(
		1,
		int(floor(
			float(BOARD_TARGET_CONTENT_SIZE - CELL_GAP * (normalized_size - 1))
			/ float(normalized_size)
		)),
	)


static func board_frame_size_for_board(board_size: int) -> int:
	var normalized_size := ReversiEngine.normalize_board_size(board_size)
	var cell_size := cell_size_for_board(normalized_size)
	return (
		cell_size * normalized_size
		+ CELL_GAP * (normalized_size - 1)
		+ BOARD_PADDING * 2
	)


func _sync_identity_labels() -> void:
	if player_info_label == null:
		return
	player_info_label.text = "%s / %s" % [_t("you"), _piece_label(player_stone)]
	ai_info_label.text = "%s / %s" % [_t("ai"), _piece_label(ReversiEngine.opponent(player_stone))]
	player_stone_view.texture = _texture_for_stone(player_stone)
	ai_stone_view.texture = _texture_for_stone(ReversiEngine.opponent(player_stone))


func _on_undo_pressed(persist: bool = true) -> void:
	if !_can_undo():
		return
	var result := ReversiEngine.undo_last_round(state)
	if !bool(result.get("ok", false)):
		return
	if persist:
		_save_state()
	_render()


func _can_undo() -> bool:
	if state.is_empty() or input_locked or ai_move_pending:
		return false
	if bool(state.get("game_over", false)):
		return false
	if int(state.get("current_turn", ReversiEngine.NONE)) != player_stone:
		return false
	return ReversiEngine.can_undo_last_round(state)


func _on_cell_pressed(x: int, y: int) -> void:
	if input_locked:
		return
	if bool(state.get("game_over", false)):
		_update_result_overlay()
		return
	if int(state.get("current_turn", ReversiEngine.NONE)) != player_stone:
		status_label.text = _t("status_ai_thinking")
		return

	var before_board := ReversiEngine.clone_board(state["board"])
	var result := ReversiEngine.play_move(state, x, y)
	if !bool(result.get("ok", false)):
		_pulse_cell(x, y, _theme_color("danger"))
		return

	_save_state()
	await _render_with_animation(before_board, result)
	call_deferred("_maybe_play_ai_turn")


func _maybe_play_ai_turn() -> void:
	if input_locked or ai_move_pending:
		return
	if bool(state.get("game_over", false)):
		_update_result_overlay()
		return
	var ai_stone: int = int(state.get("ai_stone", ReversiEngine.WHITE))
	if int(state.get("current_turn", ReversiEngine.NONE)) != ai_stone:
		return

	ai_move_pending = true
	status_label.text = _t("status_ai_thinking")
	await get_tree().create_timer(0.28).timeout
	if bool(state.get("game_over", false)) or int(state.get("current_turn", ReversiEngine.NONE)) != ai_stone:
		ai_move_pending = false
		_render()
		return

	var move := ReversiEngine.choose_ai_move(state)
	if move.is_empty():
		ai_move_pending = false
		_render()
		return

	var before_board := ReversiEngine.clone_board(state["board"])
	var result := ReversiEngine.play_move(state, int(move["x"]), int(move["y"]))
	_save_state()
	ai_move_pending = false
	await _render_with_animation(before_board, result)
	# 플레이어가 착수할 곳이 없어 패스되면 엔진이 턴을 다시 AI 에게 넘긴다.
	# 이 경우 재호출하지 않으면 AI 차례에서 게임이 멈추므로 다시 트리거한다.
	call_deferred("_maybe_play_ai_turn")


func _render_with_animation(before_board: Array, result: Dictionary) -> void:
	input_locked = true
	_render()
	await get_tree().process_frame
	await _animate_move_result(before_board, result)
	input_locked = false
	_render()


func _animate_move_result(before_board: Array, result: Dictionary) -> void:
	if !bool(result.get("ok", false)):
		return

	var placed: Dictionary = result.get("placed", {})
	var flipped: Array = result.get("flipped", [])
	var stone := int(placed.get("stone", ReversiEngine.NONE))
	var wait_time := 0.0

	if _reduce_motion_enabled():
		if !placed.is_empty():
			_play_place_sound()
		if flipped.size() >= 4:
			_play_big_flip_sound(flipped.size())
		elif !flipped.is_empty():
			_play_flip_sound(0)
		return

	if !placed.is_empty():
		var px := int(placed["x"])
		var py := int(placed["y"])
		_play_place_sound()
		_prepare_piece_view(px, py)
		var placed_view: TextureRect = cell_piece_views[px][py]
		placed_view.texture = _texture_for_stone(stone)
		placed_view.modulate = Color(1, 1, 1, 0.0)
		placed_view.scale = Vector2(0.34, 0.34)
		_motion_tween_count += 1
		var placed_tween := create_tween()
		placed_tween.set_parallel(true)
		placed_tween.tween_property(placed_view, "modulate:a", 1.0, 0.13).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		placed_tween.tween_property(placed_view, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		wait_time = max(wait_time, 0.17)
		_pulse_cell(px, py, _theme_color("accent"))

	if flipped.size() >= 4:
		_motion_tween_count += 1
		var big_sound_tween := create_tween()
		big_sound_tween.tween_interval(big_flip_sound_delay(placed, flipped))
		big_sound_tween.tween_callback(func() -> void: _play_big_flip_sound(flipped.size()))

	for index in range(flipped.size()):
		var cell: Dictionary = flipped[index]
		var x := int(cell["x"])
		var y := int(cell["y"])
		_prepare_piece_view(x, y)
		var view: TextureRect = cell_piece_views[x][y]
		var before_stone := int(before_board[x][y])
		view.texture = _texture_for_stone(before_stone)
		view.modulate = Color.WHITE
		view.scale = Vector2.ONE
		view.rotation = 0.0
		var delay := flip_wave_delay(placed, cell)
		var transition := flip_transition_profile(index)
		var front_scale: Vector2 = transition["front_scale"]
		var back_scale: Vector2 = transition["back_scale"]
		var tilt: float = transition["tilt"]
		var highlight: Color = transition["highlight"]
		var swap_alpha: float = transition["swap_alpha"]
		_motion_tween_count += 1
		var tween := create_tween()
		tween.tween_interval(delay)
		tween.tween_property(view, "scale", front_scale, FLIP_HALF_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(view, "rotation", tilt, FLIP_HALF_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(view, "modulate", highlight, FLIP_HALF_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_callback(func() -> void:
			view.texture = _texture_for_stone(stone)
			view.scale = back_scale
			view.modulate = Color(1.0, 1.0, 1.0, swap_alpha)
			if flipped.size() < 4:
				_play_flip_sound(index)
		)
		tween.tween_property(view, "scale", Vector2.ONE, FLIP_HALF_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(view, "rotation", 0.0, FLIP_HALF_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(view, "modulate", Color.WHITE, FLIP_HALF_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		wait_time = max(wait_time, delay + FLIP_HALF_DURATION * 2.0 + 0.02)

	if wait_time > 0.0:
		await get_tree().create_timer(wait_time).timeout


func _render() -> void:
	_sync_identity_labels()
	var counts := ReversiEngine.count_pieces(state.get("board", []))
	var black_score := int(counts["black"])
	var white_score := int(counts["white"])
	player_score_label.text = str(black_score if player_stone == ReversiEngine.BLACK else white_score)
	ai_score_label.text = str(white_score if player_stone == ReversiEngine.BLACK else black_score)
	var player_score := black_score if player_stone == ReversiEngine.BLACK else white_score
	var ai_score := white_score if player_stone == ReversiEngine.BLACK else black_score

	var current_turn := int(state.get("current_turn", ReversiEngine.NONE))
	turn_badge.text = _turn_text(current_turn)
	status_label.text = _status_text()
	move_count_label.text = "%02d" % state.get("move_history", []).size()
	footer_primary_label.text = _advantage_text(player_score, ai_score)
	footer_secondary_label.text = _t("focus_valid") % state.get("valid_moves", []).size()
	black_meter.size_flags_stretch_ratio = max(1.0, float(black_score))
	white_meter.size_flags_stretch_ratio = max(1.0, float(white_score))
	_update_mode_buttons()
	_update_settings_choice_buttons()
	_update_turn_badge(current_turn)
	if undo_button != null:
		undo_button.disabled = !_can_undo()

	var board: Array = state.get("board", [])
	var valid_moves: Array = state.get("valid_moves", [])
	var board_size := ReversiEngine.get_board_size(board)
	for x in range(board_size):
		for y in range(board_size):
			var piece := int(board[x][y])
			var is_valid := _is_valid_cell(valid_moves, x, y)
			var is_last := _is_last_move(x, y)
			_render_cell(x, y, piece, is_valid, is_last)

	if bool(state.get("game_over", false)):
		_update_result_overlay()
	else:
		result_overlay.visible = false


func _render_cell(x: int, y: int, piece: int, is_valid: bool, is_last: bool) -> void:
	var button: Button = cell_buttons[x][y]
	var piece_view: TextureRect = cell_piece_views[x][y]
	var hint_view: PanelContainer = cell_hint_views[x][y]
	var base := _theme_color("board_surface")
	var border_width := 3 if is_last else 0
	var border_color := _theme_color("accent") if is_last else Color.TRANSPARENT

	button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	button.disabled = false
	hint_view.visible = false
	if piece == ReversiEngine.NONE and is_valid and int(state.get("current_turn", ReversiEngine.NONE)) == player_stone and !input_locked:
		piece_view.texture = null
		piece_view.modulate = Color.TRANSPARENT
		piece_view.scale = Vector2.ONE
		if _show_moves_enabled():
			base = base.lightened(0.08)
			hint_view.visible = true
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	elif piece == ReversiEngine.BLACK or piece == ReversiEngine.WHITE:
		piece_view.texture = _texture_for_stone(piece)
		piece_view.modulate = Color.WHITE
		piece_view.scale = Vector2.ONE
	else:
		piece_view.texture = null
		piece_view.modulate = Color.TRANSPARENT
		piece_view.scale = Vector2.ONE
	piece_view.rotation = 0.0

	button.add_theme_stylebox_override("normal", _make_style(base, border_width, border_color))
	button.add_theme_stylebox_override("hover", _make_style(base.lightened(0.07), max(border_width, 2), _theme_color("accent") if is_valid else border_color))
	button.add_theme_stylebox_override("pressed", _make_style(base.darkened(0.08), max(border_width, 2), Color(0, 0, 0, 0.32)))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _prepare_piece_view(x: int, y: int) -> void:
	var view: TextureRect = cell_piece_views[x][y]
	view.pivot_offset = view.size * 0.5


func _pulse_cell(x: int, y: int, color: Color) -> void:
	var button: Button = cell_buttons[x][y]
	if _reduce_motion_enabled():
		button.modulate = Color.WHITE
		return
	_motion_tween_count += 1
	var tween := create_tween()
	tween.tween_property(button, "modulate", color, 0.05)
	tween.tween_property(button, "modulate", Color.WHITE, 0.16)


func _play_place_sound() -> void:
	_request_haptic("place")
	_play_sfx(PLACE_SFX, 1.0)


func _play_flip_sound(index: int) -> void:
	_request_haptic("flip")
	_play_sfx(FLIP_SFX, flip_pitch(index))


func _play_big_flip_sound(flip_count: int) -> void:
	_request_haptic("big_flip")
	_play_sfx(BIG_FLIP_SFX, big_flip_pitch(flip_count))


# flip.wav/big_flip.wav 는 sweep 없는 순수 톤(각 520Hz·270Hz). pitch_scale 로 base frequency 를 조정해
# 뒤집힌 순서(index)·개수(flip_count)에 따라 음이 조금씩 올라간다. static 순수함수라 회귀 테스트가 쉽다.
static func flip_pitch(index: int) -> float:
	return (520.0 + float(index) * 22.0) / 520.0


static func big_flip_pitch(flip_count: int) -> float:
	return (270.0 + float(flip_count) * 10.0) / 270.0


static func flip_wave_delay(origin: Dictionary, cell: Dictionary) -> float:
	var dx := float(int(cell.get("x", 0)) - int(origin.get("x", 0)))
	var dy := float(int(cell.get("y", 0)) - int(origin.get("y", 0)))
	return Vector2(dx, dy).length() * FLIP_WAVE_SECONDS_PER_CELL


static func flip_tilt(index: int) -> float:
	return FLIP_TILT_RADIANS if index % 2 == 0 else -FLIP_TILT_RADIANS


static func flip_transition_profile(index: int) -> Dictionary:
	return {
		"front_scale": FLIP_EDGE_SCALE,
		"back_scale": Vector2(-FLIP_EDGE_SCALE.x, FLIP_EDGE_SCALE.y),
		"tilt": flip_tilt(index),
		"highlight": FLIP_HIGHLIGHT_COLOR,
		"swap_alpha": FLIP_SWAP_ALPHA,
	}


static func big_flip_sound_delay(origin: Dictionary, flipped: Array) -> float:
	var first_wave_delay := INF
	for flipped_value in flipped:
		var flipped_cell: Dictionary = flipped_value
		first_wave_delay = minf(first_wave_delay, flip_wave_delay(origin, flipped_cell))
	return first_wave_delay + FLIP_HALF_DURATION


static func haptic_profile(kind: String) -> Dictionary:
	match kind:
		"place":
			return {"duration_ms": 18, "amplitude": 0.35}
		"flip":
			return {"duration_ms": 26, "amplitude": 0.48}
		"big_flip":
			return {"duration_ms": 55, "amplitude": 0.82}
		"game_over":
			return {"duration_ms": 80, "amplitude": 0.72}
		_:
			return {}


func _request_haptic(kind: String) -> bool:
	if !bool(_current_settings().get("haptic", true)):
		return false
	var profile := haptic_profile(kind)
	if profile.is_empty():
		return false
	var duration_ms := int(profile["duration_ms"])
	var amplitude := float(profile["amplitude"])
	if _haptic_probe.is_valid():
		_haptic_probe.call(kind, duration_ms, amplitude)
		return true
	if !OS.has_feature("android") and !OS.has_feature("ios") and !OS.has_feature("web"):
		return false
	Input.vibrate_handheld(duration_ms, amplitude)
	return true


func _play_sfx(stream: AudioStream, pitch: float) -> void:
	# AudioStreamGenerator(런타임 실시간 합성)는 iOS 실기기에서 소리가 나지 않아,
	# 동일한 톤을 미리 구운 .wav(scripts/generate_sfx.py) 를 AudioStreamPlayer 로 재생한다.
	if !bool(_current_settings().get("sound", true)):
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = -5.0
	add_child(player)
	player.play()
	player.finished.connect(func() -> void:
		if is_instance_valid(player):
			player.queue_free()
	)


# safe area(물리 픽셀)를 게임 viewport 좌표의 좌/상/우/하 여백으로 환산한다.
# X·Y 각각의 stretch 스케일(vp/win)을 써서 가로/세로 비율이 달라도 정확하고, 좌우 노치(가로 방향)도 반영한다.
# 데스크톱/웹에서는 safe area 가 전체 창이라 네 값 모두 0 이다. static 순수함수라 회귀 테스트가 쉽다.
static func compute_safe_area_margins(safe: Rect2i, win: Vector2i, vp: Vector2) -> Dictionary:
	if win.x <= 0 or win.y <= 0:
		return {"left": 0.0, "top": 0.0, "right": 0.0, "bottom": 0.0}
	var sx: float = vp.x / float(win.x)
	var sy: float = vp.y / float(win.y)
	return {
		"left": maxf(float(safe.position.x) * sx, 0.0),
		"top": maxf(float(safe.position.y) * sy, 0.0),
		"right": maxf(float(win.x - (safe.position.x + safe.size.x)) * sx, 0.0),
		"bottom": maxf(float(win.y - (safe.position.y + safe.size.y)) * sy, 0.0),
	}


func _safe_area_margins() -> Dictionary:
	return compute_safe_area_margins(
		DisplayServer.get_display_safe_area(),
		DisplayServer.window_get_size(),
		get_viewport().get_visible_rect().size
	)


func _update_mode_buttons() -> void:
	if black_button == null or white_button == null:
		return
	black_button.button_pressed = player_stone == ReversiEngine.BLACK
	white_button.button_pressed = player_stone == ReversiEngine.WHITE
	_apply_segment_style(black_button, black_button.button_pressed)
	_apply_segment_style(white_button, white_button.button_pressed)


func _update_settings_choice_buttons() -> void:
	_update_choice_buttons(difficulty_buttons, difficulty)
	_update_choice_buttons(board_size_buttons, str(_current_board_size()))
	_update_choice_buttons(board_theme_buttons, _current_theme_id())
	_update_choice_buttons(stone_theme_buttons, _current_stone_theme_id())
	_update_choice_buttons(locale_buttons, _current_locale_id())
	_update_choice_buttons(font_scale_buttons, _current_font_scale_id())


func _update_choice_buttons(button_entries: Array, selected_id: String) -> void:
	for entry in button_entries:
		var button := entry.get("button") as Button
		if button == null:
			continue
		var active := str(entry.get("id", "")) == selected_id
		button.button_pressed = active
		_apply_segment_style(button, active)


func _apply_segment_style(button: Button, active: bool) -> void:
	var bg := _theme_color("accent") if active else _theme_color("hud")
	var fg := Color(0.055, 0.048, 0.025, 1.0) if active else _theme_color("text_primary")
	button.add_theme_stylebox_override("normal", _make_style(bg, 1, Color(1, 1, 1, 0.13), 6))
	button.add_theme_stylebox_override("hover", _make_style(bg.lightened(0.08), 1, Color(1, 1, 1, 0.22), 6))
	button.add_theme_stylebox_override("pressed", _make_style(bg.darkened(0.08), 1, Color(0, 0, 0, 0.22), 6))
	button.add_theme_color_override("font_color", fg)
	button.add_theme_color_override("font_hover_color", fg)
	button.add_theme_color_override("font_pressed_color", fg)
	_apply_text_visibility(button, 1, fg)


func _update_turn_badge(current_turn: int) -> void:
	if current_turn == player_stone:
		turn_badge.add_theme_stylebox_override("normal", _make_style(_theme_color("accent"), 1, Color(1, 1, 1, 0.2), 8))
		turn_badge.add_theme_color_override("font_color", Color(0.06, 0.055, 0.035, 1.0))
		_apply_text_visibility(turn_badge, 1, Color(0.06, 0.055, 0.035, 1.0))
	elif current_turn == ReversiEngine.NONE:
		turn_badge.add_theme_stylebox_override("normal", _make_style(_theme_color("hud"), 1, Color(1, 1, 1, 0.13), 8))
		turn_badge.add_theme_color_override("font_color", _theme_color("text_primary"))
		_apply_text_visibility(turn_badge, 1, _theme_color("text_primary"))
	else:
		turn_badge.add_theme_stylebox_override("normal", _make_style(_theme_color("success"), 1, Color(1, 1, 1, 0.16), 8))
		turn_badge.add_theme_color_override("font_color", Color(0.02, 0.05, 0.03, 1.0))
		_apply_text_visibility(turn_badge, 1, Color(0.02, 0.05, 0.03, 1.0))


func _update_result_overlay(persist_stats: bool = true) -> void:
	var counts := ReversiEngine.count_pieces(state.get("board", []))
	var black_score := int(counts["black"])
	var white_score := int(counts["white"])
	var winner := int(state.get("winner", ReversiEngine.NONE))
	var result_kind := ""
	if winner == player_stone:
		result_kind = "win"
		result_title_label.text = _t("result_win")
		result_title_label.add_theme_color_override("font_color", _theme_color("accent"))
		_apply_text_visibility(result_title_label, 3, _theme_color("accent"))
	elif winner == ReversiEngine.NONE:
		result_kind = "draw"
		result_title_label.text = _t("result_draw")
		result_title_label.add_theme_color_override("font_color", _theme_color("text_primary"))
		_apply_text_visibility(result_title_label, 3, _theme_color("text_primary"))
	else:
		result_kind = "lose"
		result_title_label.text = _t("result_lose")
		result_title_label.add_theme_color_override("font_color", _theme_color("danger"))
		_apply_text_visibility(result_title_label, 3, _theme_color("danger"))
	result_score_label.text = "%d : %d" % [
		black_score if player_stone == ReversiEngine.BLACK else white_score,
		white_score if player_stone == ReversiEngine.BLACK else black_score,
	]
	result_detail_label.text = _t("result_detail") % [black_score, white_score]
	_show_result_overlay(winner)
	# game_over 는 광고와 같은 1회 가드 안에서만 전송한다.
	# (오버레이는 게임 종료 후 입력·AI턴 진입마다 재호출되므로 밖에 두면 중복 집계된다.)
	if not _interstitial_shown_this_game:
		_interstitial_shown_this_game = true
		ReversiEngine.record_game_result(state, result_kind)
		_request_haptic("game_over")
		if persist_stats:
			_save_state()
		if analytics != null:
			analytics.on_game_over(
				result_kind,
				black_score if player_stone == ReversiEngine.BLACK else white_score,
				white_score if player_stone == ReversiEngine.BLACK else black_score,
				difficulty,
				state.get("move_history", []).size(),
			)
		_request_interstitial_ad()
	result_stats_label.text = _current_difficulty_stats_text()


func _show_result_overlay(winner: int) -> void:
	result_overlay.visible = true
	var has_winner := winner == ReversiEngine.BLACK or winner == ReversiEngine.WHITE
	result_winner_stone_view.visible = has_winner
	result_winner_stone_view.texture = _texture_for_stone(winner) if has_winner else null
	if _result_animation_played_this_game:
		return
	_result_animation_played_this_game = true

	result_overlay.modulate = Color.WHITE
	result_panel.scale = Vector2.ONE
	result_winner_stone_view.scale = Vector2.ONE
	if _reduce_motion_enabled():
		return

	result_overlay.modulate.a = 0.0
	result_panel.scale = Vector2(0.86, 0.86)
	_motion_tween_count += 1
	_result_entry_animation_count += 1
	var entry_tween := create_tween()
	entry_tween.set_parallel(true)
	entry_tween.tween_property(
		result_overlay,
		"modulate:a",
		1.0,
		0.18,
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	entry_tween.tween_property(
		result_panel,
		"scale",
		Vector2.ONE,
		0.28,
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if !has_winner:
		return
	result_winner_stone_view.scale = Vector2(0.72, 0.72)
	_motion_tween_count += 1
	_winner_emphasis_animation_count += 1
	var winner_tween := create_tween()
	winner_tween.tween_interval(0.10)
	winner_tween.tween_property(
		result_winner_stone_view,
		"scale",
		Vector2(1.16, 1.16),
		0.18,
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	winner_tween.tween_property(
		result_winner_stone_view,
		"scale",
		Vector2.ONE,
		0.16,
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _current_difficulty_stats_text() -> String:
	var stats := ReversiEngine.normalize_stats(state.get("stats", {}))
	var current_difficulty := str(state.get("difficulty", difficulty))
	var bucket: Dictionary = stats.get(current_difficulty, {})
	return _t("stats_summary") % [
		_difficulty_label(current_difficulty),
		int(bucket.get("wins", 0)),
		int(bucket.get("draws", 0)),
		int(bucket.get("losses", 0)),
	]


func _request_interstitial_ad() -> void:
	# 게임 종료 시 마켓별 전면(Interstitial) 광고를 요청한다. 게임당 1회(_interstitial_shown_this_game).
	# - AIT(web export): wrapper가 노출한 전역 객체(window.__aitBridge) 메서드를 직접 호출.
	#   AppsInToss 보안 정책상 JavaScriptBridge.eval(외부 코드 문자열 실행)은 금지되므로 eval을 쓰지 않는다.
	# - App Store(iOS): AdMob 어댑터(ios_ads.gd)로 전면광고 표시. 비맞춤형·IDFA 미사용.
	# - Google Play(Android): 현재 광고 미탑재(릴리스 빌드 인프라만) → no-op.
	if _interstitial_probe.is_valid():
		_interstitial_probe.call()
	if OS.has_feature("web"):
		var bridge: JavaScriptObject = JavaScriptBridge.get_interface("__aitBridge")
		if bridge != null:
			bridge.showInterstitialAd()
		return
	if OS.has_feature("ios") and _ios_ads != null:
		_ios_ads.show_interstitial()


func _status_text() -> String:
	if bool(state.get("game_over", false)):
		return _t("status_game_over")
	if input_locked:
		return _t("status_flip")
	if ai_move_pending:
		return _t("status_ai_thinking")
	if bool(state.get("last_turn_was_pass", false)):
		return _t("status_pass")
	if int(state.get("current_turn", ReversiEngine.NONE)) == player_stone:
		return _t("status_your_move")
	return _t("status_ai_turn")


func _turn_text(current_turn: int) -> String:
	if current_turn == ReversiEngine.NONE:
		return _t("turn_final")
	if current_turn == player_stone:
		return _t("turn_player")
	return _t("turn_ai")


func _difficulty_index() -> int:
	match difficulty:
		"EASY":
			return 0
		"HARD":
			return 2
		_:
			return 1


func _is_valid_cell(valid_moves: Array, x: int, y: int) -> bool:
	for move in valid_moves:
		if int(move["x"]) == x and int(move["y"]) == y:
			return true
	return false


func _is_last_move(x: int, y: int) -> bool:
	var last_move: Dictionary = state.get("last_move", {})
	if last_move.is_empty():
		return false
	return int(last_move.get("x", -1)) == x and int(last_move.get("y", -1)) == y


func _last_move_text() -> String:
	var last_move: Dictionary = state.get("last_move", {})
	if last_move.is_empty():
		return "--"
	return "%d,%d" % [int(last_move.get("x", 0)) + 1, int(last_move.get("y", 0)) + 1]


func _advantage_text(player_score: int, ai_score: int) -> String:
	var diff := player_score - ai_score
	if diff > 0:
		return _t("focus_player_leads") % diff
	if diff < 0:
		return _t("focus_ai_leads") % abs(diff)
	return _t("focus_even")


func _make_ui_theme() -> Theme:
	var ui_theme := Theme.new()
	var ui_font := FontVariation.new()
	ui_font.base_font = UI_FONT
	ui_font.set_fallbacks([JAPANESE_FONT])
	ui_theme.default_font = ui_font
	ui_theme.default_font_size = _font_size(17)
	for theme_type in ["Label", "Button", "CheckButton"]:
		ui_theme.set_color("font_outline_color", theme_type, Color(0.0, 0.0, 0.0, 0.58))
		ui_theme.set_constant("outline_size", theme_type, 1)
	return ui_theme


func _apply_text_visibility(control: Control, outline_size: int, font_color: Color) -> void:
	control.add_theme_color_override("font_outline_color", _outline_color_for(font_color))
	control.add_theme_constant_override("outline_size", outline_size)


func _outline_color_for(font_color: Color) -> Color:
	var luminance := font_color.r * 0.299 + font_color.g * 0.587 + font_color.b * 0.114
	if luminance < 0.42:
		return Color(1.0, 1.0, 1.0, 0.22)
	return Color(0.0, 0.0, 0.0, 0.62)


func _current_settings() -> Dictionary:
	var defaults := ReversiEngine.default_settings()
	var current: Dictionary = state.get("settings", {})
	return ReversiEngine.normalize_settings(current.merged(defaults, false))


func _current_board_size() -> int:
	var board: Array = state.get("board", [])
	var board_size := ReversiEngine.get_board_size(board)
	if board_size > 0:
		return board_size
	return ReversiEngine.normalize_board_size(
		int(_current_settings().get("board_size", ReversiEngine.DEFAULT_BOARD_SIZE))
	)


func _current_font_scale() -> float:
	var configured := float(_current_settings().get("font_scale", 1.0))
	for scale_id in FONT_SCALE_IDS:
		var allowed := str(scale_id).to_float()
		if is_equal_approx(configured, allowed):
			return allowed
	return 1.0


func _current_font_scale_id() -> String:
	var configured := _current_font_scale()
	for scale_id in FONT_SCALE_IDS:
		if is_equal_approx(configured, str(scale_id).to_float()):
			return str(scale_id)
	return "1.0"


func _font_size(base_size: int) -> int:
	return maxi(1, int(roundi(float(base_size) * _current_font_scale())))


func _reduce_motion_enabled() -> bool:
	return bool(_current_settings().get("reduce_motion", false))


func _show_moves_enabled() -> bool:
	return bool(_current_settings().get("show_moves", true))


func _apply_preferences_to_state() -> void:
	preferences = ReversiEngine.normalize_preferences(preferences, _device_default_locale())
	difficulty = str(preferences.get("difficulty", "MEDIUM"))
	state["difficulty"] = difficulty
	var preferred_settings := ReversiEngine.normalize_settings(
		preferences.get("settings", ReversiEngine.default_settings())
	)
	preferred_settings["board_size"] = ReversiEngine.get_board_size(
		state.get("board", []),
	)
	state["settings"] = preferred_settings
	preferences["settings"] = preferred_settings.duplicate(true)


func _sync_preferences_from_state() -> void:
	preferences = ReversiEngine.normalize_preferences({
		"version": 1,
		"difficulty": difficulty,
		"settings": _current_settings(),
	}, _device_default_locale())


func _device_default_locale() -> String:
	# 최초 실행 시 지원하는 기기 로케일을 선택하고, 그 외에는 영어로 돌아간다.
	# 헤드리스(스모크 테스트/CI)에는 UI가 없고 테스트가 한글 UI를 전제하므로 ko 로 고정한다.
	if DisplayServer.get_name() == "headless":
		return "ko"
	return locale_id_from_device_locale(OS.get_locale())


static func locale_id_from_device_locale(device_locale: String) -> String:
	var normalized := device_locale.strip_edges().to_lower().replace("-", "_")
	if normalized.begins_with("ko"):
		return "ko"
	if normalized.begins_with("ja"):
		return "ja"
	return "en"


func _current_locale_id() -> String:
	var locale_id := str(_current_settings().get("locale", "ko"))
	if LOCALE_IDS.has(locale_id):
		return locale_id
	return "ko"


func _locale_index() -> int:
	var locale_id := _current_locale_id()
	for index in range(LOCALE_IDS.size()):
		if str(LOCALE_IDS[index]) == locale_id:
			return index
	return 0


func _set_difficulty_from_choice(difficulty_id: String) -> void:
	if !DIFFICULTY_IDS.has(difficulty_id):
		return
	difficulty = difficulty_id
	state["difficulty"] = difficulty
	if analytics != null:
		analytics.on_settings_changed("difficulty", difficulty)
	_save_preferences()
	_render()
	call_deferred("_maybe_play_ai_turn")


func _set_board_size_from_choice(board_size_id: String) -> void:
	if !BOARD_SIZE_IDS.has(board_size_id):
		return
	var board_size := ReversiEngine.normalize_board_size(board_size_id.to_int())
	if board_size == _current_board_size():
		_update_settings_choice_buttons()
		return
	var keep_settings_open := settings_overlay != null and settings_overlay.visible
	var settings := _current_settings()
	settings["board_size"] = board_size
	state["settings"] = settings
	if analytics != null:
		analytics.on_settings_changed("board_size", str(board_size))
	_save_preferences()
	_start_new_game(player_stone)
	if keep_settings_open:
		_show_settings_menu()


func _set_font_scale_from_choice(scale_id: String) -> void:
	if !FONT_SCALE_IDS.has(scale_id):
		return
	var keep_settings_open := settings_overlay != null and settings_overlay.visible
	var settings := _current_settings()
	settings["font_scale"] = scale_id.to_float()
	state["settings"] = settings
	if analytics != null:
		analytics.on_settings_changed("font_scale", scale_id)
	_save_preferences()
	_build_ui()
	_render()
	if keep_settings_open:
		_show_settings_menu()


func _set_locale(locale_id: String, persist: bool = true) -> void:
	if !LOCALE_IDS.has(locale_id):
		return
	var keep_settings_open := settings_overlay != null and settings_overlay.visible
	var settings := _current_settings()
	settings["locale"] = locale_id
	state["settings"] = settings
	if persist:
		if analytics != null:
			analytics.on_settings_changed("locale", locale_id)
		_save_preferences()
	_build_ui()
	_render()
	if keep_settings_open:
		_show_settings_menu()


func _t(key: String) -> String:
	var locale_texts: Dictionary = TEXT.get(_current_locale_id(), TEXT["ko"])
	return resolve_localized_text(key, locale_texts, TEXT["ko"])


static func resolve_localized_text(
	key: String,
	locale_texts: Dictionary,
	fallback_texts: Dictionary,
) -> String:
	if locale_texts.has(key):
		return str(locale_texts[key])
	if fallback_texts.has(key):
		return str(fallback_texts[key])
	return key


func _piece_label(stone: int) -> String:
	match stone:
		ReversiEngine.BLACK:
			return _t("black")
		ReversiEngine.WHITE:
			return _t("white")
		_:
			return _t("none")


func _difficulty_label(difficulty_id: String) -> String:
	match difficulty_id:
		"EASY":
			return _t("easy")
		"HARD":
			return _t("hard")
		_:
			return _t("medium")


func _theme_display_label(theme_id: String) -> String:
	return _t("theme_%s" % theme_id)


func _current_theme_id() -> String:
	var theme_id := str(_current_settings().get("theme", "classic"))
	if THEME_IDS.has(theme_id):
		return theme_id
	return "classic"


func _theme_index() -> int:
	var theme_id := _current_theme_id()
	for index in range(THEME_IDS.size()):
		if str(THEME_IDS[index]) == theme_id:
			return index
	return 0


func _theme_label() -> String:
	return _theme_display_label(_current_theme_id())


func _current_stone_theme_id() -> String:
	var theme_id := str(_current_settings().get("stone_theme", "classic"))
	if STONE_THEME_IDS.has(theme_id):
		return theme_id
	return "classic"


func _stone_theme_index() -> int:
	var theme_id := _current_stone_theme_id()
	for index in range(STONE_THEME_IDS.size()):
		if str(STONE_THEME_IDS[index]) == theme_id:
			return index
	return 0


func _stone_theme_label() -> String:
	return _theme_display_label(_current_stone_theme_id())


func _set_theme(theme_id: String, persist: bool = true) -> void:
	if !THEME_IDS.has(theme_id):
		return
	var keep_settings_open := settings_overlay != null and settings_overlay.visible
	var settings := _current_settings()
	settings["theme"] = theme_id
	state["settings"] = settings
	if persist:
		if analytics != null:
			analytics.on_settings_changed("theme", theme_id)
		_save_preferences()
	_build_ui()
	_render()
	if keep_settings_open:
		_show_settings_menu()


func _set_stone_theme(theme_id: String, persist: bool = true) -> void:
	if !STONE_THEME_IDS.has(theme_id):
		return
	var keep_settings_open := settings_overlay != null and settings_overlay.visible
	var settings := _current_settings()
	settings["stone_theme"] = theme_id
	state["settings"] = settings
	if persist:
		if analytics != null:
			analytics.on_settings_changed("stone_theme", theme_id)
		_save_preferences()
	_build_ui()
	_render()
	if keep_settings_open:
		_show_settings_menu()


func _theme_config(theme_id: String = "") -> Dictionary:
	var id := theme_id
	if id.is_empty():
		id = _current_theme_id()

	match id:
		"arctic":
			return {
				"bg": Color(0.018, 0.034, 0.052, 1.0),
				"hud": Color(0.055, 0.095, 0.125, 1.0),
				"hud_dark": Color(0.032, 0.055, 0.08, 1.0),
				"board_frame": Color(0.0, 0.045, 0.078, 1.0),
				"board_frame_border": Color(0.22, 0.72, 0.86, 0.45),
				"board_surface": Color(0.055, 0.42, 0.48, 1.0),
				"board_grid": Color(0.008, 0.11, 0.15, 0.92),
				"meter_bg": Color(0.01, 0.03, 0.052, 1.0),
				"text_primary": Color(0.94, 0.99, 1.0, 1.0),
				"text_muted": Color(0.76, 0.90, 0.96, 1.0),
				"accent": Color(0.48, 0.91, 1.0, 1.0),
				"danger": DANGER,
				"success": Color(0.38, 0.95, 0.68, 1.0),
				"hint": Color(0.50, 0.92, 1.0, 0.90),
				"hint_border": Color(0.86, 1.0, 1.0, 0.68),
			}
		"ember":
			return {
				"bg": Color(0.045, 0.031, 0.024, 1.0),
				"hud": Color(0.135, 0.09, 0.055, 1.0),
				"hud_dark": Color(0.075, 0.047, 0.032, 1.0),
				"board_frame": Color(0.045, 0.022, 0.012, 1.0),
				"board_frame_border": Color(0.76, 0.36, 0.12, 0.45),
				"board_surface": Color(0.31, 0.34, 0.15, 1.0),
				"board_grid": Color(0.10, 0.085, 0.035, 0.92),
				"meter_bg": Color(0.045, 0.024, 0.016, 1.0),
				"text_primary": Color(1.0, 0.96, 0.86, 1.0),
				"text_muted": Color(0.90, 0.76, 0.60, 1.0),
				"accent": Color(1.0, 0.56, 0.20, 1.0),
				"danger": DANGER,
				"success": Color(0.58, 0.86, 0.42, 1.0),
				"hint": Color(1.0, 0.58, 0.20, 0.92),
				"hint_border": Color(1.0, 0.86, 0.55, 0.62),
			}
		_:
			return {
				"bg": BG_COLOR,
				"hud": HUD_COLOR,
				"hud_dark": HUD_DARK,
				"board_frame": Color(0.12, 0.055, 0.025, 1.0),
				"board_frame_border": Color(0.58, 0.28, 0.10, 0.78),
				"board_surface": Color(0.045, 0.45, 0.22, 1.0),
				"board_grid": Color(0.012, 0.105, 0.045, 0.94),
				"meter_bg": Color(0.015, 0.02, 0.035, 1.0),
				"text_primary": TEXT_PRIMARY,
				"text_muted": TEXT_MUTED,
				"accent": ACCENT,
				"danger": DANGER,
				"success": SUCCESS,
				"hint": Color(1.0, 0.82, 0.18, 0.92),
				"hint_border": Color(1.0, 0.95, 0.68, 0.58),
			}


func _theme_color(key: String) -> Color:
	var value = _theme_config().get(key, Color.WHITE)
	if typeof(value) == TYPE_COLOR:
		return value
	return Color.WHITE


func _stone_theme_config(theme_id: String = "") -> Dictionary:
	var id := theme_id
	if id.is_empty():
		id = _current_stone_theme_id()

	match id:
		"arctic":
			return {
				"black_texture": ARCTIC_BLACK_TEXTURE,
				"white_texture": ARCTIC_WHITE_TEXTURE,
				"black_meter": Color(0.05, 0.12, 0.18, 1.0),
				"white_meter": Color(0.86, 0.98, 1.0, 1.0),
			}
		"ember":
			return {
				"black_texture": EMBER_BLACK_TEXTURE,
				"white_texture": EMBER_WHITE_TEXTURE,
				"black_meter": Color(0.16, 0.08, 0.045, 1.0),
				"white_meter": Color(0.98, 0.87, 0.63, 1.0),
			}
		_:
			return {
				"black_texture": CLASSIC_BLACK_TEXTURE,
				"white_texture": CLASSIC_WHITE_TEXTURE,
				"black_meter": Color(0.12, 0.13, 0.15, 1.0),
				"white_meter": Color(0.95, 0.96, 0.94, 1.0),
			}


func _stone_theme_color(key: String) -> Color:
	var value = _stone_theme_config().get(key, Color.WHITE)
	if typeof(value) == TYPE_COLOR:
		return value
	return Color.WHITE


func _stone_theme_texture(key: String) -> Texture2D:
	return _stone_theme_config().get(key, CLASSIC_BLACK_TEXTURE) as Texture2D


func _texture_for_stone(stone: int) -> Texture2D:
	if stone == ReversiEngine.WHITE:
		return _stone_theme_texture("white_texture")
	return _stone_theme_texture("black_texture")


func _make_style(bg: Color, border_width: int = 0, border_color: Color = Color.TRANSPARENT, radius: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	return style


func _save_state() -> void:
	state["last_saved_at"] = int(Time.get_unix_time_from_system())
	var file := FileAccess.open(_save_path, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open save file for writing.")
		return
	file.store_string(JSON.stringify(ReversiEngine.state_to_save_dict(state)))


func _load_state() -> Dictionary:
	var parsed := _read_json_dictionary(_save_path)
	if parsed.is_empty():
		return {}

	var restored := ReversiEngine.state_from_save_dict(parsed)
	if restored.is_empty():
		return {}
	return restored


func _save_preferences() -> void:
	_sync_preferences_from_state()
	_write_preferences()


func _write_preferences() -> void:
	var file := FileAccess.open(_prefs_path, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open preferences file for writing.")
		return
	file.store_string(JSON.stringify(preferences))


func _load_preferences() -> Dictionary:
	var parsed := _read_json_dictionary(_prefs_path)
	if parsed.is_empty() or int(parsed.get("version", 0)) != 1:
		return {}
	return ReversiEngine.normalize_preferences(parsed, _device_default_locale())


func _load_legacy_preferences() -> Dictionary:
	var parsed := _read_json_dictionary(_save_path)
	return ReversiEngine.preferences_from_legacy_save(parsed, _device_default_locale())


func _read_json_dictionary(path: String) -> Dictionary:
	if !FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return {}
	return parser.data


func _load_or_create_preferences() -> Dictionary:
	var loaded := _load_preferences()
	if !loaded.is_empty():
		return loaded
	var initial := _load_legacy_preferences()
	if initial.is_empty():
		initial = ReversiEngine.default_preferences(_device_default_locale())
	preferences = initial
	_write_preferences()
	return preferences
