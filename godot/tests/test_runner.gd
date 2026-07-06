extends Node

const ReversiEngine = preload("res://scripts/reversi_engine.gd")
const ReversiAnalytics = preload("res://scripts/analytics.gd")
const GA4Sender = preload("res://scripts/ga4_mp_sender.gd")


# analytics 어댑터 포워딩 검증용 프로브(sender 자리에 주입).
class _AnalyticsProbe:
	extends Node
	var sent: Array = []
	func send(event_name: String, params: Dictionary) -> void:
		sent.append({"name": event_name, "params": params})


func _ready() -> void:
	var ok := true
	ok = _test_main_scene_exists() and ok
	ok = _test_initial_valid_moves() and ok
	ok = _test_first_move_flip() and ok
	ok = _test_pass_turn_fixture() and ok
	ok = _test_game_over_full_board() and ok
	ok = _test_codec_round_trip() and ok
	ok = _test_save_round_trip() and ok
	var i18n_ok := await _test_i18n_defaults_and_locale_switch()
	ok = i18n_ok and ok
	var settings_menu_ok := await _test_settings_menu_keeps_playfield_focused()
	ok = settings_menu_ok and ok
	var theme_ok := await _test_visual_theme_switches_are_independent()
	ok = theme_ok and ok
	var ui_ok := await _test_ui_hints_return_after_animation()
	ok = ui_ok and ok
	ok = _test_ga4_disabled_in_headless() and ok
	ok = _test_ga4_build_event() and ok
	ok = _test_ga4_batching() and ok
	ok = _test_ga4_config_validation() and ok
	ok = _test_ga4_client_id_persists() and ok
	ok = _test_analytics_adapter_headless_noop() and ok
	get_tree().quit(0 if ok else 1)


func _test_main_scene_exists() -> bool:
	var main_scene: String = str(ProjectSettings.get_setting("application/run/main_scene", ""))
	return _assert(!main_scene.is_empty(), "main scene configured") and _assert(ResourceLoader.exists(main_scene), "main scene exists")


func _test_initial_valid_moves() -> bool:
	var state := ReversiEngine.create_new_game()
	var expected := [{"x": 2, "y": 3}, {"x": 3, "y": 2}, {"x": 4, "y": 5}, {"x": 5, "y": 4}]
	return _assert(_moves_equal(state["valid_moves"], expected), "initial BLACK valid moves")


func _test_first_move_flip() -> bool:
	var state := ReversiEngine.create_new_game()
	var result := ReversiEngine.play_move(state, 2, 3)
	var counts := ReversiEngine.count_pieces(state["board"])
	var expected_white := [{"x": 2, "y": 2}, {"x": 2, "y": 4}, {"x": 4, "y": 2}]
	return (
		_assert(bool(result["ok"]), "first move accepted")
		and _assert(int(state["board"][3][3]) == ReversiEngine.BLACK, "first move flips 3,3")
		and _assert(result["flipped"].size() == 1, "first move flip count")
		and _assert(int(result["flipped"][0]["x"]) == 3 and int(result["flipped"][0]["y"]) == 3, "first move flip coordinate")
		and _assert(int(counts["black"]) == 4 and int(counts["white"]) == 1, "first move score")
		and _assert(_moves_equal(state["valid_moves"], expected_white), "WHITE valid moves after first move")
	)


func _test_pass_turn_fixture() -> bool:
	var board := _board_from_strings([
		"BBBWWWBB",
		"BWBBBWWB",
		"BBWWBWWB",
		"BBWBBBBB",
		"WBWWWWWW",
		"WBBW.WBW",
		"WBWWWWBW",
		".B.WBBBW",
	])
	var state := ReversiEngine.create_state_from_board(board, ReversiEngine.BLACK)
	var result := ReversiEngine.play_move(state, 7, 0)
	return (
		_assert(bool(result["ok"]), "pass fixture move accepted")
		and _assert(int(state["current_turn"]) == ReversiEngine.BLACK, "pass keeps turn on BLACK")
		and _assert(int(state["pass_count"]) == 1, "pass increments pass_count")
	)


func _test_game_over_full_board() -> bool:
	var board: Array = []
	for _x in range(ReversiEngine.BOARD_SIZE):
		var row: Array = []
		for _y in range(ReversiEngine.BOARD_SIZE):
			row.append(ReversiEngine.BLACK)
		board.append(row)
	var state := ReversiEngine.create_state_from_board(board, ReversiEngine.BLACK)
	return _assert(bool(state["game_over"]), "full board game over") and _assert(int(state["winner"]) == ReversiEngine.BLACK, "full board winner")


func _test_codec_round_trip() -> bool:
	var state := ReversiEngine.create_new_game()
	var payload := ReversiEngine.encode_board_payload(state["board"], int(state["current_turn"]), state["valid_moves"])
	var decoded := ReversiEngine.decode_board_payload(payload)
	var encoded_again := ReversiEngine.encode_board_payload(decoded["board"], int(decoded["current_turn"]), decoded["valid_moves"])
	var expected_rows := PackedInt32Array([0x0000, 0x0000, 0x0300, 0x0e40, 0x01b0, 0x00c0, 0x0000, 0x0000])
	var rows_ok := true
	for index in range(expected_rows.size()):
		rows_ok = rows_ok and _read_u16(payload, index * 2) == expected_rows[index]
	return (
		_assert(payload.size() == 18, "codec payload is 18 bytes")
		and _assert(rows_ok, "initial codec row fixture")
		and _assert(payload == encoded_again, "codec round trip")
	)


func _test_save_round_trip() -> bool:
	var state := ReversiEngine.create_new_game(ReversiEngine.WHITE, "HARD")
	ReversiEngine.play_move(state, 2, 3)
	var saved := ReversiEngine.state_to_save_dict(state)
	var restored := ReversiEngine.state_from_save_dict(saved)
	return (
		_assert(!restored.is_empty(), "save restores")
		and _assert(int(restored["player_stone"]) == ReversiEngine.WHITE, "save player stone")
		and _assert(str(restored["difficulty"]) == "HARD", "save difficulty")
		and _assert(restored["move_history"].size() == 1, "save move history")
	)


func _test_ui_hints_return_after_animation() -> bool:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame

	main.ai_move_pending = false
	main.input_locked = false
	main.player_stone = ReversiEngine.BLACK
	main.difficulty = "MEDIUM"
	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	var settings: Dictionary = main.state.get("settings", {})
	settings["sound"] = false
	main.state["settings"] = settings
	main._sync_identity_labels()
	main._render()
	await get_tree().process_frame
	var player_result := ReversiEngine.play_move(main.state, 2, 3)
	if !bool(player_result["ok"]):
		main.queue_free()
		return _assert(false, "ui setup player move accepted")

	var ai_move := ReversiEngine.choose_ai_move(main.state)
	if ai_move.is_empty():
		main.queue_free()
		return _assert(false, "ui setup ai move exists")

	var before_board := ReversiEngine.clone_board(main.state["board"])
	var ai_result := ReversiEngine.play_move(main.state, int(ai_move["x"]), int(ai_move["y"]))
	await main._render_with_animation(before_board, ai_result)
	await get_tree().process_frame

	var expected_hints := int(main.state.get("valid_moves", []).size())
	var visible_hints := _visible_hint_count(main)
	var ghost_stones := _visible_hint_piece_texture_count(main)
	var unlocked := !bool(main.input_locked)
	main.queue_free()
	return (
		_assert(unlocked, "ui unlocks after move animation")
		and _assert(expected_hints > 0, "ui has valid player moves after ai")
		and _assert(visible_hints == expected_hints, "ui valid hints return after animation")
		and _assert(ghost_stones == 0, "ui valid hints do not draw ghost stones")
	)


func _test_i18n_defaults_and_locale_switch() -> bool:
	var state := ReversiEngine.create_new_game()
	var default_settings: Dictionary = state.get("settings", {})
	var default_locale_ok := str(default_settings.get("locale", "")) == "ko"

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame

	main.ai_move_pending = false
	main.input_locked = false
	main.player_stone = ReversiEngine.BLACK
	main.difficulty = "MEDIUM"
	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	main._render()
	await get_tree().process_frame

	var korean_default_ok: bool = main._current_locale_id() == "ko"
	var korean_label_ok: bool = main.black_button.text == "흑" and main._t("new_game") == "새 게임"
	var font_ok: bool = main.theme != null and main.theme.default_font != null
	var font_path_ok: bool = font_ok and str(main.theme.default_font.resource_path).ends_with("DoHyeon-Regular.ttf")
	var text_visibility_ok: bool = main.status_label.get_theme_constant("outline_size") >= 1 \
		and main.status_label.get_theme_color("font_outline_color").a > 0.0

	main._set_locale("en", false)
	await get_tree().process_frame

	var locale_settings: Dictionary = main.state.get("settings", {})
	var english_setting_ok: bool = str(locale_settings.get("locale", "")) == "en"
	var english_label_ok: bool = main.black_button.text == "BLACK" and main._t("new_game") == "NEW"
	var locale_buttons_ok: bool = _choice_group_has_active_id(main.locale_buttons, "en")
	main.queue_free()
	return (
		_assert(default_locale_ok, "i18n default locale is Korean")
		and _assert(korean_default_ok, "ui starts in Korean locale")
		and _assert(korean_label_ok, "ui renders Korean labels")
		and _assert(font_ok, "ui uses bundled font")
		and _assert(font_path_ok, "ui uses Do Hyeon bundled font")
		and _assert(text_visibility_ok, "ui text has visibility outline")
		and _assert(english_setting_ok, "ui locale setting changes")
		and _assert(english_label_ok, "ui renders English labels")
		and _assert(locale_buttons_ok, "ui locale buttons track selected locale")
	)


func _test_settings_menu_keeps_playfield_focused() -> bool:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame

	main.ai_move_pending = false
	main.input_locked = false
	main.player_stone = ReversiEngine.BLACK
	main.difficulty = "MEDIUM"
	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	main._render()
	await get_tree().process_frame

	var settings_hidden_ok: bool = main.settings_overlay != null and !main.settings_overlay.visible
	var settings_button_ok: bool = main.settings_button != null and main.settings_button.text == "설정"
	var strip_compact_ok: bool = main.gameplay_strip != null and main.gameplay_strip.custom_minimum_size.y <= 52
	var momentum_strip_full_width_ok: bool = main.gameplay_strip != null \
		and main.gameplay_strip.size_flags_horizontal == Control.SIZE_EXPAND_FILL \
		and main.gameplay_strip.custom_minimum_size.x == 0
	var play_controls_visible_ok: bool = main.black_button != null \
		and main.white_button != null \
		and main.new_game_button != null \
		and main.black_button.is_visible_in_tree() \
		and main.white_button.is_visible_in_tree() \
		and main.new_game_button.is_visible_in_tree()
	var play_controls_large_ok: bool = main.black_button.custom_minimum_size.x >= 112.0 \
		and main.white_button.custom_minimum_size.x >= 112.0 \
		and main.new_game_button.custom_minimum_size.x >= 172.0 \
		and main.black_button.custom_minimum_size.y >= 56.0 \
		and main.white_button.custom_minimum_size.y >= 56.0 \
		and main.new_game_button.custom_minimum_size.y >= 56.0
	var settings_controls_hidden_ok: bool = main.difficulty_buttons.size() == 3 \
		and main.board_theme_buttons.size() == 3 \
		and !_choice_group_first_button_visible(main.difficulty_buttons) \
		and !_choice_group_first_button_visible(main.board_theme_buttons)
	var no_select_box_ok: bool = !_visible_option_button_exists(main)
	var load_removed_ok: bool = main._t("load") == "load"
	var default_hint_setting_removed_ok: bool = !ReversiEngine.default_settings().has("highlight")
	var default_vibration_setting_removed_ok: bool = !ReversiEngine.default_settings().has("vibration")
	var sound_setting: Dictionary = main.state.get("settings", {})
	sound_setting["sound"] = false
	sound_setting["vibration"] = true
	main.state["settings"] = sound_setting
	var audio_players_before := _audio_player_count(main)
	main._play_place_sound()
	var sound_disabled_ok: bool = _audio_player_count(main) == audio_players_before
	var unsupported_setting_pruned_ok: bool = !main._current_settings().has("vibration")

	main._show_settings_menu()
	await get_tree().process_frame
	var menu_open_ok: bool = main.settings_overlay.visible \
		and _choice_group_first_button_visible(main.difficulty_buttons) \
		and _choice_group_first_button_visible(main.board_theme_buttons)
	var hint_toggle_removed_ok: bool = !_visible_button_text_exists(main.settings_overlay, "힌트") \
		and !_visible_button_text_exists(main.settings_overlay, "HINT")
	var vibration_toggle_removed_ok: bool = !_visible_button_text_exists(main.settings_overlay, "진동") \
		and !_visible_button_text_exists(main.settings_overlay, "VIBE")

	var panel_rect: Rect2 = main.settings_panel.get_global_rect()
	var inside_event := _make_left_click(panel_rect.get_center())
	main._on_settings_overlay_gui_input(inside_event)
	await get_tree().process_frame
	var inside_tap_keeps_open_ok: bool = main.settings_overlay.visible

	var outside_event := _make_left_click(Vector2(max(0.0, panel_rect.position.x - 24.0), panel_rect.position.y + 24.0))
	main._on_settings_overlay_gui_input(outside_event)
	await get_tree().process_frame
	var outside_tap_closes_ok: bool = !main.settings_overlay.visible

	main._hide_settings_menu()
	await get_tree().process_frame
	var menu_close_ok: bool = !main.settings_overlay.visible and !_choice_group_first_button_visible(main.difficulty_buttons)

	main.queue_free()
	return (
		_assert(settings_hidden_ok, "ui settings menu is hidden by default")
		and _assert(settings_button_ok, "ui exposes settings button")
		and _assert(strip_compact_ok, "ui keeps board momentum strip compact")
		and _assert(momentum_strip_full_width_ok, "ui expands board momentum strip horizontally")
		and _assert(play_controls_visible_ok, "ui keeps new game and stone controls on playfield")
		and _assert(play_controls_large_ok, "ui keeps primary play controls large enough")
		and _assert(settings_controls_hidden_ok, "ui hides settings controls from playfield")
		and _assert(no_select_box_ok, "ui removes mobile-unfriendly select boxes")
		and _assert(load_removed_ok, "ui removes redundant load action")
		and _assert(default_hint_setting_removed_ok, "ui removes hint setting default")
		and _assert(default_vibration_setting_removed_ok, "ui removes unsupported vibration setting default")
		and _assert(sound_disabled_ok, "ui sound setting suppresses move sound")
		and _assert(unsupported_setting_pruned_ok, "ui prunes unsupported saved vibration setting")
		and _assert(menu_open_ok, "ui settings menu reveals settings controls")
		and _assert(hint_toggle_removed_ok, "ui settings menu omits hint toggle")
		and _assert(vibration_toggle_removed_ok, "ui settings menu omits unsupported vibration toggle")
		and _assert(inside_tap_keeps_open_ok, "ui settings panel tap keeps menu open")
		and _assert(outside_tap_closes_ok, "ui settings background tap closes menu")
		and _assert(menu_close_ok, "ui settings menu closes")
	)


func _test_visual_theme_switches_are_independent() -> bool:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame

	main.ai_move_pending = false
	main.input_locked = false
	main.player_stone = ReversiEngine.BLACK
	main.difficulty = "MEDIUM"
	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	main._render()
	await get_tree().process_frame

	var classic_texture: Texture2D = main._texture_for_stone(ReversiEngine.BLACK)
	var classic_style := main.cell_buttons[0][0].get_theme_stylebox("normal") as StyleBoxFlat
	var classic_color := classic_style.bg_color

	main._set_theme("arctic", false)
	await get_tree().process_frame

	var board_only_texture: Texture2D = main._texture_for_stone(ReversiEngine.BLACK)
	var arctic_board_style := main.cell_buttons[0][0].get_theme_stylebox("normal") as StyleBoxFlat
	var arctic_board_color := arctic_board_style.bg_color
	var board_settings: Dictionary = main.state.get("settings", {})
	var selected_theme_ok: bool = str(board_settings.get("theme", "")) == "arctic"
	var board_buttons_ok: bool = _choice_group_has_active_id(main.board_theme_buttons, "arctic")

	main._set_stone_theme("ember", false)
	await get_tree().process_frame

	var ember_texture: Texture2D = main._texture_for_stone(ReversiEngine.BLACK)
	var after_stone_style := main.cell_buttons[0][0].get_theme_stylebox("normal") as StyleBoxFlat
	var after_stone_color := after_stone_style.bg_color
	var stone_settings: Dictionary = main.state.get("settings", {})
	var selected_stone_ok: bool = str(stone_settings.get("stone_theme", "")) == "ember"
	var stone_buttons_ok: bool = _choice_group_has_active_id(main.stone_theme_buttons, "ember")
	main.queue_free()
	return (
		_assert(selected_theme_ok, "ui theme setting changes")
		and _assert(classic_color != arctic_board_color, "ui board theme switches board color")
		and _assert(classic_texture == board_only_texture, "ui board theme does not switch stone texture")
		and _assert(board_buttons_ok, "ui board theme buttons track selected theme")
		and _assert(selected_stone_ok, "ui stone theme setting changes")
		and _assert(board_only_texture != ember_texture, "ui stone theme switches stone texture")
		and _assert(arctic_board_color == after_stone_color, "ui stone theme does not switch board color")
		and _assert(stone_buttons_ok, "ui stone theme buttons track selected theme")
	)


func _visible_hint_count(main) -> int:
	var count := 0
	for row in main.cell_hint_views:
		for hint in row:
			if hint.visible:
				count += 1
	return count


func _visible_hint_piece_texture_count(main) -> int:
	var count := 0
	for x in range(main.cell_hint_views.size()):
		for y in range(main.cell_hint_views[x].size()):
			if main.cell_hint_views[x][y].visible and main.cell_piece_views[x][y].texture != null:
				count += 1
	return count


func _visible_button_text_exists(root: Node, text: String) -> bool:
	var button := root as Button
	if button != null and button.is_visible_in_tree() and button.text == text:
		return true
	for child in root.get_children():
		if _visible_button_text_exists(child, text):
			return true
	return false


func _visible_option_button_exists(root: Node) -> bool:
	var option := root as OptionButton
	if option != null and option.is_visible_in_tree():
		return true
	for child in root.get_children():
		if _visible_option_button_exists(child):
			return true
	return false


func _make_left_click(position: Vector2) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = position
	return event


func _choice_group_first_button_visible(entries: Array) -> bool:
	if entries.is_empty():
		return false
	var first_entry: Dictionary = entries[0]
	var button := first_entry.get("button") as Button
	return button != null and button.is_visible_in_tree()


func _choice_group_has_active_id(entries: Array, active_id: String) -> bool:
	if entries.is_empty():
		return false
	var found_active := false
	for entry in entries:
		var item: Dictionary = entry
		var button := item.get("button") as Button
		if button == null:
			return false
		var is_active := str(item.get("id", "")) == active_id
		if button.button_pressed != is_active:
			return false
		if is_active:
			found_active = true
	return found_active


func _audio_player_count(main) -> int:
	var count := 0
	for child in main.get_children():
		if child is AudioStreamPlayer:
			count += 1
	return count


func _board_from_strings(rows: Array) -> Array:
	var board: Array = []
	for row_text in rows:
		var row: Array = []
		var text := str(row_text)
		for y in range(text.length()):
			var token := text.substr(y, 1)
			if token == "B":
				row.append(ReversiEngine.BLACK)
			elif token == "W":
				row.append(ReversiEngine.WHITE)
			else:
				row.append(ReversiEngine.NONE)
		board.append(row)
	return board


func _moves_equal(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for index in range(actual.size()):
		if int(actual[index]["x"]) != int(expected[index]["x"]):
			return false
		if int(actual[index]["y"]) != int(expected[index]["y"]):
			return false
	return true


func _read_u16(payload: PackedByteArray, offset: int) -> int:
	return int(payload[offset]) | (int(payload[offset + 1]) << 8)


func _rm_user(rel_path: String) -> void:
	if FileAccess.file_exists(rel_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(rel_path))


func _test_ga4_disabled_in_headless() -> bool:
	# 헤드리스/디버그 빌드: 전송 비활성 + 식별자 파일 미생성(수집 없음 빌드에 흔적 안 남김).
	_rm_user(GA4Sender.CLIENT_ID_PATH)
	var sender: Node = GA4Sender.new()
	add_child(sender)
	var enabled_ok := _assert(not sender._enabled, "GA4 disabled in headless build")
	sender.send("game_start", {"difficulty": "EASY"})
	var noop_ok := _assert(sender._queue.is_empty(), "GA4 send is no-op when disabled")
	var no_file_ok := _assert(not FileAccess.file_exists(GA4Sender.CLIENT_ID_PATH), "no client_id file when disabled")
	sender.queue_free()
	return enabled_ok and noop_ok and no_file_ok


func _test_ga4_build_event() -> bool:
	var sender = GA4Sender.new()
	sender._session_id = "1700000000"
	var reserved := sender._build_event("session_start", {})
	var normal := sender._build_event("game_start", {"difficulty": "HARD"})
	sender.free()
	return (
		_assert(reserved.is_empty(), "reserved event name skipped")
		and _assert(str(normal.get("name", "")) == "game_start", "event name preserved")
		and _assert(str(normal["params"].get("difficulty", "")) == "HARD", "event params preserved")
		and _assert(str(normal["params"].get("session_id", "")) == "1700000000", "session_id attached")
		and _assert(normal["params"].has("engagement_time_msec"), "engagement_time_msec attached")
	)


func _test_ga4_batching() -> bool:
	var q: Array = []
	for i in range(30):
		q.append({"name": "e%d" % i})
	var split := GA4Sender._split_batch(q, 25)
	return (
		_assert(split["batch"].size() == 25, "batch caps at 25 events")
		and _assert(split["rest"].size() == 5, "remaining events stay queued")
	)


func _test_ga4_config_validation() -> bool:
	var sender = GA4Sender.new()
	sender.set_config("G-ABC123XYZ", "secret")
	var valid_ok := _assert(sender._config_valid(), "valid G- measurement_id accepted")
	sender.set_config("ABC123XYZ", "secret")
	var invalid_ok := _assert(not sender._config_valid(), "non-G- measurement_id rejected")
	sender.set_config("", "")
	var empty_ok := _assert(not sender._config_valid(), "empty config rejected")
	sender.free()
	return valid_ok and invalid_ok and empty_ok


func _test_ga4_client_id_persists() -> bool:
	_rm_user(GA4Sender.CLIENT_ID_PATH)
	var sender = GA4Sender.new()
	var first := sender._load_or_make_client_id()
	var second := sender._load_or_make_client_id()
	sender.free()
	return (
		_assert(first != "", "client_id generated")
		and _assert(first == second, "client_id persists across loads")
	)


func _test_analytics_adapter_headless_noop() -> bool:
	# 어댑터는 headless 에서 log_event 를 no-op 처리(sender 로 포워딩하지 않음).
	var probe := _AnalyticsProbe.new()
	var adapter = ReversiAnalytics.new()
	adapter.set_sender(probe)
	adapter.on_game_start("EASY", 1)
	adapter.on_game_over("win", 40, 24, "EASY", 60)
	var ok := _assert(probe.sent.is_empty(), "analytics adapter is no-op in headless")
	probe.free()
	return ok


func _assert(condition: bool, label: String) -> bool:
	if !condition:
		push_error("Smoke failed: %s" % label)
		return false
	print("Smoke passed: %s" % label)
	return true
