extends Node

const ReversiEngine = preload("res://scripts/reversi_engine.gd")
const ReversiAnalytics = preload("res://scripts/analytics.gd")
const GA4Sender = preload("res://scripts/ga4_mp_sender.gd")
const PuzzleCatalog = preload("res://scripts/puzzle_catalog.gd")


# analytics 어댑터 포워딩 검증용 프로브(sender 자리에 주입).
class _AnalyticsProbe:
	extends Node
	var sent: Array = []
	func send(event_name: String, params: Dictionary) -> void:
		sent.append({"name": event_name, "params": params})


class _HapticProbe:
	extends RefCounted
	var events: Array = []
	func request(kind: String, duration_ms: int, amplitude: float) -> void:
		events.append({
			"kind": kind,
			"duration_ms": duration_ms,
			"amplitude": amplitude,
		})

	func count(kind: String) -> int:
		var total := 0
		for event in events:
			if str(event.get("kind", "")) == kind:
				total += 1
		return total


class _InterstitialProbe:
	extends RefCounted
	var requests := 0
	func request() -> void:
		requests += 1


class _ShellOpenProbe:
	extends RefCounted
	var uris: Array[String] = []
	func open(uri: String) -> void:
		uris.append(uri)


class _ShareResultProbe:
	extends RefCounted
	var messages: Array[String] = []
	func share(text: String) -> void:
		messages.append(text)


class _MusicProbe:
	extends RefCounted
	var playing := false
	var play_calls := 0
	var stop_calls := 0

	func play() -> void:
		playing = true
		play_calls += 1

	func stop() -> void:
		playing = false
		stop_calls += 1


class _ScreenKeepOnProbe:
	extends RefCounted
	var calls: Array[bool] = []
	func set_keep_on(enable: bool) -> void:
		calls.append(enable)


func _ready() -> void:
	var ok := true
	ok = _test_main_scene_exists() and ok
	ok = _test_screen_keep_on_policy() and ok
	ok = _test_initial_valid_moves() and ok
	ok = _test_first_move_flip() and ok
	ok = _test_flip_count_is_pure() and ok
	ok = _test_game_highlight_summary() and ok
	ok = _test_pass_turn_fixture() and ok
	ok = _test_game_over_full_board() and ok
	ok = _test_board_size_settings_and_rules() and ok
	ok = _test_codec_round_trip() and ok
	ok = _test_save_round_trip() and ok
	ok = _test_preferences_storage_lifecycle() and ok
	ok = _test_difficulty_stats_save_round_trip() and ok
	ok = _test_undo_round_trip() and ok
	ok = _test_search_score_alpha_beta_cutoff_branches() and ok
	ok = _test_choose_ai_move_alpha_beta_and_seeded_ties() and ok
	ok = _test_alpha_beta_matches_full_search() and ok
	ok = _test_endgame_exact_search() and ok
	ok = _test_mobility_evaluation_boundaries() and ok
	ok = _test_phase_aware_evaluation_weights() and ok
	ok = _test_c_square_evaluation() and ok
	ok = _test_x_square_evaluation() and ok
	ok = _test_phase_aware_mobility_choice() and ok
	ok = _test_anti_reversi_rules_and_ai() and ok
	ok = _test_puzzle_catalog_and_goals() and ok
	var ai_delay_ok := await _test_ai_think_delay_profile_and_guard()
	ok = ai_delay_ok and ok
	var local_two_player_ok := await _test_local_two_player_mode()
	ok = local_two_player_ok and ok
	var i18n_ok := await _test_i18n_defaults_and_locale_switch()
	ok = i18n_ok and ok
	var japanese_locale_ok := await _test_japanese_locale_and_font_fallback()
	ok = japanese_locale_ok and ok
	var settings_menu_ok := await _test_settings_menu_keeps_playfield_focused()
	ok = settings_menu_ok and ok
	var difficulty_description_ok := await _test_difficulty_description_subtitle()
	ok = difficulty_description_ok and ok
	var anti_reversi_ui_ok := await _test_anti_reversi_ui()
	ok = anti_reversi_ui_ok and ok
	var puzzle_ui_ok := await _test_puzzle_mode_ui_and_save_isolation()
	ok = puzzle_ui_ok and ok
	var how_to_play_ok := await _test_how_to_play_sheet()
	ok = how_to_play_ok and ok
	var move_list_ok := await _test_move_list_panel()
	ok = move_list_ok and ok
	var result_share_ok := await _test_result_share_button()
	ok = result_share_ok and ok
	var game_highlights_ok := await _test_game_highlights_ui_and_restore()
	ok = game_highlights_ok and ok
	var replay_ok := await _test_finished_game_replay()
	ok = replay_ok and ok
	var hint_button_ok := await _test_hint_button()
	ok = hint_button_ok and ok
	var settings_persistence_ok := await _test_settings_persist_immediately()
	ok = settings_persistence_ok and ok
	var board_size_ui_ok := await _test_board_size_ui()
	ok = board_size_ui_ok and ok
	var board_coordinates_ok := await _test_board_coordinate_labels()
	ok = board_coordinates_ok and ok
	var adaptive_layout_ok := await _test_adaptive_vertical_layout()
	ok = adaptive_layout_ok and ok
	var accessibility_ok := await _test_accessibility_settings_and_reduced_motion()
	ok = accessibility_ok and ok
	var high_contrast_ok := await _test_high_contrast_accessibility()
	ok = high_contrast_ok and ok
	var new_game_confirmation_ok := await _test_new_game_confirmation_guard()
	ok = new_game_confirmation_ok and ok
	var theme_ok := await _test_visual_theme_switches_are_independent()
	ok = theme_ok and ok
	var forest_theme_ok := await _test_forest_board_theme()
	ok = forest_theme_ok and ok
	var sakura_theme_ok := await _test_sakura_visual_theme()
	ok = sakura_theme_ok and ok
	var ghost_preview_ok := await _test_legal_move_ghost_preview()
	ok = ghost_preview_ok and ok
	var ui_ok := await _test_ui_hints_return_after_animation()
	ok = ui_ok and ok
	var show_moves_ok := await _test_show_moves_setting()
	ok = show_moves_ok and ok
	var flip_count_ok := await _test_flip_count_overlay()
	ok = flip_count_ok and ok
	var undo_ui_ok := await _test_undo_button_states()
	ok = undo_ui_ok and ok
	var result_animation_ok := await _test_result_overlay_animation_once_and_reduce_motion()
	ok = result_animation_ok and ok
	var stats_ui_ok := await _test_result_stats_once_and_i18n()
	ok = stats_ui_ok and ok
	var interstitial_restore_ok := await _test_interstitial_restore_guard()
	ok = interstitial_restore_ok and ok
	ok = _test_ga4_disabled_in_headless() and ok
	ok = _test_ga4_build_event() and ok
	ok = _test_ga4_batching() and ok
	ok = _test_ga4_config_validation() and ok
	ok = _test_ga4_client_id_persists() and ok
	ok = _test_analytics_adapter_headless_noop() and ok
	ok = _test_safe_area_margins() and ok
	ok = _test_sfx_pitch_scale() and ok
	ok = _test_flip_wave_geometry() and ok
	var sfx_sound_ok := await _test_sfx_respects_sound_setting()
	ok = sfx_sound_ok and ok
	var bgm_music_ok := await _test_bgm_loop_and_music_setting()
	ok = bgm_music_ok and ok
	var haptic_ok := await _test_haptic_feedback()
	ok = haptic_ok and ok
	get_tree().quit(0 if ok else 1)


func _test_screen_keep_on_policy() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var foreground_probe := _ScreenKeepOnProbe.new()
	var web_probe := _ScreenKeepOnProbe.new()
	var headless_probe := _ScreenKeepOnProbe.new()
	var foreground_enabled: bool = MainScript.configure_screen_keep_on(
		"macos",
		Callable(foreground_probe, "set_keep_on"),
	)
	var web_enabled: bool = MainScript.configure_screen_keep_on(
		"web",
		Callable(web_probe, "set_keep_on"),
	)
	var headless_enabled: bool = MainScript.configure_screen_keep_on(
		"headless",
		Callable(headless_probe, "set_keep_on"),
	)
	return (
		_assert(
			foreground_enabled and foreground_probe.calls == [true],
			"foreground display requests screen keep-on",
		)
		and _assert(
			web_enabled and web_probe.calls == [true],
			"web display safely routes screen keep-on",
		)
		and _assert(
			!headless_enabled and headless_probe.calls.is_empty(),
			"headless display skips screen keep-on",
		)
	)


func _test_safe_area_margins() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	# safe area 가 창 전체(inset 없음) → 네 마진 모두 0 (데스크톱/웹).
	var full: Dictionary = MainScript.compute_safe_area_margins(Rect2i(0, 0, 1170, 2532), Vector2i(1170, 2532), Vector2(720, 1280))
	var zero_ok: bool = full["left"] == 0.0 and full["top"] == 0.0 and full["right"] == 0.0 and full["bottom"] == 0.0
	# 상단 47px 노치 + 하단 34px 홈 인디케이터 → Y 스케일(vp.y/win.y) 반영, 좌우 0.
	var sy: float = 1280.0 / 2532.0
	var inset: Dictionary = MainScript.compute_safe_area_margins(Rect2i(0, 47, 1170, 2451), Vector2i(1170, 2532), Vector2(720, 1280))
	var top_ok: bool = absf(inset["top"] - 47.0 * sy) < 0.01
	var bottom_ok: bool = absf(inset["bottom"] - 34.0 * sy) < 0.01
	var lr_ok: bool = inset["left"] == 0.0 and inset["right"] == 0.0
	# 잘못된 창 크기 → 0 (0 나눗셈 방지).
	var guard: Dictionary = MainScript.compute_safe_area_margins(Rect2i(0, 0, 0, 0), Vector2i(0, 0), Vector2(720, 1280))
	var guard_ok: bool = guard["top"] == 0.0 and guard["bottom"] == 0.0
	return (
		_assert(zero_ok, "safe area full window gives zero margins")
		and _assert(top_ok, "safe area top margin scaled to viewport")
		and _assert(bottom_ok, "safe area bottom margin scaled to viewport")
		and _assert(lr_ok, "safe area no left/right inset in portrait")
		and _assert(guard_ok, "safe area guards zero window size")
	)


func _test_ai_think_delay_profile_and_guard() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var easy_base := float(MainScript.AI_THINK_DELAY_BASE["EASY"])
	var medium_base := float(MainScript.AI_THINK_DELAY_BASE["MEDIUM"])
	var hard_base := float(MainScript.AI_THINK_DELAY_BASE["HARD"])
	var ordered_bases_ok: bool = easy_base < medium_base and medium_base < hard_base
	var midpoint_ok: bool = is_equal_approx(MainScript.ai_think_delay("EASY", 0.5), easy_base) \
		and is_equal_approx(MainScript.ai_think_delay("MEDIUM", 0.5), medium_base) \
		and is_equal_approx(MainScript.ai_think_delay("HARD", 0.5), hard_base)
	var jitter_range_ok: bool = is_equal_approx(
		MainScript.ai_think_delay("EASY", 0.0),
		easy_base - MainScript.AI_THINK_DELAY_JITTER,
	) and is_equal_approx(
		MainScript.ai_think_delay("EASY", 1.0),
		easy_base + MainScript.AI_THINK_DELAY_JITTER,
	) and MainScript.ai_think_delay("MEDIUM", 0.0) \
		!= MainScript.ai_think_delay("MEDIUM", 1.0)
	var remaining_delay_ok: bool = is_equal_approx(
		MainScript.ai_think_remaining_delay(0.4, 100),
		0.3,
	) and is_zero_approx(MainScript.ai_think_remaining_delay(0.4, 600))
	var thread_policy_ok: bool = MainScript.ai_search_should_use_thread(
		"HARD",
		false,
		true,
	) and !MainScript.ai_search_should_use_thread(
		"HARD",
		true,
		true,
	) and !MainScript.ai_search_should_use_thread(
		"HARD",
		false,
		false,
	) and !MainScript.ai_search_should_use_thread(
		"MEDIUM",
		false,
		true,
	)

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame
	main.player_stone = ReversiEngine.WHITE
	main.difficulty = "EASY"
	main.state = ReversiEngine.create_new_game(ReversiEngine.WHITE, "EASY", 8, 991)
	var settings: Dictionary = main.state.get("settings", {})
	settings["sound"] = false
	settings["reduce_motion"] = true
	main.state["settings"] = settings
	main.ai_move_pending = false
	main.input_locked = false
	main._render()

	var samples: Dictionary = {}
	for _index in range(16):
		var sample: float = main._sample_ai_think_delay()
		samples["%.8f" % sample] = true
	var random_jitter_ok: bool = samples.size() > 1

	var board_before: Array = ReversiEngine.clone_board(main.state["board"])
	main._maybe_play_ai_turn()
	var pending_started_ok: bool = main.ai_move_pending
	await get_tree().process_frame
	main.state["current_turn"] = ReversiEngine.WHITE
	main.state["valid_moves"] = ReversiEngine.get_valid_moves(
		main.state["board"],
		ReversiEngine.WHITE,
	)
	await get_tree().create_timer(0.3).timeout
	var turn_guard_ok: bool = !main.ai_move_pending \
		and main.state["board"] == board_before \
		and main.state.get("move_history", []).is_empty() \
		and int(main.state.get("current_turn", ReversiEngine.NONE)) == ReversiEngine.WHITE

	main.queue_free()
	await get_tree().process_frame

	var threaded_main = main_scene.instantiate()
	add_child(threaded_main)
	await get_tree().process_frame
	threaded_main.player_stone = ReversiEngine.WHITE
	threaded_main.difficulty = "HARD"
	threaded_main.state = ReversiEngine.create_new_game(
		ReversiEngine.WHITE,
		"HARD",
		8,
		992,
	)
	var threaded_settings: Dictionary = threaded_main.state.get("settings", {})
	threaded_settings["sound"] = false
	threaded_settings["reduce_motion"] = true
	threaded_main.state["settings"] = threaded_settings
	var expected_hard_move: Dictionary = ReversiEngine.choose_ai_move(
		threaded_main.state.duplicate(true),
	)
	threaded_main._maybe_play_ai_turn()
	var hard_pending_ok: bool = threaded_main.ai_move_pending \
		and threaded_main.input_locked
	await get_tree().process_frame
	await get_tree().process_frame
	var worker_started_without_blocking: bool = threaded_main._ai_worker_started_count >= 1
	var worker_deadline_msec := Time.get_ticks_msec() + 5000
	while threaded_main._ai_worker_completed_count < 1 \
		and Time.get_ticks_msec() < worker_deadline_msec:
		await get_tree().process_frame
	var worker_thread_ok: bool = threaded_main._ai_worker_started_count >= 1 \
		and threaded_main._ai_worker_completed_count >= 1 \
		and threaded_main._ai_worker_ran_off_main_thread
	var hard_apply_deadline_msec := Time.get_ticks_msec() + 2000
	while (threaded_main.ai_move_pending or threaded_main.input_locked) \
		and Time.get_ticks_msec() < hard_apply_deadline_msec:
		await get_tree().process_frame
	var hard_result_ok: bool = threaded_main._ai_worker_completed_count >= 1 \
		and !threaded_main.ai_move_pending \
		and !threaded_main.input_locked \
		and threaded_main.state.get("move_history", []).size() == 1 \
		and int(threaded_main.state.get("move_history", [])[0].get("x", -1)) \
			== int(expected_hard_move.get("x", -2)) \
		and int(threaded_main.state.get("move_history", [])[0].get("y", -1)) \
			== int(expected_hard_move.get("y", -2))

	threaded_main.state = ReversiEngine.create_new_game(
		ReversiEngine.WHITE,
		"HARD",
		8,
		993,
	)
	threaded_main.state["settings"] = threaded_settings
	threaded_main.player_stone = ReversiEngine.WHITE
	threaded_main.ai_move_pending = false
	threaded_main.input_locked = false
	threaded_main._maybe_play_ai_turn()
	await get_tree().process_frame
	threaded_main.player_stone = ReversiEngine.BLACK
	threaded_main.state = ReversiEngine.create_new_game(
		ReversiEngine.BLACK,
		"HARD",
		8,
		994,
	)
	threaded_main.state["settings"] = threaded_settings
	threaded_main.input_locked = false
	var stale_worker_deadline_msec := Time.get_ticks_msec() + 5000
	while threaded_main.ai_move_pending \
		and Time.get_ticks_msec() < stale_worker_deadline_msec:
		await get_tree().process_frame
	var stale_worker_discard_ok: bool = !threaded_main.ai_move_pending \
		and !threaded_main.input_locked \
		and int(threaded_main.state.get("game_seed", -1)) == 994 \
		and threaded_main.state.get("move_history", []).is_empty()

	var fallback_state := ReversiEngine.create_new_game(
		ReversiEngine.WHITE,
		"MEDIUM",
		8,
		995,
	)
	var expected_fallback_move: Dictionary = ReversiEngine.choose_ai_move(
		fallback_state.duplicate(true),
	)
	var fallback_move: Dictionary = await threaded_main._choose_ai_move_without_blocking(
		fallback_state,
		"MEDIUM",
	)
	var fallback_ok: bool = fallback_move == expected_fallback_move \
		and threaded_main._ai_sync_fallback_count == 1
	var no_new_hud_ok: bool = threaded_main.find_child("GameRoot", true, false).get_child_count() == 7
	threaded_main.queue_free()
	await get_tree().process_frame
	return (
		_assert(ordered_bases_ok, "ai think delay bases increase with difficulty")
		and _assert(midpoint_ok, "ai think delay midpoint matches the centralized base")
		and _assert(jitter_range_ok, "ai think delay applies a bounded nonzero jitter")
		and _assert(random_jitter_ok, "ai think delay samples vary across turns")
		and _assert(remaining_delay_ok, "ai think delay subtracts elapsed search time")
		and _assert(thread_policy_ok, "hard AI uses a worker except on web or unavailable threading")
		and _assert(pending_started_ok, "ai turn enters the pending state before search")
		and _assert(turn_guard_ok, "ai turn change guard prevents a stale computed move")
		and _assert(hard_pending_ok, "hard AI keeps input locked while search is pending")
		and _assert(worker_started_without_blocking, "hard AI starts while main frames keep running")
		and _assert(worker_thread_ok, "hard AI search executes on a worker thread")
		and _assert(hard_result_ok, "hard AI worker applies the exact computed move")
		and _assert(stale_worker_discard_ok, "hard AI worker discards a stale result after game replacement")
		and _assert(fallback_ok, "non-worker path returns the same synchronous AI result")
		and _assert(no_new_hud_ok, "threaded AI reuses the existing status HUD")
	)


func _test_local_two_player_mode() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_local_two_player_%s.json" % suffix
	var save_path := "user://save_local_two_player_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)

	var defaults := ReversiEngine.default_settings()
	var normalization_ok: bool = str(defaults.get("opponent_mode", "")) == "ai" \
		and ReversiEngine.normalize_opponent_mode("local") == "local" \
		and ReversiEngine.normalize_opponent_mode("unknown") == "ai" \
		and str(ReversiEngine.normalize_settings({"opponent_mode": "unknown"}).get("opponent_mode", "")) == "ai"
	var catalogs_ok: bool = str(MainScript.TEXT["ko"].get("opponent_mode_setting", "")) == "대전 상대" \
		and str(MainScript.TEXT["ko"].get("opponent_local", "")) == "2인" \
		and str(MainScript.TEXT["en"].get("opponent_mode_setting", "")) == "OPPONENT" \
		and str(MainScript.TEXT["en"].get("opponent_local", "")) == "2 PLAYERS"

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	main._show_settings_menu()
	await get_tree().process_frame
	var local_entry: Dictionary = main.opponent_mode_buttons[1]
	var local_button := local_entry.get("button") as Button
	var settings_scroll := main.settings_panel.find_child("SettingsScroll", true, false) as ScrollContainer
	var settings_entry_ok: bool = main.opponent_mode_buttons.size() == 2 \
		and local_button != null \
		and main.settings_panel.is_ancestor_of(local_button) \
		and local_button.is_visible_in_tree() \
		and settings_scroll != null \
		and settings_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED \
		and settings_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO \
		and _choice_group_has_active_id(main.opponent_mode_buttons, "ai")

	main._set_opponent_mode_from_choice("local")
	await get_tree().process_frame
	var local_settings: Dictionary = main.state.get("settings", {})
	local_settings["reduce_motion"] = true
	local_settings["sound"] = false
	main.state["settings"] = local_settings
	main._save_preferences()
	main._render()
	var local_ui_ok: bool = main._is_local_game() \
		and _choice_group_has_active_id(main.opponent_mode_buttons, "local") \
		and main.settings_overlay.visible \
		and !main.black_button.visible \
		and !main.white_button.visible \
		and main.player_info_label.text == "흑 플레이어" \
		and main.ai_info_label.text == "백 플레이어" \
		and main.status_label.text == "흑 차례" \
		and main.turn_badge.text == "흑"

	await main._on_cell_pressed(2, 3)
	await get_tree().create_timer(0.55).timeout
	var black_move_only_ok: bool = main.state.get("move_history", []).size() == 1 \
		and int(main.state.get("move_history", [])[0].get("stone", ReversiEngine.NONE)) == ReversiEngine.BLACK \
		and int(main.state.get("current_turn", ReversiEngine.NONE)) == ReversiEngine.WHITE \
		and !main.ai_move_pending \
		and main._status_text() == "백 차례" \
		and main._turn_text(ReversiEngine.WHITE) == "백"
	var white_move: Dictionary = main.state.get("valid_moves", [])[0]
	await main._on_cell_pressed(int(white_move["x"]), int(white_move["y"]))
	var alternating_ok: bool = main.state.get("move_history", []).size() == 2 \
		and int(main.state.get("move_history", [])[1].get("stone", ReversiEngine.NONE)) == ReversiEngine.WHITE \
		and int(main.state.get("current_turn", ReversiEngine.NONE)) == ReversiEngine.BLACK

	main.queue_free()
	await get_tree().process_frame
	var restored = main_scene.instantiate()
	restored._prefs_path = prefs_path
	restored._save_path = save_path
	add_child(restored)
	await get_tree().process_frame
	await get_tree().process_frame
	var restored_ok: bool = restored._is_local_game() \
		and restored.state.get("move_history", []).size() == 2 \
		and int(restored.state.get("current_turn", ReversiEngine.NONE)) == ReversiEngine.BLACK \
		and restored._status_text() == "흑 차례" \
		and !restored.ai_move_pending

	restored._set_opponent_mode_from_choice("ai")
	var ai_settings: Dictionary = restored.state.get("settings", {})
	ai_settings["reduce_motion"] = true
	ai_settings["sound"] = false
	restored.state["settings"] = ai_settings
	var human_result := ReversiEngine.play_move(restored.state, 2, 3)
	restored._render()
	restored._maybe_play_ai_turn()
	await get_tree().create_timer(0.75).timeout
	var ai_regression_ok: bool = bool(human_result.get("ok", false)) \
		and restored._current_opponent_mode() == "ai" \
		and restored.state.get("move_history", []).size() == 2 \
		and int(restored.state.get("move_history", [])[1].get("stone", ReversiEngine.NONE)) == ReversiEngine.WHITE \
		and !restored.ai_move_pending

	restored._set_opponent_mode_from_choice("local")
	var pass_board := _board_from_strings([
		"WWBBBBW.",
		".WWBBBBW",
		"BWWWBBWW",
		".WWWBWWW",
		"BWBWWBWB",
		"BWBWWWWB",
		"BWWBBWWB",
		".WWWWWWW",
	])
	var pass_state := ReversiEngine.create_state_from_board(pass_board, ReversiEngine.BLACK)
	pass_state["settings"] = restored._current_settings()
	var pass_result := ReversiEngine.play_move(pass_state, 0, 7)
	restored.state = pass_state
	restored.ai_move_pending = false
	restored.input_locked = false
	var local_pass_ok: bool = bool(pass_result.get("ok", false)) \
		and restored._status_text() == "패스" \
		and int(restored.state.get("current_turn", ReversiEngine.NONE)) == ReversiEngine.BLACK
	var pass_follow_up := ReversiEngine.play_move(restored.state, 1, 0)
	local_pass_ok = bool(pass_follow_up.get("ok", false)) \
		and restored._status_text() == "백 차례" \
		and local_pass_ok

	var full_board: Array = []
	for _x in range(ReversiEngine.BOARD_SIZE):
		var row: Array = []
		for _y in range(ReversiEngine.BOARD_SIZE):
			row.append(ReversiEngine.BLACK)
		full_board.append(row)
	var final_state := ReversiEngine.create_state_from_board(
		full_board,
		ReversiEngine.BLACK,
		ReversiEngine.BLACK,
		"MEDIUM",
	)
	final_state["settings"] = restored._current_settings()
	var stats_before: Dictionary = final_state.get("stats", {}).duplicate(true)
	restored.state = final_state
	restored._interstitial_shown_this_game = false
	restored._result_animation_played_this_game = true
	restored._render()
	var local_result_ok: bool = restored.result_overlay.visible \
		and restored.result_title_label.text == "흑 승리" \
		and restored.result_score_label.text == "64 : 0" \
		and restored.result_detail_label.text == "흑 64 / 백 0" \
		and !restored.result_stats_label.visible \
		and restored.state.get("stats", {}) == stats_before
	var stored: Dictionary = restored._load_preferences()
	var persistence_ok: bool = str(stored.get("settings", {}).get("opponent_mode", "")) == "local"
	restored.queue_free()
	await get_tree().process_frame
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(normalization_ok, "opponent mode defaults to AI and rejects unknown values")
		and _assert(catalogs_ok, "local opponent labels exist in Korean and English")
		and _assert(settings_entry_ok, "opponent mode entry stays inside settings")
		and _assert(local_ui_ok, "local mode uses black and white identity without extra HUD selectors")
		and _assert(black_move_only_ok, "local mode leaves WHITE for a human without an AI response")
		and _assert(alternating_ok, "local mode accepts alternating BLACK and WHITE moves")
		and _assert(restored_ok, "local mode and active game restore after restart")
		and _assert(ai_regression_ok, "AI mode still responds after switching back")
		and _assert(local_pass_ok, "local mode preserves pass flow and the next player status")
		and _assert(local_result_ok, "local result reports BLACK and WHITE without changing AI stats")
		and _assert(persistence_ok, "local mode selection persists immediately")
	)


func _test_sfx_pitch_scale() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var flip0_ok: bool = absf(MainScript.flip_pitch(0) - 1.0) < 0.0001
	var flip3_ok: bool = absf(MainScript.flip_pitch(3) - (586.0 / 520.0)) < 0.0001
	var big0_ok: bool = absf(MainScript.big_flip_pitch(0) - 1.0) < 0.0001
	var big5_ok: bool = absf(MainScript.big_flip_pitch(5) - (320.0 / 270.0)) < 0.0001
	return (
		_assert(flip0_ok, "flip pitch base is 1.0")
		and _assert(flip3_ok, "flip pitch scales with index")
		and _assert(big0_ok, "big flip pitch base is 1.0")
		and _assert(big5_ok, "big flip pitch scales with count")
	)


func _test_flip_wave_geometry() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var origin := {"x": 2, "y": 3}
	var flipped := [
		{"x": 3, "y": 3},
		{"x": 4, "y": 3},
		{"x": 5, "y": 3},
		{"x": 6, "y": 3},
	]
	var near_delay: float = MainScript.flip_wave_delay(origin, {"x": 3, "y": 3})
	var diagonal_delay: float = MainScript.flip_wave_delay(origin, {"x": 3, "y": 4})
	var far_delay: float = MainScript.flip_wave_delay(origin, {"x": 6, "y": 3})
	var first_tilt: float = MainScript.flip_tilt(0)
	var second_tilt: float = MainScript.flip_tilt(1)
	var transition: Dictionary = MainScript.flip_transition_profile(0)
	var front_scale: Vector2 = transition["front_scale"]
	var back_scale: Vector2 = transition["back_scale"]
	var highlight: Color = transition["highlight"]
	var swap_alpha: float = transition["swap_alpha"]
	var big_sound_delay: float = MainScript.big_flip_sound_delay(origin, flipped)
	return (
		_assert(near_delay > 0.0, "flip wave starts after placement origin")
		and _assert(diagonal_delay > near_delay, "flip wave delays diagonal distance")
		and _assert(far_delay > diagonal_delay, "flip wave expands by origin distance")
		and _assert(first_tilt != 0.0 and second_tilt == -first_tilt, "flip alternates disc rotation tilt")
		and _assert(front_scale.x > 0.0 and back_scale.x < 0.0 and front_scale.y > 1.0, "flip crosses the disc edge with thickness")
		and _assert(highlight != Color.WHITE and swap_alpha > 0.0 and swap_alpha < 1.0, "flip midpoint highlights and fades the color swap")
		and _assert(big_sound_delay > near_delay and big_sound_delay < far_delay, "big flip sound aligns with the first wave midpoint")
	)


func _test_sfx_respects_sound_setting() -> bool:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame
	# 사운드 off → _play_sfx 가 조기 종료해 AudioStreamPlayer 를 만들지 않는다.
	# (sound on 시 실제 play 는 헤드리스 audio 에서 AudioStreamWAV 를 leak 하므로 여기서는 트리거하지 않는다.
	#  on 경로는 _play_sfx 의 sound 게이트 이후 player 생성+play 로 코드상 자명하다.)
	main.state["settings"] = {"sound": false}
	var before: int = _count_audio_players(main)
	main._play_place_sound()
	main._play_flip_sound(2)
	main._play_big_flip_sound(4)
	var off_ok: bool = _count_audio_players(main) == before
	main.free()
	return _assert(off_ok, "sfx suppressed when sound is off")


func _test_bgm_loop_and_music_setting() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var defaults := ReversiEngine.default_settings()
	var normalized := ReversiEngine.normalize_settings({"sound": true, "music": false})
	var loop_stream: AudioStream = MainScript.looping_bgm_stream(MainScript.BGM_STREAM)
	var settings_contract_ok := bool(defaults.get("music", false)) \
		and bool(normalized.get("sound", false)) \
		and !bool(normalized.get("music", true))
	var asset_contract_ok := FileAccess.file_exists("res://assets/audio/bgm_lucid_board.ogg") \
		and loop_stream is AudioStreamOggVorbis \
		and bool((loop_stream as AudioStreamOggVorbis).loop) \
		and float(MainScript.BGM_VOLUME_DB) <= -18.0
	var bus_contract_ok := AudioServer.get_bus_index(MainScript.SFX_BUS) >= 0 \
		and AudioServer.get_bus_index(MainScript.MUSIC_BUS) >= 0 \
		and AudioServer.get_bus_index(MainScript.SFX_BUS) \
			!= AudioServer.get_bus_index(MainScript.MUSIC_BUS)
	var labels_ok := str(MainScript.TEXT["ko"].get("music", "")) == "음악" \
		and str(MainScript.TEXT["en"].get("music", "")) == "MUSIC"

	var prefs_path := "user://prefs_music_%s.json" % str(OS.get_process_id())
	_rm_user(prefs_path)
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame
	main._prefs_path = prefs_path
	var headless_noop_ok := main.bgm_player == null
	var settings_residency_ok: bool = main.music_toggle != null \
		and main.settings_panel.is_ancestor_of(main.music_toggle)

	var probe := _MusicProbe.new()
	main.bgm_player = probe
	var music_on_settings: Dictionary = main._current_settings()
	music_on_settings["sound"] = false
	music_on_settings["music"] = true
	main.state["settings"] = music_on_settings
	main._sync_music_playback()
	var music_independent_on_ok := probe.playing \
		and probe.play_calls == 1 \
		and !bool(main._current_settings().get("sound", true))

	main.music_toggle.button_pressed = false
	await get_tree().process_frame
	var immediate_stop_ok := !probe.playing \
		and probe.stop_calls == 1 \
		and !bool(main._current_settings().get("music", true)) \
		and !bool(main._current_settings().get("sound", true))

	var sound_on_settings: Dictionary = main._current_settings()
	sound_on_settings["sound"] = true
	main.state["settings"] = sound_on_settings
	main._save_preferences()
	main._sync_music_playback()
	var restored_preferences: Dictionary = main._load_preferences()
	var restored_settings: Dictionary = restored_preferences.get("settings", {})
	var persistence_independence_ok := bool(restored_settings.get("sound", false)) \
		and !bool(restored_settings.get("music", true)) \
		and probe.play_calls == 1 \
		and probe.stop_calls == 1

	main.bgm_player = null
	probe = null
	main.queue_free()
	await get_tree().process_frame
	_rm_user(prefs_path)
	return (
		_assert(settings_contract_ok, "music setting defaults on and normalizes independently")
		and _assert(asset_contract_ok, "BGM uses a low-volume looping OGG stream")
		and _assert(bus_contract_ok, "BGM and SFX use separate audio buses")
		and _assert(labels_ok, "music toggle has Korean and English labels")
		and _assert(settings_residency_ok, "music toggle stays inside the settings sheet")
		and _assert(headless_noop_ok, "headless startup skips the BGM audio player")
		and _assert(music_independent_on_ok, "music plays while sound effects are disabled")
		and _assert(immediate_stop_ok, "music toggle stops playback immediately")
		and _assert(
			persistence_independence_ok,
			"music and sound settings persist independently",
		)
	)


func _test_haptic_feedback() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var place_profile: Dictionary = MainScript.haptic_profile("place")
	var flip_profile: Dictionary = MainScript.haptic_profile("flip")
	var big_profile: Dictionary = MainScript.haptic_profile("big_flip")
	var game_over_profile: Dictionary = MainScript.haptic_profile("game_over")
	var profiles_distinct := (
		int(place_profile["duration_ms"]) < int(flip_profile["duration_ms"])
		and int(flip_profile["duration_ms"]) < int(big_profile["duration_ms"])
		and int(big_profile["duration_ms"]) < int(game_over_profile["duration_ms"])
		and float(place_profile["amplitude"]) < float(flip_profile["amplitude"])
		and float(flip_profile["amplitude"]) < float(big_profile["amplitude"])
	)

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame
	var probe := _HapticProbe.new()
	main._haptic_probe = Callable(probe, "request")
	var settings := ReversiEngine.default_settings()
	settings["sound"] = false
	settings["haptic"] = true
	main.state["settings"] = settings

	main._play_place_sound()
	main._play_flip_sound(0)
	main._play_big_flip_sound(4)

	var full_board: Array = []
	for _x in range(ReversiEngine.BOARD_SIZE):
		var row: Array = []
		for _y in range(ReversiEngine.BOARD_SIZE):
			row.append(ReversiEngine.BLACK)
		full_board.append(row)
	main.state = ReversiEngine.create_state_from_board(full_board, ReversiEngine.BLACK)
	main.state["settings"] = settings
	main._interstitial_shown_this_game = false
	main._update_result_overlay(false)
	main._update_result_overlay(false)

	var trigger_counts_ok := (
		probe.count("place") == 1
		and probe.count("flip") == 1
		and probe.count("big_flip") == 1
		and probe.count("game_over") == 1
	)
	var before_disabled := probe.events.size()
	settings["haptic"] = false
	main.state["settings"] = settings
	main._play_place_sound()
	main._play_flip_sound(0)
	main._play_big_flip_sound(4)
	main._request_haptic("game_over")
	var disabled_ok := probe.events.size() == before_disabled

	settings["haptic"] = true
	main.state["settings"] = settings
	main._haptic_probe = Callable()
	var headless_noop_ok: bool = !main._request_haptic("place")
	main.queue_free()
	return (
		_assert(profiles_distinct, "haptic profiles distinguish place flip big flip and game over")
		and _assert(trigger_counts_ok, "haptic triggers each move cue and game over once")
		and _assert(disabled_ok, "haptic toggle suppresses every haptic cue")
		and _assert(headless_noop_ok, "haptic safely no-ops in headless")
	)


func _count_audio_players(node: Node) -> int:
	var count: int = 0
	for child in node.get_children():
		if child is AudioStreamPlayer:
			count += 1
	return count


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


func _test_flip_count_is_pure() -> bool:
	var state := ReversiEngine.create_new_game()
	var board: Array = state["board"]
	var board_before := ReversiEngine.clone_board(board)
	var preview_count := ReversiEngine.count_flips(board, ReversiEngine.BLACK, 2, 3)
	var pure_ok: bool = board == board_before
	var occupied_ok: bool = ReversiEngine.count_flips(board, ReversiEngine.BLACK, 3, 3) == 0
	var invalid_ok: bool = ReversiEngine.count_flips(board, ReversiEngine.NONE, 2, 3) == 0 \
		and ReversiEngine.count_flips(board, ReversiEngine.BLACK, -1, 3) == 0
	var result := ReversiEngine.play_move(state, 2, 3)
	return (
		_assert(preview_count == 1, "flip count previews one disc for the initial C4 move")
		and _assert(pure_ok, "flip count leaves the board unchanged")
		and _assert(occupied_ok and invalid_ok, "flip count safely rejects invalid moves")
		and _assert(preview_count == result.get("flipped", []).size(), "flip count matches the applied move result")
	)


func _test_game_highlight_summary() -> bool:
	var fixture_history: Array = [
		{"x": 2, "y": 3, "stone": ReversiEngine.BLACK},
		{"x": 2, "y": 2, "stone": ReversiEngine.WHITE},
		{"x": 2, "y": 1, "stone": ReversiEngine.BLACK},
		{"x": 1, "y": 1, "stone": ReversiEngine.WHITE},
		{"x": 0, "y": 1, "stone": ReversiEngine.BLACK},
		{"x": 0, "y": 0, "stone": ReversiEngine.WHITE},
		{"x": 3, "y": 2, "stone": ReversiEngine.BLACK},
		{"x": 0, "y": 2, "stone": ReversiEngine.WHITE},
		{"x": 1, "y": 2, "stone": ReversiEngine.BLACK},
		{"x": 1, "y": 3, "stone": ReversiEngine.WHITE},
		{"x": 0, "y": 3, "stone": ReversiEngine.BLACK},
		{"x": 0, "y": 4, "stone": ReversiEngine.WHITE},
		{"x": 1, "y": 0, "stone": ReversiEngine.BLACK},
		{"x": 2, "y": 0, "stone": ReversiEngine.WHITE},
		{"x": 4, "y": 5, "stone": ReversiEngine.BLACK},
	]
	var history_before := fixture_history.duplicate(true)
	var summary := ReversiEngine.summarize_move_history(fixture_history, 8)
	var max_flip_move: Dictionary = summary.get("max_flip_move", {})
	var corrupt_history := fixture_history.duplicate(true)
	(corrupt_history[3] as Dictionary)["stone"] = ReversiEngine.BLACK
	var invalid_summary := ReversiEngine.summarize_move_history(corrupt_history, 8)
	return (
		_assert(fixture_history == history_before, "game highlight summary leaves move history unchanged")
		and _assert(
			int(summary.get("moves_replayed", 0)) == 15,
			"game highlight summary replays the complete fixture",
		)
		and _assert(
			int(summary.get("max_flip_count", 0)) == 2
				and int(max_flip_move.get("x", -1)) == 0
				and int(max_flip_move.get("y", -1)) == 3
				and int(max_flip_move.get("stone", ReversiEngine.NONE)) == ReversiEngine.BLACK,
			"game highlight summary finds the biggest flip and coordinate",
		)
		and _assert(
			int(summary.get("corner_black", -1)) == 0
				and int(summary.get("corner_white", -1)) == 1,
			"game highlight summary counts final occupied corners",
		)
		and _assert(
			int(summary.get("peak_lead", 0)) == 5
				and int(summary.get("peak_lead_stone", ReversiEngine.NONE)) == ReversiEngine.BLACK,
			"game highlight summary finds the peak disc lead",
		)
		and _assert(invalid_summary.is_empty(), "game highlight summary rejects corrupt move history")
	)


func _test_pass_turn_fixture() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var board := _board_from_strings([
		"WWBBBBW.",
		".WWBBBBW",
		"BWWWBBWW",
		".WWWBWWW",
		"BWBWWBWB",
		"BWBWWWWB",
		"BWWBBWWB",
		".WWWWWWW",
	])
	var state := ReversiEngine.create_state_from_board(board, ReversiEngine.BLACK)
	var result := ReversiEngine.play_move(state, 0, 7)
	var pass_keeps_turn_ok: bool = int(state["current_turn"]) == ReversiEngine.BLACK
	var pass_count_ok: bool = int(state["pass_count"]) == 1
	var pass_flag_ok: bool = bool(state.get("last_turn_was_pass", false))
	var main = MainScript.new()
	main.state = state
	main.player_stone = ReversiEngine.BLACK
	var pass_status_ok: bool = main._status_text() == "패스"
	var follow_up_result := ReversiEngine.play_move(state, 1, 0)
	var normal_turn_ok: bool = bool(follow_up_result.get("ok", false)) \
		and !bool(state.get("last_turn_was_pass", true)) \
		and int(state.get("current_turn", ReversiEngine.NONE)) == ReversiEngine.WHITE \
		and main._status_text() == "AI 차례"
	main.free()
	return (
		_assert(bool(result["ok"]), "pass fixture move accepted")
		and _assert(pass_keeps_turn_ok, "pass keeps turn on BLACK")
		and _assert(pass_count_ok, "pass increments pass_count")
		and _assert(pass_flag_ok, "pass marks only the latest turn transition")
		and _assert(pass_status_ok, "ui shows pass for the pass transition")
		and _assert(normal_turn_ok, "normal move clears pass status")
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


func _test_board_size_settings_and_rules() -> bool:
	var defaults := ReversiEngine.default_settings()
	var normalization_ok := (
		int(defaults.get("board_size", 0)) == 8
		and int(ReversiEngine.normalize_settings({"board_size": 5})["board_size"]) == 6
		and int(ReversiEngine.normalize_settings({"board_size": 7})["board_size"]) == 8
		and int(ReversiEngine.normalize_settings({"board_size": 11})["board_size"]) == 10
	)
	var variants_ok := true
	for board_size in [6, 10]:
		var state := ReversiEngine.create_new_game(
			ReversiEngine.BLACK,
			"MEDIUM",
			board_size,
		)
		var board: Array = state["board"]
		var center := int(board_size / 2)
		var expected_moves := [
			{"x": center - 2, "y": center - 1},
			{"x": center - 1, "y": center - 2},
			{"x": center, "y": center + 1},
			{"x": center + 1, "y": center},
		]
		var full_board: Array = []
		for _x in range(board_size):
			var row: Array = []
			for _y in range(board_size):
				row.append(ReversiEngine.BLACK)
			full_board.append(row)
		var black_score := ReversiEngine._evaluate_board(
			full_board,
			ReversiEngine.BLACK,
		)
		var white_score := ReversiEngine._evaluate_board(
			full_board,
			ReversiEngine.WHITE,
		)
		var first_move: Dictionary = expected_moves[0]
		var move_result := ReversiEngine.play_move(
			state,
			int(first_move["x"]),
			int(first_move["y"]),
		)
		var variant_ok: bool = (
			board.size() == board_size
			and board[0].size() == board_size
			and int(state.get("settings", {}).get("board_size", 0)) == board_size
			and _moves_equal(
				ReversiEngine.get_valid_moves(
					ReversiEngine._initial_board(board_size),
					ReversiEngine.BLACK,
				),
				expected_moves,
			)
			and bool(move_result.get("ok", false))
			and move_result.get("flipped", []).size() == 1
			and ReversiEngine._evaluate_board(
				ReversiEngine._initial_board(board_size),
				ReversiEngine.BLACK,
			) == 0
			and black_score > 0
			and black_score == -white_score
		)
		variants_ok = _assert(
			variant_ok,
			"%dx%d rules and evaluation use the board size" % [board_size, board_size],
		) and variants_ok
	return (
		_assert(normalization_ok, "board size settings normalize to 6 8 or 10")
		and variants_ok
	)


func _test_codec_round_trip() -> bool:
	var state := ReversiEngine.create_new_game()
	var payload := ReversiEngine.encode_board_payload(state["board"], int(state["current_turn"]), state["valid_moves"])
	var decoded := ReversiEngine.decode_board_payload(payload)
	var encoded_again := ReversiEngine.encode_board_payload(decoded["board"], int(decoded["current_turn"]), decoded["valid_moves"])
	var expected_rows := PackedInt32Array([0x0000, 0x0000, 0x0300, 0x0e40, 0x01b0, 0x00c0, 0x0000, 0x0000])
	var legacy_payload := PackedByteArray()
	for row_value in expected_rows:
		_append_u16(legacy_payload, int(row_value))
	_append_u16(legacy_payload, ReversiEngine.BLACK)
	var legacy_decoded := ReversiEngine.decode_board_payload(legacy_payload)
	var legacy_saved := ReversiEngine.state_to_save_dict(state)
	legacy_saved["board_codec"] = Marshalls.raw_to_base64(legacy_payload)
	var legacy_restored := ReversiEngine.state_from_save_dict(legacy_saved)

	var large_state := ReversiEngine.create_new_game(
		ReversiEngine.WHITE,
		"HARD",
		10,
	)
	var large_move: Dictionary = large_state["valid_moves"][0]
	ReversiEngine.play_move(
		large_state,
		int(large_move["x"]),
		int(large_move["y"]),
	)
	var large_saved := ReversiEngine.state_to_save_dict(large_state)
	var large_payload := Marshalls.base64_to_raw(str(large_saved["board_codec"]))
	var large_restored := ReversiEngine.state_from_save_dict(large_saved)
	return (
		_assert(
			payload.size() == 21
				and int(payload[0]) == ReversiEngine.CODEC_MAGIC_0
				and int(payload[1]) == ReversiEngine.CODEC_MAGIC_1
				and int(payload[2]) == ReversiEngine.CODEC_VERSION
				and int(payload[3]) == 8,
			"codec writes a tagged variable-length 8x8 payload",
		)
		and _assert(payload == encoded_again, "tagged codec round trip")
		and _assert(
			legacy_payload.size() == 18
				and ReversiEngine.get_board_size(legacy_decoded.get("board", [])) == 8
				and int(legacy_decoded.get("current_turn", 0)) == ReversiEngine.BLACK
				and _moves_equal(legacy_decoded.get("valid_moves", []), state["valid_moves"]),
			"codec decodes the legacy 18-byte 8x8 fixture",
		)
		and _assert(
			!legacy_restored.is_empty()
				and ReversiEngine.get_board_size(legacy_restored.get("board", [])) == 8,
			"legacy board_codec save restores as 8x8",
		)
		and _assert(
			large_payload.size() == 30
				and ReversiEngine.get_board_size(large_restored.get("board", [])) == 10
				and large_restored.get("board", []) == large_state.get("board", [])
				and int(large_restored.get("settings", {}).get("board_size", 0)) == 10,
			"10x10 save round trips through the tagged codec",
		)
	)


func _test_save_round_trip() -> bool:
	var state := ReversiEngine.create_new_game(ReversiEngine.WHITE, "HARD", 8, 13579)
	var fresh_pass_flag_ok := !bool(state.get("last_turn_was_pass", true))
	ReversiEngine.play_move(state, 2, 3)
	state["pass_count"] = 2
	state["last_turn_was_pass"] = true
	var settings: Dictionary = state.get("settings", {})
	settings["haptic"] = false
	state["settings"] = settings
	var saved := ReversiEngine.state_to_save_dict(state)
	var restored := ReversiEngine.state_from_save_dict(saved)
	var legacy_saved := saved.duplicate(true)
	legacy_saved.erase("last_turn_was_pass")
	legacy_saved["difficulty"] = "HARD"
	legacy_saved["settings"] = settings
	var legacy_restored := ReversiEngine.state_from_save_dict(legacy_saved)
	var seedless_legacy_saved := legacy_saved.duplicate(true)
	seedless_legacy_saved.erase("game_seed")
	var seedless_legacy_restored := ReversiEngine.state_from_save_dict(seedless_legacy_saved)
	var seedless_legacy_restored_again := ReversiEngine.state_from_save_dict(seedless_legacy_saved)
	var migrated_preferences := ReversiEngine.preferences_from_legacy_save(legacy_saved)
	return (
		_assert(!restored.is_empty(), "save restores")
		and _assert(int(restored["player_stone"]) == ReversiEngine.WHITE, "save player stone")
		and _assert(restored["move_history"].size() == 1, "save move history")
		and _assert(int(restored["pass_count"]) == 2, "save pass count")
		and _assert(fresh_pass_flag_ok, "new game defaults pass transition to false")
		and _assert(bool(restored.get("last_turn_was_pass", false)), "save restores pass transition")
		and _assert(
			!bool(legacy_restored.get("last_turn_was_pass", true)),
			"legacy save defaults pass transition to false",
		)
		and _assert(int(restored["game_seed"]) == 13579, "save game seed")
		and _assert(
			int(seedless_legacy_restored.get("game_seed", -1))
				== int(seedless_legacy_restored_again.get("game_seed", -2)),
			"legacy save derives a reproducible game seed",
		)
		and _assert(!saved.has("difficulty") and !saved.has("settings"), "game save excludes preferences")
		and _assert(str(legacy_restored["difficulty"]) == "HARD", "legacy save restores difficulty")
		and _assert(!bool(legacy_restored.get("settings", {}).get("haptic", true)), "legacy save restores settings")
		and _assert(str(migrated_preferences.get("difficulty", "")) == "HARD", "legacy save migrates difficulty")
		and _assert(!bool(migrated_preferences.get("settings", {}).get("haptic", true)), "legacy save migrates settings")
	)


func _test_preferences_storage_lifecycle() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_lifecycle_%s.json" % suffix
	var save_path := "user://save_lifecycle_%s.json" % suffix
	var fresh_prefs_path := "user://prefs_fresh_%s.json" % suffix
	var fresh_save_path := "user://save_fresh_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)
	_rm_user(fresh_prefs_path)
	_rm_user(fresh_save_path)

	var legacy_state := ReversiEngine.create_new_game(ReversiEngine.WHITE, "HARD")
	var legacy_settings := ReversiEngine.default_settings()
	legacy_settings["theme"] = "arctic"
	legacy_settings["stone_theme"] = "ember"
	legacy_settings["locale"] = "en"
	legacy_settings["sound"] = false
	legacy_settings.erase("music")
	legacy_state["settings"] = legacy_settings
	var legacy_payload := ReversiEngine.state_to_save_dict(legacy_state)
	legacy_payload["difficulty"] = "HARD"
	legacy_payload["settings"] = legacy_settings
	var save_file := FileAccess.open(save_path, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(legacy_payload))
	save_file.close()

	var migrated_main = MainScript.new()
	migrated_main._prefs_path = prefs_path
	migrated_main._save_path = save_path
	var migrated: Dictionary = migrated_main._load_or_create_preferences()
	migrated_main.preferences = migrated
	migrated_main._load_or_start()
	var migration_ok := FileAccess.file_exists(prefs_path) \
		and str(migrated.get("difficulty", "")) == "HARD" \
		and str(migrated.get("settings", {}).get("theme", "")) == "arctic" \
		and str(migrated.get("settings", {}).get("stone_theme", "")) == "ember" \
		and str(migrated.get("settings", {}).get("locale", "")) == "en" \
		and !bool(migrated.get("settings", {}).get("sound", true)) \
		and bool(migrated.get("settings", {}).get("music", false)) \
		and str(migrated_main.state.get("difficulty", "")) == "HARD"
	migrated_main.free()

	var corrupt_save := FileAccess.open(save_path, FileAccess.WRITE)
	corrupt_save.store_string("{broken")
	corrupt_save.close()
	var restored_main = MainScript.new()
	restored_main._prefs_path = prefs_path
	restored_main._save_path = save_path
	var after_corruption: Dictionary = restored_main._load_or_create_preferences()
	restored_main.preferences = after_corruption
	restored_main._load_or_start()
	var corrupt_state_ok := str(restored_main.state.get("difficulty", "")) == "HARD" \
		and str(restored_main.state.get("settings", {}).get("theme", "")) == "arctic"
	_rm_user(save_path)
	var after_deletion: Dictionary = restored_main._load_or_create_preferences()
	restored_main.preferences = after_deletion
	restored_main._load_or_start()
	var independent_ok := str(after_corruption.get("difficulty", "")) == "HARD" \
		and str(after_corruption.get("settings", {}).get("theme", "")) == "arctic" \
		and str(after_deletion.get("settings", {}).get("locale", "")) == "en" \
		and corrupt_state_ok \
		and str(restored_main.state.get("settings", {}).get("locale", "")) == "en"
	restored_main.free()

	var fresh_main = MainScript.new()
	fresh_main._prefs_path = fresh_prefs_path
	fresh_main._save_path = fresh_save_path
	var fresh: Dictionary = fresh_main._load_or_create_preferences()
	fresh_main.preferences = fresh
	fresh_main._load_or_start()
	var fresh_ok := FileAccess.file_exists(fresh_prefs_path) \
		and str(fresh.get("difficulty", "")) == "MEDIUM" \
		and str(fresh.get("settings", {}).get("locale", "")) == "ko" \
		and str(fresh_main.state.get("settings", {}).get("locale", "")) == "ko"
	fresh_main.free()

	_rm_user(prefs_path)
	_rm_user(save_path)
	_rm_user(fresh_prefs_path)
	_rm_user(fresh_save_path)
	return (
		_assert(migration_ok, "preferences migrate once from legacy game save")
		and _assert(independent_ok, "preferences survive corrupt or deleted game save")
		and _assert(fresh_ok, "preferences initialize without a game save")
	)


func _test_difficulty_stats_save_round_trip() -> bool:
	var state := ReversiEngine.create_new_game(ReversiEngine.BLACK, "EASY")
	var win_ok := ReversiEngine.record_game_result(state, "win")
	state["difficulty"] = "MEDIUM"
	var draw_ok := ReversiEngine.record_game_result(state, "draw")
	state["difficulty"] = "HARD"
	var loss_ok := ReversiEngine.record_game_result(state, "lose")
	var saved := ReversiEngine.state_to_save_dict(state)
	var restored := ReversiEngine.state_from_save_dict(saved)
	var restored_stats: Dictionary = restored.get("stats", {})
	var easy: Dictionary = restored_stats.get("EASY", {})
	var medium: Dictionary = restored_stats.get("MEDIUM", {})
	var hard: Dictionary = restored_stats.get("HARD", {})

	var legacy_saved := saved.duplicate(true)
	legacy_saved.erase("stats")
	var legacy_restored := ReversiEngine.state_from_save_dict(legacy_saved)
	var legacy_stats: Dictionary = legacy_restored.get("stats", {})
	var legacy_easy: Dictionary = legacy_stats.get("EASY", {})
	var invalid_ok := !ReversiEngine.record_game_result(state, "unknown")
	return (
		_assert(win_ok and draw_ok and loss_ok, "stats accepts win draw and loss")
		and _assert(int(easy.get("wins", 0)) == 1, "stats saves EASY win")
		and _assert(int(medium.get("draws", 0)) == 1, "stats saves MEDIUM draw")
		and _assert(int(hard.get("losses", 0)) == 1, "stats saves HARD loss")
		and _assert(int(legacy_easy.get("wins", -1)) == 0, "stats defaults legacy save counters")
		and _assert(invalid_ok, "stats rejects unknown result")
	)


func _test_undo_round_trip() -> bool:
	var state := ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM", 8, 24680)
	var before_payload := ReversiEngine.encode_board_payload(
		state["board"],
		int(state["current_turn"]),
		state["valid_moves"],
	)
	var before_counts := ReversiEngine.count_pieces(state["board"])
	var before_valid_moves: Array = state["valid_moves"].duplicate(true)
	var player_result := ReversiEngine.play_move(state, 2, 3)
	var ai_move := ReversiEngine.choose_ai_move(state)
	var ai_result := ReversiEngine.play_move(state, int(ai_move.get("x", -1)), int(ai_move.get("y", -1)))
	var undo_result := ReversiEngine.undo_last_round(state)
	var after_payload := ReversiEngine.encode_board_payload(
		state["board"],
		int(state["current_turn"]),
		state["valid_moves"],
	)
	var after_counts := ReversiEngine.count_pieces(state["board"])
	var restored := ReversiEngine.state_from_save_dict(ReversiEngine.state_to_save_dict(state))
	var restored_payload := ReversiEngine.encode_board_payload(
		restored["board"],
		int(restored["current_turn"]),
		restored["valid_moves"],
	)
	var empty_state := ReversiEngine.create_new_game()
	var empty_undo := ReversiEngine.undo_last_round(empty_state)
	return (
		_assert(bool(player_result.get("ok", false)), "undo setup player move accepted")
		and _assert(bool(ai_result.get("ok", false)), "undo setup ai move accepted")
		and _assert(bool(undo_result.get("ok", false)), "undo round accepted")
		and _assert(int(undo_result.get("removed_moves", 0)) == 2, "undo removes player and ai moves")
		and _assert(after_payload == before_payload, "undo restores board and current turn")
		and _assert(after_counts == before_counts, "undo restores scores")
		and _assert(_moves_equal(state["valid_moves"], before_valid_moves), "undo restores valid moves")
		and _assert(int(state["pass_count"]) == 0, "undo restores pass count")
		and _assert(state["move_history"].is_empty(), "undo trims move history")
		and _assert(int(state.get("game_seed", -1)) == 24680, "undo preserves game seed")
		and _assert(int(restored.get("game_seed", -1)) == 24680, "undo seed survives save round trip")
		and _assert(restored_payload == before_payload, "undo state survives save round trip")
		and _assert(!bool(empty_undo.get("ok", true)), "undo rejects empty history")
	)


func _test_alpha_beta_matches_full_search() -> bool:
	var fixtures := [
		{"difficulty": "EASY", "plies": 0},
		{"difficulty": "MEDIUM", "plies": 6},
		{"difficulty": "HARD", "plies": 12},
	]
	var all_match := true
	for fixture in fixtures:
		var state := ReversiEngine.create_new_game(
			ReversiEngine.BLACK,
			str(fixture["difficulty"]),
		)
		for _ply in range(int(fixture["plies"])):
			if bool(state["game_over"]):
				break
			var valid_moves: Array = state["valid_moves"]
			if valid_moves.is_empty():
				break
			var move: Dictionary = valid_moves[0]
			ReversiEngine.play_move(state, int(move["x"]), int(move["y"]))

		var search_stats := {
			"nodes": 0,
			"max_cutoffs": 0,
			"min_cutoffs": 0,
		}
		var alpha_beta_move := ReversiEngine.choose_ai_move(state, search_stats)
		var full_search_move := _choose_ai_move_full_search(state)
		var selected_score := _score_move_full_search(state, alpha_beta_move)
		var full_search_score := _score_move_full_search(state, full_search_move)
		var fixture_matches := (
			!alpha_beta_move.is_empty()
			and selected_score == full_search_score
			and int(search_stats.get("best_score", ReversiEngine.SEARCH_MIN)) == full_search_score
		)
		all_match = _assert(
			fixture_matches,
			"alpha-beta keeps the full-search best score for %s" % fixture["difficulty"],
		) and all_match
	return all_match


func _test_search_score_alpha_beta_cutoff_branches() -> bool:
	var board: Array = ReversiEngine.create_new_game()["board"]
	var maximizing_stats := {
		"nodes": 0,
		"max_cutoffs": 0,
		"min_cutoffs": 0,
	}
	var alpha: int = ReversiEngine.SEARCH_MIN
	var beta: int = ReversiEngine.SEARCH_MIN + 1
	ReversiEngine._search_score(
		board,
		ReversiEngine.BLACK,
		ReversiEngine.BLACK,
		3,
		alpha,
		beta,
		maximizing_stats,
	)
	var minimizing_stats := {
		"nodes": 0,
		"max_cutoffs": 0,
		"min_cutoffs": 0,
	}
	alpha = ReversiEngine.SEARCH_MAX - 1
	beta = ReversiEngine.SEARCH_MAX
	ReversiEngine._search_score(
		board,
		ReversiEngine.WHITE,
		ReversiEngine.BLACK,
		3,
		alpha,
		beta,
		minimizing_stats,
	)
	return (
		_assert(
			int(maximizing_stats["max_cutoffs"]) > 0,
			"_search_score maximizing branch cuts off when best >= beta",
		)
		and _assert(
			int(minimizing_stats["min_cutoffs"]) > 0,
			"_search_score minimizing branch cuts off when best <= alpha",
		)
	)


func _test_choose_ai_move_alpha_beta_and_seeded_ties() -> bool:
	var hard_state := ReversiEngine.create_new_game(
		ReversiEngine.BLACK,
		"HARD",
		8,
		11,
	)
	var search_stats := {
		"nodes": 0,
		"max_cutoffs": 0,
		"min_cutoffs": 0,
	}
	var hard_move := ReversiEngine.choose_ai_move(hard_state, search_stats)
	var fixed_seeds := [11, 29, 47, 71, 97, 131]
	var medium_choices := {}
	var hard_choices := {}
	for game_seed in fixed_seeds:
		var medium_state := ReversiEngine.create_new_game(
			ReversiEngine.BLACK,
			"MEDIUM",
			8,
			int(game_seed),
		)
		var medium_move := ReversiEngine.choose_ai_move(medium_state)
		medium_choices["%d,%d" % [medium_move["x"], medium_move["y"]]] = true

		var seeded_hard_state := ReversiEngine.create_new_game(
			ReversiEngine.BLACK,
			"HARD",
			8,
			int(game_seed),
		)
		var seeded_hard_move := ReversiEngine.choose_ai_move(seeded_hard_state)
		hard_choices["%d,%d" % [seeded_hard_move["x"], seeded_hard_move["y"]]] = true

	var reproducible_state := ReversiEngine.create_new_game(
		ReversiEngine.BLACK,
		"MEDIUM",
		8,
		424242,
	)
	var reproducible_move := ReversiEngine.choose_ai_move(reproducible_state)
	var restored_state := ReversiEngine.state_from_save_dict(
		ReversiEngine.state_to_save_dict(reproducible_state)
	)
	var restored_move := ReversiEngine.choose_ai_move(restored_state)

	var easy_choices := {}
	for game_seed in fixed_seeds:
		var easy_state := ReversiEngine.create_new_game(
			ReversiEngine.BLACK,
			"EASY",
			8,
			int(game_seed),
		)
		var easy_move := ReversiEngine.choose_ai_move(easy_state)
		easy_choices["%d,%d" % [easy_move["x"], easy_move["y"]]] = true
	var easy_reproducible_state := ReversiEngine.create_new_game(
		ReversiEngine.BLACK,
		"EASY",
		8,
		515151,
	)
	var easy_reproducible_move := ReversiEngine.choose_ai_move(easy_reproducible_state)
	var easy_restored_state := ReversiEngine.state_from_save_dict(
		ReversiEngine.state_to_save_dict(easy_reproducible_state)
	)
	var easy_restored_move := ReversiEngine.choose_ai_move(easy_restored_state)
	return (
		_assert(
			!hard_move.is_empty()
				and int(search_stats["nodes"]) > 0
				and int(search_stats["max_cutoffs"]) + int(search_stats["min_cutoffs"]) > 0,
			"choose_ai_move executes alpha-beta search with a cutoff",
		)
		and _assert(
			int(search_stats.get("tie_count", 0)) > 1,
			"hard search retains every tied best move",
		)
		and _assert(
			medium_choices.size() > 1 and hard_choices.size() > 1,
			"fixed game seeds vary tied MEDIUM and HARD opening choices",
		)
		and _assert(
			int(reproducible_move["x"]) == int(restored_move["x"])
				and int(reproducible_move["y"]) == int(restored_move["y"])
				and int(restored_state.get("game_seed", -1)) == 424242,
			"saved game seed reproduces the same tied choice",
		)
		and _assert(
			easy_choices.size() > 1,
			"fixed game seeds vary tied EASY opening choices",
		)
		and _assert(
			int(easy_reproducible_move["x"]) == int(easy_restored_move["x"])
				and int(easy_reproducible_move["y"]) == int(easy_restored_move["y"])
				and int(easy_restored_state.get("game_seed", -1)) == 515151,
			"saved EASY game seed reproduces the same tied choice",
		)
	)


func _test_endgame_exact_search() -> bool:
	var board := _board_from_strings([
		"WWWWWWW.",
		"BBBBBWWB",
		"B.WWWBW.",
		"BBWWWBWB",
		"BBBBWWW.",
		"BBBWBWWW",
		".WWBBBW.",
		".W.WBWWW",
	])
	var hard_state := ReversiEngine.create_state_from_board(
		board,
		ReversiEngine.BLACK,
		ReversiEngine.WHITE,
		"HARD",
		580058,
	)
	var exact_stats := {
		"exact_nodes": 0,
		"exact_terminals": 0,
		"exact_passes": 0,
		"exact_max_cutoffs": 0,
		"exact_min_cutoffs": 0,
	}
	var started_usec := Time.get_ticks_usec()
	var exact_move := ReversiEngine.choose_ai_move(hard_state, exact_stats)
	var elapsed_usec := Time.get_ticks_usec() - started_usec
	var exact_win_ok: bool = int(exact_move.get("x", -1)) == 2 \
		and int(exact_move.get("y", -1)) == 1 \
		and int(exact_stats.get("best_score", 0)) == 12 \
		and int(exact_stats.get("tie_count", 0)) == 1
	var exact_branch_ok: bool = bool(exact_stats.get("exact_search", false)) \
		and int(exact_stats.get("empty_count", -1)) == 8 \
		and int(exact_stats.get("exact_nodes", 0)) > 0 \
		and int(exact_stats.get("exact_terminals", 0)) > 0
	var response_budget_ok: bool = elapsed_usec < 5_000_000

	var pass_board := _board_from_strings([
		"WWBBBBW.",
		".WWBBBBW",
		"BWWWBBWW",
		".WWWBWWW",
		"BWBWWBWB",
		"BWBWWWWB",
		"BWWBBWWB",
		".WWWWWWW",
	])
	ReversiEngine._apply_move(pass_board, ReversiEngine.BLACK, 0, 7)
	var pass_stats := {
		"exact_nodes": 0,
		"exact_terminals": 0,
		"exact_passes": 0,
	}
	var score_through_pass := ReversiEngine._search_exact_score(
		pass_board,
		ReversiEngine.WHITE,
		ReversiEngine.BLACK,
		ReversiEngine.SEARCH_MIN,
		ReversiEngine.SEARCH_MAX,
		pass_stats,
	)
	var score_after_pass := ReversiEngine._search_exact_score(
		pass_board,
		ReversiEngine.BLACK,
		ReversiEngine.BLACK,
		ReversiEngine.SEARCH_MIN,
		ReversiEngine.SEARCH_MAX,
	)
	var exact_pass_ok: bool = score_through_pass == score_after_pass \
		and int(pass_stats.get("exact_passes", 0)) > 0

	var easy_state := ReversiEngine.create_state_from_board(
		pass_board,
		ReversiEngine.BLACK,
		ReversiEngine.WHITE,
		"EASY",
		580058,
	)
	var easy_stats := {"nodes": 0}
	var easy_move := ReversiEngine.choose_ai_move(easy_state, easy_stats)
	var expected_easy_move := _choose_ai_move_full_search(easy_state)
	var easy_unchanged_ok: bool = !bool(easy_stats.get("exact_search", true)) \
		and int(easy_move.get("x", -1)) == int(expected_easy_move.get("x", -1)) \
		and int(easy_move.get("y", -1)) == int(expected_easy_move.get("y", -1))

	var thresholds_ok: bool = !ReversiEngine.ENDGAME_EXACT_EMPTIES.has("EASY") \
		and int(ReversiEngine.ENDGAME_EXACT_EMPTIES["MEDIUM"]) == 6 \
		and int(ReversiEngine.ENDGAME_EXACT_EMPTIES["HARD"]) == 8
	var terminal_score_ok: bool = ReversiEngine._terminal_piece_difference(
		_board_from_strings([
			"BBBBBBBB",
			"BBBBBBBB",
			"BBBBBBBB",
			"BBBBBBBB",
			"BBBBBBBB",
			"BBBBBBBB",
			"BBBBBBBB",
			"BBBBWWWW",
		]),
		ReversiEngine.BLACK,
	) == 56
	return (
		_assert(thresholds_ok, "endgame thresholds apply only to MEDIUM and HARD")
		and _assert(exact_branch_ok, "hard AI switches to exact search at eight empties")
		and _assert(exact_win_ok, "exact search selects the unique terminal win")
		and _assert(exact_pass_ok, "exact search handles a forced pass without heuristic fallback")
		and _assert(terminal_score_ok, "exact terminal score is the final disc difference")
		and _assert(easy_unchanged_ok, "easy AI keeps its depth-one first-move behavior")
		and _assert(response_budget_ok, "eight-empty exact search stays within five seconds")
	)


func _choose_ai_move_full_search(state: Dictionary) -> Dictionary:
	var stone := int(state["current_turn"])
	var moves := ReversiEngine.get_valid_moves(state["board"], stone)
	var depth := int(ReversiEngine.DIFFICULTY_DEPTH.get(str(state["difficulty"]), 3))
	var best_score := ReversiEngine.SEARCH_MIN
	var best_move: Dictionary = {}
	for move in moves:
		var board_after := ReversiEngine.clone_board(state["board"])
		ReversiEngine._apply_move(
			board_after,
			stone,
			int(move["x"]),
			int(move["y"]),
		)
		var next_turn := _full_search_next_turn(board_after, stone)
		var score := _full_search_score(board_after, next_turn, stone, depth - 1)
		if score > best_score:
			best_score = score
			best_move = move
	return best_move


func _score_move_full_search(state: Dictionary, move: Dictionary) -> int:
	if move.is_empty():
		return ReversiEngine.SEARCH_MIN
	var stone := int(state["current_turn"])
	var depth := int(ReversiEngine.DIFFICULTY_DEPTH.get(str(state["difficulty"]), 3))
	var board_after := ReversiEngine.clone_board(state["board"])
	ReversiEngine._apply_move(
		board_after,
		stone,
		int(move["x"]),
		int(move["y"]),
	)
	var next_turn := _full_search_next_turn(board_after, stone)
	return _full_search_score(board_after, next_turn, stone, depth - 1)


func _full_search_score(board: Array, turn: int, root_stone: int, depth: int) -> int:
	if depth <= 0 or turn == ReversiEngine.NONE:
		return ReversiEngine._evaluate_board(board, root_stone)

	var moves := ReversiEngine.get_valid_moves(board, turn)
	if moves.is_empty():
		var other := ReversiEngine.opponent(turn)
		if ReversiEngine.get_valid_moves(board, other).is_empty():
			return ReversiEngine._evaluate_board(board, root_stone)
		return _full_search_score(board, other, root_stone, depth - 1)

	var maximizing := turn == root_stone
	var best := ReversiEngine.SEARCH_MIN if maximizing else ReversiEngine.SEARCH_MAX
	for move in moves:
		var next_board := ReversiEngine.clone_board(board)
		ReversiEngine._apply_move(
			next_board,
			turn,
			int(move["x"]),
			int(move["y"]),
		)
		var next_turn := _full_search_next_turn(next_board, turn)
		var score := _full_search_score(next_board, next_turn, root_stone, depth - 1)
		best = max(best, score) if maximizing else min(best, score)
	return best


func _full_search_next_turn(board: Array, just_played: int) -> int:
	var next := ReversiEngine.opponent(just_played)
	if !ReversiEngine.get_valid_moves(board, next).is_empty():
		return next
	if !ReversiEngine.get_valid_moves(board, just_played).is_empty():
		return just_played
	return ReversiEngine.NONE


func _test_mobility_evaluation_boundaries() -> bool:
	var empty_board: Array = []
	var full_board: Array = []
	for _x in range(ReversiEngine.BOARD_SIZE):
		var empty_row: Array = []
		var full_row: Array = []
		for _y in range(ReversiEngine.BOARD_SIZE):
			empty_row.append(ReversiEngine.NONE)
			full_row.append(ReversiEngine.BLACK)
		empty_board.append(empty_row)
		full_board.append(full_row)

	var mobility_state := ReversiEngine.create_new_game()
	ReversiEngine.play_move(mobility_state, 2, 3)
	var mobility_board: Array = mobility_state["board"]
	var mobility_difference := (
		ReversiEngine.get_valid_moves(mobility_board, ReversiEngine.BLACK).size()
		- ReversiEngine.get_valid_moves(mobility_board, ReversiEngine.WHITE).size()
	)
	var black_full_score := ReversiEngine._evaluate_board(
		full_board,
		ReversiEngine.BLACK,
	)
	var white_full_score := ReversiEngine._evaluate_board(
		full_board,
		ReversiEngine.WHITE,
	)
	var opening_board: Array = ReversiEngine.create_new_game()["board"]
	var middle_board := _board_from_strings([
		"BBBBBBBB",
		"WWWWWWWW",
		"BBBBBBBB",
		"WWWWWWWW",
		"........",
		"........",
		"........",
		"........",
	])
	return (
		_assert(
			ReversiEngine._mobility_score(mobility_board, ReversiEngine.BLACK)
				== mobility_difference * ReversiEngine.MOBILITY_WEIGHT,
			"evaluation mobility term uses valid-move difference",
		)
		and _assert(
			ReversiEngine._evaluate_board(empty_board, ReversiEngine.BLACK) == 0,
			"empty-board evaluation stays finite at zero",
		)
		and _assert(
			black_full_score == -white_full_score and absi(black_full_score) < 10000,
			"terminal-board evaluation stays finite and symmetric",
		)
		and _assert(
			ReversiEngine._disc_weight_for_board(opening_board)
				== ReversiEngine.DISC_WEIGHT_OPENING
				and ReversiEngine._disc_weight_for_board(middle_board)
					== ReversiEngine.DISC_WEIGHT_MIDDLE
				and ReversiEngine._disc_weight_for_board(full_board)
					== ReversiEngine.DISC_WEIGHT_ENDGAME,
			"disc-count weight increases from opening through endgame",
		)
	)


func _test_phase_aware_evaluation_weights() -> bool:
	var opening_board: Array = ReversiEngine.create_new_game()["board"]
	var middle_board := _board_from_strings([
		"BBBBBBBB",
		"WWWWWWWW",
		"BBBBBBBB",
		"WWWWWWWW",
		"........",
		"........",
		"........",
		"........",
	])
	var endgame_board: Array = []
	for _x in range(ReversiEngine.BOARD_SIZE):
		var row: Array = []
		for _y in range(ReversiEngine.BOARD_SIZE):
			row.append(ReversiEngine.BLACK)
		endgame_board.append(row)

	var phases_ok := (
		ReversiEngine._phase_for_board(opening_board) == ReversiEngine.PHASE_OPENING
		and ReversiEngine._phase_for_board(middle_board) == ReversiEngine.PHASE_MIDDLE
		and ReversiEngine._phase_for_board(endgame_board) == ReversiEngine.PHASE_ENDGAME
	)
	var disc_schedule_ok := (
		ReversiEngine._disc_weight_for_board(opening_board)
			== ReversiEngine.DISC_WEIGHT_OPENING
		and ReversiEngine._disc_weight_for_board(middle_board)
			== ReversiEngine.DISC_WEIGHT_MIDDLE
		and ReversiEngine._disc_weight_for_board(endgame_board)
			== ReversiEngine.DISC_WEIGHT_ENDGAME
		and ReversiEngine.DISC_WEIGHT_OPENING < ReversiEngine.DISC_WEIGHT_MIDDLE
		and ReversiEngine.DISC_WEIGHT_MIDDLE < ReversiEngine.DISC_WEIGHT_ENDGAME
	)
	var position_schedule_ok := (
		ReversiEngine._position_weight_for_board(opening_board)
			== ReversiEngine.POSITION_WEIGHT_OPENING
		and ReversiEngine._position_weight_for_board(middle_board)
			== ReversiEngine.POSITION_WEIGHT_MIDDLE
		and ReversiEngine._position_weight_for_board(endgame_board)
			== ReversiEngine.POSITION_WEIGHT_ENDGAME
		and ReversiEngine.POSITION_WEIGHT_OPENING > ReversiEngine.POSITION_WEIGHT_MIDDLE
		and ReversiEngine.POSITION_WEIGHT_MIDDLE > 0
		and ReversiEngine.POSITION_WEIGHT_ENDGAME > 0
	)
	return (
		_assert(phases_ok, "evaluation derives opening middle and endgame from occupied cells")
		and _assert(disc_schedule_ok, "disc weight rises from opening to endgame")
		and _assert(position_schedule_ok, "position weight is phase scheduled and remains positive")
	)


func _test_c_square_evaluation() -> bool:
	var c_squares := [
		Vector2i(0, 1),
		Vector2i(1, 0),
		Vector2i(0, 6),
		Vector2i(6, 0),
		Vector2i(1, 7),
		Vector2i(7, 1),
		Vector2i(6, 7),
		Vector2i(7, 6),
	]
	var every_open_corner_c_square_is_negative := true
	for point in c_squares:
		var board := _board_from_strings([
			"........",
			"........",
			"........",
			"........",
			"........",
			"........",
			"........",
			"........",
		])
		board[point.x][point.y] = ReversiEngine.BLACK
		every_open_corner_c_square_is_negative = (
			ReversiEngine._evaluate_board(board, ReversiEngine.BLACK) < 0
			and every_open_corner_c_square_is_negative
		)

	var open_corner_board := _board_from_strings([
		".B......",
		"........",
		"........",
		"........",
		"........",
		"........",
		"........",
		"........",
	])
	var secured_corner_board := ReversiEngine.clone_board(open_corner_board)
	secured_corner_board[0][0] = ReversiEngine.BLACK
	return (
		_assert(
			every_open_corner_c_square_is_negative,
			"all eight C-squares are penalized while their corners are open",
		)
		and _assert(
			ReversiEngine._evaluate_board(open_corner_board, ReversiEngine.BLACK)
				< ReversiEngine._evaluate_board(secured_corner_board, ReversiEngine.BLACK),
			"C-square evaluation improves after the adjacent corner is secured",
		)
	)


func _test_x_square_evaluation() -> bool:
	var dynamic_coordinates_ok := true
	for board_size in ReversiEngine.SUPPORTED_BOARD_SIZES:
		var empty_board: Array = ReversiEngine.create_new_game(
			ReversiEngine.BLACK,
			"EASY",
			board_size,
			6301,
		)["board"]
		for x in range(board_size):
			for y in range(board_size):
				empty_board[x][y] = ReversiEngine.NONE
		var last: int = board_size - 1
		var near_last: int = board_size - 2
		var x_square_pairs := [
			[Vector2i(1, 1), Vector2i(0, 0)],
			[Vector2i(1, near_last), Vector2i(0, last)],
			[Vector2i(near_last, 1), Vector2i(last, 0)],
			[Vector2i(near_last, near_last), Vector2i(last, last)],
		]
		for pair in x_square_pairs:
			var point: Vector2i = pair[0]
			var corner: Vector2i = pair[1]
			var open_corner_board := ReversiEngine.clone_board(empty_board)
			open_corner_board[point.x][point.y] = ReversiEngine.BLACK
			var secured_corner_board := ReversiEngine.clone_board(open_corner_board)
			secured_corner_board[corner.x][corner.y] = ReversiEngine.BLACK
			dynamic_coordinates_ok = (
				ReversiEngine._evaluate_board(open_corner_board, ReversiEngine.BLACK)
					== -board_size * 2 * ReversiEngine.POSITION_WEIGHT_OPENING
				and ReversiEngine._evaluate_board(
					secured_corner_board,
					ReversiEngine.BLACK,
				) == board_size * 3 * ReversiEngine.POSITION_WEIGHT_OPENING
				and dynamic_coordinates_ok
			)

	var secured_x_state := ReversiEngine.create_new_game(
		ReversiEngine.BLACK,
		"EASY",
		ReversiEngine.DEFAULT_BOARD_SIZE,
		6301,
	)
	secured_x_state["board"] = _board_from_strings([
		"........",
		"...W....",
		"BWW.W...",
		".WWWW..W",
		".WWWWWW.",
		"BBBWWWW.",
		"B.WBBB..",
		"BWBB....",
	])
	secured_x_state["current_turn"] = ReversiEngine.BLACK
	secured_x_state["valid_moves"] = ReversiEngine.get_valid_moves(
		secured_x_state["board"],
		ReversiEngine.BLACK,
	)
	var chosen_move := ReversiEngine.choose_ai_move(secured_x_state)
	return (
		_assert(
			dynamic_coordinates_ok,
			"X-square penalties use board-size-derived coordinates and only open corners",
		)
		and _assert(
			int(chosen_move.get("x", -1)) == 6 and int(chosen_move.get("y", -1)) == 1,
			"easy AI can choose a secured X-square instead of retaining the open-corner penalty: %s"
				% [chosen_move],
		)
	)


func _test_phase_aware_mobility_choice() -> bool:
	var board := _board_from_strings([
		"....WB..",
		"...WWB..",
		"..BBWB..",
		"...WWW..",
		"..WWWW..",
		"..B.B...",
		"........",
		"........",
	])
	var medium_state := ReversiEngine.create_state_from_board(
		board,
		ReversiEngine.BLACK,
		ReversiEngine.WHITE,
		"MEDIUM",
		620062,
	)
	var hard_state: Dictionary = medium_state.duplicate(true)
	hard_state["difficulty"] = "HARD"
	var easy_state: Dictionary = medium_state.duplicate(true)
	easy_state["difficulty"] = "EASY"
	var easy_stats := {"nodes": 0}
	var medium_move := ReversiEngine.choose_ai_move(medium_state)
	var hard_move := ReversiEngine.choose_ai_move(hard_state)
	ReversiEngine.choose_ai_move(easy_state, easy_stats)

	var greedy_move := {"x": 5, "y": 5}
	var strategic_move := {"x": 0, "y": 3}
	var greedy_metrics := _move_flip_and_mobility(board, ReversiEngine.BLACK, greedy_move)
	var strategic_metrics := _move_flip_and_mobility(
		board,
		ReversiEngine.BLACK,
		strategic_move,
	)
	var evaluation_once := ReversiEngine._evaluate_board(board, ReversiEngine.BLACK)
	var evaluation_twice := ReversiEngine._evaluate_board(board, ReversiEngine.BLACK)
	return (
		_assert(
			int(greedy_metrics["flips"]) == 4
				and int(strategic_metrics["flips"]) == 3
				and int(strategic_metrics["mobility"]) > int(greedy_metrics["mobility"]),
			"fixture contrasts greedy flips with higher resulting mobility",
		)
		and _assert(
			medium_move == strategic_move and hard_move == strategic_move,
			"medium and hard prefer the lower-flip higher-mobility move",
		)
		and _assert(
			int(easy_stats.get("nodes", -1)) == medium_state["valid_moves"].size()
				and !bool(easy_stats.get("exact_search", true)),
			"easy keeps one-ply search without exact endgame escalation",
		)
		and _assert(
			evaluation_once == evaluation_twice,
			"phase-aware static evaluation is deterministic",
		)
	)


func _test_anti_reversi_rules_and_ai() -> bool:
	var defaults := ReversiEngine.default_settings()
	var settings_contract_ok: bool = str(defaults.get("variant", "")) \
		== ReversiEngine.VARIANT_STANDARD \
		and ReversiEngine.normalize_variant(ReversiEngine.VARIANT_ANTI) \
			== ReversiEngine.VARIANT_ANTI \
		and ReversiEngine.normalize_variant("unknown") == ReversiEngine.VARIANT_STANDARD \
		and str(ReversiEngine.normalize_settings({"variant": "unknown"})["variant"]) \
			== ReversiEngine.VARIANT_STANDARD

	var majority_board: Array = []
	for x in range(ReversiEngine.BOARD_SIZE):
		var row: Array = []
		for y in range(ReversiEngine.BOARD_SIZE):
			row.append(
				ReversiEngine.WHITE
				if x == ReversiEngine.BOARD_SIZE - 1 and y == ReversiEngine.BOARD_SIZE - 1
				else ReversiEngine.BLACK
			)
		majority_board.append(row)
	var standard_result := ReversiEngine.create_state_from_board(
		majority_board,
		ReversiEngine.BLACK,
		ReversiEngine.WHITE,
	)
	var anti_result: Dictionary = standard_result.duplicate(true)
	var anti_result_settings: Dictionary = anti_result["settings"]
	anti_result_settings["variant"] = ReversiEngine.VARIANT_ANTI
	anti_result["settings"] = anti_result_settings
	ReversiEngine._refresh_result(anti_result)
	var minority_wins_ok: bool = bool(anti_result.get("game_over", false)) \
		and int(standard_result.get("winner", ReversiEngine.NONE)) == ReversiEngine.BLACK \
		and int(anti_result.get("winner", ReversiEngine.NONE)) == ReversiEngine.WHITE

	var draw_board: Array = []
	for x in range(ReversiEngine.BOARD_SIZE):
		var row: Array = []
		for y in range(ReversiEngine.BOARD_SIZE):
			row.append(ReversiEngine.BLACK if (x + y) % 2 == 0 else ReversiEngine.WHITE)
		draw_board.append(row)
	var anti_draw := ReversiEngine.create_state_from_board(draw_board)
	var anti_draw_settings: Dictionary = anti_draw["settings"]
	anti_draw_settings["variant"] = ReversiEngine.VARIANT_ANTI
	anti_draw["settings"] = anti_draw_settings
	ReversiEngine._refresh_result(anti_draw)
	var draw_unchanged_ok: bool = bool(anti_draw.get("game_over", false)) \
		and int(anti_draw.get("winner", -1)) == ReversiEngine.NONE

	var choice_board := _board_from_strings([
		"..WWWWW.",
		"WWWWBW..",
		"WWWWWWW.",
		"WWBWBW.B",
		"WWWBWWBB",
		"WWWWB.BB",
		"WWWWWBBB",
		"B.W.B.BB",
	])
	var standard_state := ReversiEngine.create_state_from_board(
		choice_board,
		ReversiEngine.BLACK,
		ReversiEngine.WHITE,
		"EASY",
		560056,
	)
	var anti_state: Dictionary = standard_state.duplicate(true)
	var anti_settings: Dictionary = anti_state["settings"]
	anti_settings["variant"] = ReversiEngine.VARIANT_ANTI
	anti_state["settings"] = anti_settings
	var standard_evaluation := ReversiEngine._evaluate_board(
		choice_board,
		ReversiEngine.BLACK,
	)
	var anti_evaluation := ReversiEngine._evaluate_board(
		choice_board,
		ReversiEngine.BLACK,
		ReversiEngine.VARIANT_ANTI,
	)
	var evaluation_inverts_ok: bool = anti_evaluation == -standard_evaluation \
		and ReversiEngine._terminal_piece_difference(
			majority_board,
			ReversiEngine.BLACK,
			ReversiEngine.VARIANT_ANTI,
		) == -ReversiEngine._terminal_piece_difference(
			majority_board,
			ReversiEngine.BLACK,
		)
	var standard_move := ReversiEngine.choose_ai_move(standard_state)
	var anti_move := ReversiEngine.choose_ai_move(anti_state)
	var standard_board_after := ReversiEngine.clone_board(choice_board)
	ReversiEngine._apply_move(
		standard_board_after,
		ReversiEngine.BLACK,
		int(standard_move.get("x", -1)),
		int(standard_move.get("y", -1)),
	)
	var anti_board_after := ReversiEngine.clone_board(choice_board)
	ReversiEngine._apply_move(
		anti_board_after,
		ReversiEngine.BLACK,
		int(anti_move.get("x", -1)),
		int(anti_move.get("y", -1)),
	)
	var standard_counts := ReversiEngine.count_pieces(standard_board_after)
	var anti_counts := ReversiEngine.count_pieces(anti_board_after)
	var anti_choice_ok: bool = standard_move == {"x": 0, "y": 0} \
		and anti_move == {"x": 1, "y": 6} \
		and int(anti_counts["black"]) < int(standard_counts["black"])

	return (
		_assert(settings_contract_ok, "anti variant defaults and normalization are fail closed")
		and _assert(minority_wins_ok, "anti variant awards a terminal board to the minority stone")
		and _assert(draw_unchanged_ok, "anti variant keeps equal terminal counts as a draw")
		and _assert(evaluation_inverts_ok, "anti variant reverses heuristic and exact terminal scores")
		and _assert(anti_choice_ok, "anti AI avoids the standard corner and keeps fewer discs")
	)


func _test_puzzle_catalog_and_goals() -> bool:
	var definitions := PuzzleCatalog.all()
	var ids := {}
	var catalog_contract_ok := definitions.size() >= 3
	for definition_value in definitions:
		var definition: Dictionary = definition_value
		var puzzle_id := str(definition.get("id", ""))
		var puzzle_state := PuzzleCatalog.create_state(definition, 590059)
		ids[puzzle_id] = true
		catalog_contract_ok = catalog_contract_ok \
			and PuzzleCatalog.definition_is_valid(definition) \
			and ReversiEngine.get_board_size(puzzle_state.get("board", [])) == 8 \
			and int(puzzle_state.get("current_turn", ReversiEngine.NONE)) \
				== int(definition.get("current_turn", ReversiEngine.NONE)) \
			and str(puzzle_state.get("difficulty", "")) \
				== str(definition.get("difficulty", "")) \
			and !str(definition.get("description", "")).is_empty() \
			and typeof(definition.get("goal", {})) == TYPE_DICTIONARY

	var corner_definition := PuzzleCatalog.get_by_id("corner_capture")
	var corner_state := PuzzleCatalog.create_state(corner_definition, 590001)
	var corner_before := PuzzleCatalog.evaluate_goal(corner_definition, corner_state)
	var corner_move := ReversiEngine.play_move(corner_state, 0, 0)
	var corner_after := PuzzleCatalog.evaluate_goal(corner_definition, corner_state)
	var corner_goal_ok: bool = !bool(corner_before.get("complete", true)) \
		and bool(corner_move.get("ok", false)) \
		and bool(corner_after.get("complete", false)) \
		and bool(corner_after.get("success", false))

	var win_definition := PuzzleCatalog.get_by_id("white_finish")
	var win_state := PuzzleCatalog.create_state(win_definition, 590002)
	var finish_move := ReversiEngine.play_move(win_state, 5, 7)
	var win_result := PuzzleCatalog.evaluate_goal(win_definition, win_state)
	var win_goal_ok: bool = bool(finish_move.get("ok", false)) \
		and bool(win_state.get("game_over", false)) \
		and int(win_state.get("winner", ReversiEngine.NONE)) == ReversiEngine.WHITE \
		and bool(win_result.get("complete", false)) \
		and bool(win_result.get("success", false))
	var failed_state := PuzzleCatalog.create_state(win_definition, 590003)
	failed_state["game_over"] = true
	failed_state["winner"] = ReversiEngine.BLACK
	var failed_result := PuzzleCatalog.evaluate_goal(win_definition, failed_state)
	var failed_goal_ok: bool = bool(failed_result.get("complete", false)) \
		and !bool(failed_result.get("success", true))

	return (
		_assert(
			catalog_contract_ok and ids.size() == definitions.size(),
			"puzzle catalog defines three valid board turn description goal and difficulty fixtures",
		)
		and _assert(corner_goal_ok, "puzzle corner goal completes only after the target corner is captured")
		and _assert(win_goal_ok, "puzzle win goal succeeds on the matching terminal winner")
		and _assert(failed_goal_ok, "puzzle win goal reports a failed terminal winner")
	)


func _move_flip_and_mobility(
	board: Array,
	stone: int,
	move: Dictionary,
) -> Dictionary:
	var board_after := ReversiEngine.clone_board(board)
	var flipped := ReversiEngine._apply_move(
		board_after,
		stone,
		int(move["x"]),
		int(move["y"]),
	)
	return {
		"flips": flipped.size(),
		"mobility": (
			ReversiEngine.get_valid_moves(board_after, stone).size()
			- ReversiEngine.get_valid_moves(
				board_after,
				ReversiEngine.opponent(stone),
			).size()
		),
	}


func _test_legal_move_ghost_preview() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame

	main.ai_move_pending = false
	main.input_locked = false
	main.player_stone = ReversiEngine.BLACK
	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	var initial_settings: Dictionary = main.state.get("settings", {})
	initial_settings["sound"] = false
	main.state["settings"] = initial_settings
	main._render()
	await get_tree().process_frame

	var expected_moves: int = main.state.get("valid_moves", []).size()
	var black_texture: Texture2D = main._texture_for_stone(ReversiEngine.BLACK)
	var board_grid := main.find_child("BoardGrid", true, false) as GridContainer
	var initial_ghosts_ok: bool = expected_moves == 4 \
		and _visible_ghost_count(main) == expected_moves \
		and _visible_hint_count(main) == expected_moves \
		and !main.cell_ghost_views[0][0].visible
	var board_layer_ok: bool = board_grid != null
	for move_value in main.state.get("valid_moves", []):
		var move: Dictionary = move_value
		var x := int(move.get("x", -1))
		var y := int(move.get("y", -1))
		var ghost: TextureRect = main.cell_ghost_views[x][y]
		initial_ghosts_ok = initial_ghosts_ok \
			and ghost.visible \
			and ghost.texture == black_texture \
			and is_equal_approx(ghost.modulate.a, MainScript.LEGAL_MOVE_GHOST_ALPHA) \
			and is_equal_approx(ghost.scale.x, MainScript.LEGAL_MOVE_GHOST_SCALE) \
			and is_equal_approx(ghost.scale.y, MainScript.LEGAL_MOVE_GHOST_SCALE) \
			and ghost.pivot_offset == ghost.size * 0.5
		board_layer_ok = board_layer_ok \
			and board_grid.is_ancestor_of(ghost) \
			and !main.settings_panel.is_ancestor_of(ghost)

	var all_theme_contrast_ok := true
	for theme_value in MainScript.THEME_IDS:
		var theme_id := str(theme_value)
		main._set_theme(theme_id, false)
		await get_tree().process_frame
		var ghost: TextureRect = main.cell_ghost_views[2][3]
		var hint_style := main.cell_hint_views[2][3].get_theme_stylebox("panel") as StyleBoxFlat
		var theme_config: Dictionary = main._theme_config(theme_id)
		var border_contrast := absf(
			hint_style.border_color.get_luminance()
			- Color(theme_config["board_surface"]).get_luminance()
		)
		all_theme_contrast_ok = all_theme_contrast_ok \
			and ghost.visible \
			and ghost.texture == main._texture_for_stone(ReversiEngine.BLACK) \
			and hint_style != null \
			and hint_style.bg_color.a <= 0.10 \
			and border_contrast >= 0.18

	main._set_theme("classic", false)
	await get_tree().process_frame
	main.state["current_turn"] = ReversiEngine.WHITE
	main.state["valid_moves"] = ReversiEngine.get_valid_moves(
		main.state["board"],
		ReversiEngine.WHITE,
	)
	main.input_locked = false
	main._render()
	var opponent_turn_hidden_ok: bool = _visible_ghost_count(main) == 0 \
		and _visible_hint_count(main) == 0

	main.state["current_turn"] = ReversiEngine.BLACK
	main.state["valid_moves"] = ReversiEngine.get_valid_moves(
		main.state["board"],
		ReversiEngine.BLACK,
	)
	main.input_locked = true
	main._render()
	var input_locked_hidden_ok: bool = _visible_ghost_count(main) == 0 \
		and _visible_hint_count(main) == 0

	main.input_locked = false
	var local_settings: Dictionary = main.state.get("settings", {})
	local_settings["opponent_mode"] = "local"
	main.state["settings"] = local_settings
	main.state["current_turn"] = ReversiEngine.WHITE
	main.state["valid_moves"] = ReversiEngine.get_valid_moves(
		main.state["board"],
		ReversiEngine.WHITE,
	)
	main._render()
	var local_move: Dictionary = main.state.get("valid_moves", [])[0]
	var local_ghost: TextureRect = main.cell_ghost_views[int(local_move["x"])][int(local_move["y"])]
	var local_turn_color_ok: bool = _visible_ghost_count(main) \
			== main.state.get("valid_moves", []).size() \
		and local_ghost.texture == main._texture_for_stone(ReversiEngine.WHITE)

	var ai_settings: Dictionary = main.state.get("settings", {})
	ai_settings["opponent_mode"] = "ai"
	main.state["settings"] = ai_settings
	main.state["current_turn"] = ReversiEngine.BLACK
	main.state["valid_moves"] = ReversiEngine.get_valid_moves(
		main.state["board"],
		ReversiEngine.BLACK,
	)
	main._render()
	var before_board: Array = ReversiEngine.clone_board(main.state["board"])
	var move_result: Dictionary = ReversiEngine.play_move(main.state, 2, 3)
	var motion_count_before: int = main._motion_tween_count
	await main._render_with_animation(before_board, move_result)
	var placed_view: TextureRect = main.cell_piece_views[2][3]
	var placement_transition_ok: bool = bool(move_result.get("ok", false)) \
		and !main.cell_ghost_views[2][3].visible \
		and placed_view.texture == main._texture_for_stone(ReversiEngine.BLACK) \
		and placed_view.modulate == Color.WHITE \
		and placed_view.scale == Vector2.ONE \
		and main._motion_tween_count > motion_count_before

	main.queue_free()
	return (
		_assert(initial_ghosts_ok, "legal moves render current-color translucent ghost discs")
		and _assert(board_layer_ok, "ghost discs stay inside the board render layer")
		and _assert(all_theme_contrast_ok, "ghost discs retain a contrasting marker across every board theme")
		and _assert(opponent_turn_hidden_ok, "ghost discs hide during the AI opponent turn")
		and _assert(input_locked_hidden_ok, "ghost discs hide while board input is locked")
		and _assert(local_turn_color_ok, "local play ghost discs follow the current turn color")
		and _assert(placement_transition_ok, "a ghost disc transitions into the existing opaque placement animation")
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
	var ghost_stones := _visible_ghost_count(main)
	var unlocked := !bool(main.input_locked)
	main.queue_free()
	return (
		_assert(unlocked, "ui unlocks after move animation")
		and _assert(expected_hints > 0, "ui has valid player moves after ai")
		and _assert(visible_hints == expected_hints, "ui valid hints return after animation")
		and _assert(ghost_stones == expected_hints, "ui valid hints return as ghost stones")
	)


func _test_show_moves_setting() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_show_moves_%s.json" % suffix
	var save_path := "user://save_show_moves_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)

	var defaults := ReversiEngine.default_settings()
	var legacy_normalized := ReversiEngine.normalize_settings({})
	var disabled_normalized := ReversiEngine.normalize_settings({"show_moves": false})
	var normalization_ok: bool = bool(defaults.get("show_moves", false)) \
		and bool(legacy_normalized.get("show_moves", false)) \
		and !bool(disabled_normalized.get("show_moves", true))

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	main.player_stone = ReversiEngine.BLACK
	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	main._render()
	await get_tree().process_frame

	var expected_hints := int(main.state.get("valid_moves", []).size())
	var default_on_ok: bool = main.show_moves_toggle.button_pressed \
		and _visible_hint_count(main) == expected_hints \
		and _visible_ghost_count(main) == expected_hints
	main._show_settings_menu()
	await get_tree().process_frame
	var settings_depth_ok: bool = main.settings_panel.is_ancestor_of(main.show_moves_toggle) \
		and main.show_moves_toggle.is_visible_in_tree() \
		and main.show_moves_toggle.text == "착수 표시" \
		and str(MainScript.TEXT["en"].get("show_moves", "")) == "MOVES"

	main.show_moves_toggle.button_pressed = false
	await get_tree().process_frame
	var hidden_ok: bool = !main._show_moves_enabled() \
		and _visible_hint_count(main) == 0 \
		and _visible_ghost_count(main) == 0
	var motion_count_before_invalid: int = main._motion_tween_count
	main._on_cell_pressed(0, 0)
	var invalid_feedback_ok: bool = main._motion_tween_count == motion_count_before_invalid + 1
	var stored: Dictionary = main._load_preferences()
	var persisted_off_ok: bool = !bool(stored.get("settings", {}).get("show_moves", true))
	main.queue_free()
	await get_tree().process_frame

	var restored_main = main_scene.instantiate()
	restored_main._prefs_path = prefs_path
	restored_main._save_path = save_path
	add_child(restored_main)
	await get_tree().process_frame
	var restored_off_ok: bool = !restored_main.show_moves_toggle.button_pressed \
		and !restored_main._show_moves_enabled() \
		and _visible_hint_count(restored_main) == 0 \
		and _visible_ghost_count(restored_main) == 0
	restored_main._set_locale("en", false)
	await get_tree().process_frame
	var english_label_ok: bool = restored_main.show_moves_toggle.text == "MOVES"
	restored_main.show_moves_toggle.button_pressed = true
	await get_tree().process_frame
	var restored_on_ok: bool = restored_main._show_moves_enabled() \
		and _visible_hint_count(restored_main) == int(
			restored_main.state.get("valid_moves", []).size()
		) \
		and _visible_ghost_count(restored_main) == int(
			restored_main.state.get("valid_moves", []).size()
		)

	restored_main.queue_free()
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(normalization_ok, "show moves defaults on and normalizes saved values")
		and _assert(default_on_ok, "show moves defaults to visible legal markers")
		and _assert(settings_depth_ok, "show moves toggle stays inside settings with ko en labels")
		and _assert(hidden_ok, "show moves off hides legal markers immediately")
		and _assert(invalid_feedback_ok, "invalid move pulse remains active while markers are hidden")
		and _assert(persisted_off_ok, "show moves off persists to preferences")
		and _assert(restored_off_ok, "show moves off restores after restart")
		and _assert(english_label_ok, "show moves renders the English label")
		and _assert(restored_on_ok, "show moves on restores legal markers")
	)


func _test_flip_count_overlay() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_flip_counts_%s.json" % suffix
	var save_path := "user://save_flip_counts_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)

	var defaults := ReversiEngine.default_settings()
	var normalized := ReversiEngine.normalize_settings({})
	var defaults_off_ok: bool = !bool(defaults.get("show_flip_counts", true)) \
		and !bool(normalized.get("show_flip_counts", true))
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	main.player_stone = ReversiEngine.BLACK
	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	main._render()
	await get_tree().process_frame

	var default_marker_ok: bool = !main.show_flip_counts_toggle.button_pressed \
		and _visible_flip_count_count(main) == 0 \
		and _visible_hint_count(main) == int(main.state.get("valid_moves", []).size())
	main._show_settings_menu()
	await get_tree().process_frame
	var toggle_ok: bool = main.settings_panel.is_ancestor_of(main.show_flip_counts_toggle) \
		and main.show_flip_counts_toggle.is_visible_in_tree() \
		and main.show_flip_counts_toggle.text == "뒤집기 수" \
		and str(MainScript.TEXT["en"].get("show_flip_counts", "")) == "FLIP COUNTS"
	main.show_flip_counts_toggle.button_pressed = true
	await get_tree().process_frame

	var legal_counts_ok := true
	var valid_moves: Array = main.state.get("valid_moves", [])
	for move_value in valid_moves:
		var move: Dictionary = move_value
		var x := int(move["x"])
		var y := int(move["y"])
		var label: Label = main.cell_flip_count_labels[x][y]
		legal_counts_ok = label.visible \
			and label.text == str(ReversiEngine.count_flips(main.state["board"], main.player_stone, x, y)) \
			and legal_counts_ok
	var all_legal_visible_ok: bool = _visible_flip_count_count(main) == valid_moves.size()
	var stored: Dictionary = main._load_preferences()
	var persisted_ok: bool = bool(stored.get("settings", {}).get("show_flip_counts", false))

	main.state["current_turn"] = ReversiEngine.WHITE
	main.state["valid_moves"] = ReversiEngine.get_valid_moves(main.state["board"], ReversiEngine.WHITE)
	main.input_locked = false
	main._render()
	var ai_hidden_ok: bool = _visible_flip_count_count(main) == 0
	main.state["current_turn"] = ReversiEngine.BLACK
	main.state["valid_moves"] = ReversiEngine.get_valid_moves(main.state["board"], ReversiEngine.BLACK)
	main.input_locked = true
	main._render()
	var locked_hidden_ok: bool = _visible_flip_count_count(main) == 0
	main.queue_free()
	await get_tree().process_frame

	var restored = main_scene.instantiate()
	restored._prefs_path = prefs_path
	restored._save_path = save_path
	add_child(restored)
	await get_tree().process_frame
	var restored_ok: bool = restored.show_flip_counts_toggle.button_pressed \
		and restored._show_flip_counts_enabled() \
		and _visible_flip_count_count(restored) == int(restored.state.get("valid_moves", []).size())
	restored.queue_free()
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(defaults_off_ok, "flip count overlay defaults off and normalizes legacy settings")
		and _assert(default_marker_ok, "flip count off preserves the existing move markers")
		and _assert(toggle_ok, "flip count toggle stays inside settings with ko en labels")
		and _assert(legal_counts_ok and all_legal_visible_ok, "flip count labels cover every legal player move")
		and _assert(persisted_ok, "flip count toggle persists immediately")
		and _assert(ai_hidden_ok, "flip count labels hide during the ai turn")
		and _assert(locked_hidden_ok, "flip count labels hide while input is locked")
		and _assert(restored_ok, "flip count overlay restores after restart")
	)


func _test_undo_button_states() -> bool:
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
	main._render()
	await get_tree().process_frame

	var initial_board := ReversiEngine.clone_board(main.state["board"])
	var korean_label_ok: bool = main.undo_button.text == "무르기"
	var touch_size_ok: bool = main.undo_button.custom_minimum_size.y >= 56.0
	var empty_disabled_ok: bool = main.undo_button.disabled

	main._set_locale("en", false)
	await get_tree().process_frame
	var english_label_ok: bool = main.undo_button.text == "UNDO"
	main._set_locale("ko", false)
	await get_tree().process_frame

	var player_result := ReversiEngine.play_move(main.state, 2, 3)
	var ai_move := ReversiEngine.choose_ai_move(main.state)
	var ai_result := ReversiEngine.play_move(
		main.state,
		int(ai_move.get("x", -1)),
		int(ai_move.get("y", -1)),
	)
	main._render()
	var available_after_round_ok: bool = !main.undo_button.disabled

	main.input_locked = true
	main._render()
	var locked_disabled_ok: bool = main.undo_button.disabled
	main.input_locked = false
	main.ai_move_pending = true
	main._render()
	var pending_disabled_ok: bool = main.undo_button.disabled
	main.ai_move_pending = false
	main.state["game_over"] = true
	main.state["current_turn"] = ReversiEngine.NONE
	main._render()
	var game_over_available_ok: bool = main._can_undo() and !main.undo_button.disabled \
		and main.result_overlay.visible

	main._on_undo_pressed(false)
	var undo_board_ok: bool = main.state["board"] == initial_board
	var game_resumed_ok: bool = !bool(main.state.get("game_over", true)) \
		and int(main.state.get("current_turn", ReversiEngine.NONE)) == main.player_stone \
		and !main.result_overlay.visible
	var disabled_after_undo_ok: bool = main.undo_button.disabled
	main.queue_free()
	return (
		_assert(korean_label_ok, "ui exposes Korean undo label")
		and _assert(english_label_ok, "ui exposes English undo label")
		and _assert(touch_size_ok, "ui undo button keeps mobile touch height")
		and _assert(empty_disabled_ok, "ui disables undo with empty history")
		and _assert(bool(player_result.get("ok", false)), "ui undo setup player move accepted")
		and _assert(bool(ai_result.get("ok", false)), "ui undo setup ai move accepted")
		and _assert(available_after_round_ok, "ui enables undo after player and ai round")
		and _assert(locked_disabled_ok, "ui disables undo while input is locked")
		and _assert(pending_disabled_ok, "ui disables undo while ai move is pending")
		and _assert(game_over_available_ok, "ui enables undo from the game-over board")
		and _assert(undo_board_ok, "ui undo restores the previous board")
		and _assert(game_resumed_ok, "ui undo closes the result overlay and resumes play")
		and _assert(disabled_after_undo_ok, "ui disables undo after history is exhausted")
	)


func _test_result_stats_once_and_i18n() -> bool:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame

	var full_board: Array = []
	for _x in range(ReversiEngine.BOARD_SIZE):
		var row: Array = []
		for _y in range(ReversiEngine.BOARD_SIZE):
			row.append(ReversiEngine.BLACK)
		full_board.append(row)

	main.player_stone = ReversiEngine.BLACK
	main.difficulty = "EASY"
	main.state = ReversiEngine.create_state_from_board(
		full_board,
		ReversiEngine.BLACK,
		ReversiEngine.BLACK,
		"EASY",
	)
	var settings: Dictionary = main.state.get("settings", {})
	settings["locale"] = "ko"
	settings["sound"] = false
	main.state["settings"] = settings
	main._interstitial_shown_this_game = false

	main._update_result_overlay(false)
	main._update_result_overlay(false)
	var stats: Dictionary = main.state.get("stats", {})
	var easy: Dictionary = stats.get("EASY", {})
	var once_ok: bool = int(easy.get("wins", 0)) == 1
	var korean_text_ok: bool = main.result_stats_label.text == "쉬움 1승 0무 0패"

	main._set_locale("en", false)
	await get_tree().process_frame
	var english_text_ok: bool = main.result_stats_label.text == "EASY 1W 0D 0L"
	var localized_stats: Dictionary = main.state.get("stats", {})
	var localized_easy: Dictionary = localized_stats.get("EASY", {})
	var no_locale_duplicate_ok: bool = int(localized_easy.get("wins", 0)) == 1

	main._start_new_game(ReversiEngine.BLACK, false)
	var preserved_stats: Dictionary = main.state.get("stats", {})
	var preserved_easy: Dictionary = preserved_stats.get("EASY", {})
	var restart_preserves_ok: bool = int(preserved_easy.get("wins", 0)) == 1
	main.queue_free()
	return (
		_assert(once_ok, "ui records a completed game exactly once")
		and _assert(korean_text_ok, "ui shows Korean difficulty stats")
		and _assert(english_text_ok, "ui shows English difficulty stats")
		and _assert(no_locale_duplicate_ok, "ui locale rebuild does not duplicate stats")
		and _assert(restart_preserves_ok, "ui new game preserves cumulative stats")
	)


func _test_result_overlay_animation_once_and_reduce_motion() -> bool:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame

	var black_board: Array = []
	var white_board: Array = []
	var draw_board: Array = []
	for x in range(ReversiEngine.BOARD_SIZE):
		var black_row: Array = []
		var white_row: Array = []
		var draw_row: Array = []
		for y in range(ReversiEngine.BOARD_SIZE):
			black_row.append(ReversiEngine.BLACK)
			white_row.append(ReversiEngine.WHITE)
			draw_row.append(
				ReversiEngine.BLACK if (x + y) % 2 == 0 else ReversiEngine.WHITE
			)
		black_board.append(black_row)
		white_board.append(white_row)
		draw_board.append(draw_row)

	main.player_stone = ReversiEngine.BLACK
	main.state = ReversiEngine.create_state_from_board(
		black_board,
		ReversiEngine.BLACK,
		ReversiEngine.BLACK,
		"EASY",
	)
	var animated_settings: Dictionary = main.state.get("settings", {})
	animated_settings["locale"] = "ko"
	animated_settings["sound"] = false
	animated_settings["haptic"] = false
	animated_settings["reduce_motion"] = false
	main.state["settings"] = animated_settings
	main._interstitial_shown_this_game = true
	main._result_animation_played_this_game = false
	main._motion_tween_count = 0
	main._result_entry_animation_count = 0
	main._winner_emphasis_animation_count = 0
	main._update_result_overlay(false)
	main._update_result_overlay(false)
	var win_guard_ok: bool = main._result_entry_animation_count == 1 \
		and main._winner_emphasis_animation_count == 1 \
		and main._motion_tween_count == 2
	var win_content_ok: bool = main.result_overlay.visible \
		and main.result_winner_stone_view.visible \
		and main.result_winner_stone_view.texture == main._texture_for_stone(ReversiEngine.BLACK) \
		and main.result_title_label.text == main._t("result_win") \
		and main.result_score_label.text == "64 : 0" \
		and main.result_detail_label.text == main._t("result_detail") % [64, 0]
	await get_tree().create_timer(0.55).timeout
	var win_motion_finishes_ok: bool = is_equal_approx(main.result_overlay.modulate.a, 1.0) \
		and main.result_panel.scale.is_equal_approx(Vector2.ONE) \
		and main.result_winner_stone_view.scale.is_equal_approx(Vector2.ONE)

	main._start_new_game(ReversiEngine.BLACK, false)
	main.state = ReversiEngine.create_state_from_board(
		white_board,
		ReversiEngine.BLACK,
		ReversiEngine.BLACK,
		"EASY",
	)
	var reduced_settings: Dictionary = main.state.get("settings", {})
	reduced_settings["locale"] = "ko"
	reduced_settings["sound"] = false
	reduced_settings["haptic"] = false
	reduced_settings["reduce_motion"] = true
	main.state["settings"] = reduced_settings
	main._interstitial_shown_this_game = true
	var before_reduced_motion_count: int = main._motion_tween_count
	var before_reduced_entry_count: int = main._result_entry_animation_count
	var before_reduced_winner_count: int = main._winner_emphasis_animation_count
	main._update_result_overlay(false)
	main._update_result_overlay(false)
	var reduced_motion_ok: bool = main.result_overlay.visible \
		and main._result_animation_played_this_game \
		and main._motion_tween_count == before_reduced_motion_count \
		and main._result_entry_animation_count == before_reduced_entry_count \
		and main._winner_emphasis_animation_count == before_reduced_winner_count \
		and main.result_overlay.modulate == Color.WHITE \
		and main.result_panel.scale == Vector2.ONE \
		and main.result_winner_stone_view.scale == Vector2.ONE
	var lose_content_ok: bool = main.result_winner_stone_view.visible \
		and main.result_winner_stone_view.texture == main._texture_for_stone(ReversiEngine.WHITE) \
		and main.result_title_label.text == main._t("result_lose") \
		and main.result_score_label.text == "0 : 64" \
		and main.result_detail_label.text == main._t("result_detail") % [0, 64]

	main._start_new_game(ReversiEngine.BLACK, false)
	main.state = ReversiEngine.create_state_from_board(
		draw_board,
		ReversiEngine.BLACK,
		ReversiEngine.BLACK,
		"EASY",
	)
	var draw_settings: Dictionary = main.state.get("settings", {})
	draw_settings["locale"] = "ko"
	draw_settings["sound"] = false
	draw_settings["haptic"] = false
	draw_settings["reduce_motion"] = false
	main.state["settings"] = draw_settings
	main._interstitial_shown_this_game = true
	var before_draw_entry_count: int = main._result_entry_animation_count
	var before_draw_winner_count: int = main._winner_emphasis_animation_count
	main._update_result_overlay(false)
	main._update_result_overlay(false)
	var draw_ok: bool = main._result_entry_animation_count == before_draw_entry_count + 1 \
		and main._winner_emphasis_animation_count == before_draw_winner_count \
		and !main.result_winner_stone_view.visible \
		and main.result_title_label.text == main._t("result_draw") \
		and main.result_score_label.text == "32 : 32" \
		and main.result_detail_label.text == main._t("result_detail") % [32, 32]
	var overlay_depth_ok: bool = main.result_overlay.is_ancestor_of(main.result_panel) \
		and main.result_overlay.is_ancestor_of(main.result_winner_stone_view)

	main.queue_free()
	return (
		_assert(win_guard_ok, "result entry and winner emphasis animate once per game")
		and _assert(win_content_ok, "win result keeps verdict scores and winning stone")
		and _assert(win_motion_finishes_ok, "result entry and winner pulse finish at neutral transforms")
		and _assert(reduced_motion_ok, "reduced motion shows result without result tweens")
		and _assert(lose_content_ok, "loss result keeps verdict scores and winning stone")
		and _assert(draw_ok, "draw animates the card once without winner emphasis")
		and _assert(overlay_depth_ok, "result animation stays inside the existing overlay")
	)


func _test_interstitial_restore_guard() -> bool:
	var suffix := str(OS.get_process_id())
	var save_path := "user://save_interstitial_%s.json" % suffix
	var prefs_path := "user://prefs_interstitial_%s.json" % suffix
	_rm_user(save_path)
	_rm_user(prefs_path)

	var full_board: Array = []
	for _x in range(ReversiEngine.BOARD_SIZE):
		var row: Array = []
		for _y in range(ReversiEngine.BOARD_SIZE):
			row.append(ReversiEngine.BLACK)
		full_board.append(row)
	var completed_state := ReversiEngine.create_state_from_board(
		full_board,
		ReversiEngine.BLACK,
		ReversiEngine.BLACK,
		"EASY",
	)
	var save_file := FileAccess.open(save_path, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(ReversiEngine.state_to_save_dict(completed_state)))
	save_file.close()

	var probe := _InterstitialProbe.new()
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._save_path = save_path
	main._prefs_path = prefs_path
	main._interstitial_probe = Callable(probe, "request")
	add_child(main)
	await get_tree().process_frame

	var restored_game_suppresses_ok: bool = bool(main.state.get("game_over", false)) \
		and main.result_overlay.visible \
		and main._interstitial_shown_this_game \
		and probe.requests == 0
	main.result_overlay.visible = false
	main._on_cell_pressed(0, 0)
	var reopened_overlay_suppresses_ok: bool = main.result_overlay.visible \
		and probe.requests == 0

	main._start_new_game(ReversiEngine.BLACK, false)
	var new_game_resets_ok: bool = !main._interstitial_shown_this_game
	main.state = ReversiEngine.create_state_from_board(
		full_board,
		ReversiEngine.BLACK,
		ReversiEngine.BLACK,
		"EASY",
	)
	main._update_result_overlay(false)
	main._update_result_overlay(false)
	var next_game_requests_once_ok: bool = main._interstitial_shown_this_game \
		and probe.requests == 1

	main.queue_free()
	_rm_user(save_path)
	_rm_user(prefs_path)
	return (
		_assert(restored_game_suppresses_ok, "restored completed game suppresses interstitial request")
		and _assert(reopened_overlay_suppresses_ok, "reopened result overlay suppresses duplicate interstitial request")
		and _assert(new_game_resets_ok, "new game resets interstitial guard")
		and _assert(next_game_requests_once_ok, "next completed game requests interstitial exactly once")
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
	var korean_haptic_label_ok: bool = main.haptic_toggle.text == "진동"
	var font_ok: bool = main.theme != null and main.theme.default_font != null
	var font_variation_ok: bool = font_ok and main.theme.default_font is FontVariation
	var font_path_ok: bool = font_variation_ok \
		and str(main.theme.default_font.base_font.resource_path).ends_with("DoHyeon-Regular.ttf")
	var text_visibility_ok: bool = main.status_label.get_theme_constant("outline_size") >= 1 \
		and main.status_label.get_theme_color("font_outline_color").a > 0.0

	main._set_locale("en", false)
	await get_tree().process_frame

	var locale_settings: Dictionary = main.state.get("settings", {})
	var english_setting_ok: bool = str(locale_settings.get("locale", "")) == "en"
	var english_label_ok: bool = main.black_button.text == "BLACK" and main._t("new_game") == "NEW"
	var english_haptic_label_ok: bool = main.haptic_toggle.text == "HAPTIC"
	var locale_buttons_ok: bool = _choice_group_has_active_id(main.locale_buttons, "en")
	main.queue_free()
	return (
		_assert(default_locale_ok, "i18n default locale is Korean")
		and _assert(korean_default_ok, "ui starts in Korean locale")
		and _assert(korean_label_ok, "ui renders Korean labels")
		and _assert(korean_haptic_label_ok, "ui renders Korean haptic label")
		and _assert(font_ok, "ui uses bundled font")
		and _assert(font_variation_ok, "ui font supports bundled fallbacks")
		and _assert(font_path_ok, "ui uses Do Hyeon bundled font")
		and _assert(text_visibility_ok, "ui text has visibility outline")
		and _assert(english_setting_ok, "ui locale setting changes")
		and _assert(english_label_ok, "ui renders English labels")
		and _assert(english_haptic_label_ok, "ui renders English haptic label")
		and _assert(locale_buttons_ok, "ui locale buttons track selected locale")
	)


func _test_japanese_locale_and_font_fallback() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_japanese_%s.json" % suffix
	_rm_user(prefs_path)

	var japanese_texts: Dictionary = MainScript.TEXT["ja"]
	var korean_texts: Dictionary = MainScript.TEXT["ko"]
	var complete_catalog_ok := japanese_texts.size() == korean_texts.size()
	for key in korean_texts.keys():
		complete_catalog_ok = japanese_texts.has(key) and complete_catalog_ok
	var korean_fallback_ok: bool = MainScript.resolve_localized_text(
		"new_game",
		{},
		korean_texts,
	) == "새 게임"
	var unknown_key_ok: bool = MainScript.resolve_localized_text(
		"missing_key",
		{},
		korean_texts,
	) == "missing_key"
	var device_locale_ok: bool = MainScript.locale_id_from_device_locale("ja_JP") == "ja" \
		and MainScript.locale_id_from_device_locale("ja-JP") == "ja" \
		and MainScript.locale_id_from_device_locale("ko_KR") == "ko" \
		and MainScript.locale_id_from_device_locale("en_US") == "en"

	var japanese_font: Font = MainScript.JAPANESE_FONT
	var glyph_coverage_ok := japanese_font != null
	for value in japanese_texts.values():
		var translated := str(value)
		for index in range(translated.length()):
			var codepoint := translated.unicode_at(index)
			if codepoint > 0x7f and !japanese_font.has_char(codepoint):
				glyph_coverage_ok = false

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	add_child(main)
	await get_tree().process_frame
	main._set_locale("ja")
	await get_tree().process_frame

	var fallback_fonts: Array[Font] = main.theme.default_font.get_fallbacks()
	var font_fallback_ok := fallback_fonts.size() == 1 \
		and str(fallback_fonts[0].resource_path).ends_with("MPLUSRounded1c-Regular.ttf")
	var japanese_ui_ok: bool = main._current_locale_id() == "ja" \
		and main.black_button.text == "黒" \
		and main.white_button.text == "白" \
		and main.new_game_button.text == "新しい対局" \
		and main.settings_button.text == "設定" \
		and main.haptic_toggle.text == "振動" \
		and main.show_moves_toggle.text == "着手表示" \
		and main._t("status_your_move") == "あなたの番"
	var locale_segment_ok: bool = main.locale_buttons.size() == 3 \
		and str(main.locale_buttons[2].get("id", "")) == "ja" \
		and (main.locale_buttons[2].get("button") as Button).text == "日本語" \
		and _choice_group_has_active_id(main.locale_buttons, "ja")
	var stored: Dictionary = main._load_preferences()
	var stored_locale_ok: bool = str(stored.get("settings", {}).get("locale", "")) == "ja"
	main.queue_free()
	await get_tree().process_frame

	var restored_main = main_scene.instantiate()
	restored_main._prefs_path = prefs_path
	add_child(restored_main)
	await get_tree().process_frame
	var restored_locale_ok: bool = restored_main._current_locale_id() == "ja" \
		and restored_main.black_button.text == "黒" \
		and restored_main.settings_button.text == "設定"
	restored_main.queue_free()
	_rm_user(prefs_path)
	return (
		_assert(complete_catalog_ok, "Japanese catalog covers every Korean key")
		and _assert(korean_fallback_ok, "missing Japanese translation falls back to Korean")
		and _assert(unknown_key_ok, "unknown localization key returns safely")
		and _assert(device_locale_ok, "Japanese device locale selects ja on first install")
		and _assert(glyph_coverage_ok, "bundled Japanese font covers localized glyphs")
		and _assert(font_fallback_ok, "UI theme bundles Japanese font fallback")
		and _assert(japanese_ui_ok, "UI renders Japanese labels")
		and _assert(locale_segment_ok, "language segment exposes Japanese only in settings")
		and _assert(stored_locale_ok, "Japanese locale saves immediately")
		and _assert(restored_locale_ok, "Japanese locale survives restart")
	)


func _test_settings_menu_keeps_playfield_focused() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame
	var shell_probe := _ShellOpenProbe.new()
	main._shell_open_override = Callable(shell_probe, "open")

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
		and main.board_size_buttons.size() == 3 \
		and main.board_theme_buttons.size() == MainScript.THEME_IDS.size() \
		and !_choice_group_first_button_visible(main.difficulty_buttons) \
		and !_choice_group_first_button_visible(main.board_size_buttons) \
		and !_choice_group_first_button_visible(main.board_theme_buttons)
	var no_select_box_ok: bool = !_visible_option_button_exists(main)
	var load_removed_ok: bool = main._t("load") == "load"
	var default_hint_setting_removed_ok: bool = !ReversiEngine.default_settings().has("highlight")
	var default_haptic_setting_ok: bool = bool(ReversiEngine.default_settings().get("haptic", false))
	var sound_setting: Dictionary = main.state.get("settings", {})
	sound_setting["sound"] = false
	sound_setting["vibration"] = true
	main.state["settings"] = sound_setting
	main.haptic_toggle.button_pressed = true
	var audio_players_before := _audio_player_count(main)
	main._play_place_sound()
	var sound_disabled_ok: bool = _audio_player_count(main) == audio_players_before
	var unsupported_setting_pruned_ok: bool = !main._current_settings().has("vibration")

	main._show_settings_menu()
	await get_tree().process_frame
	var menu_open_ok: bool = main.settings_overlay.visible \
		and _choice_group_first_button_visible(main.difficulty_buttons) \
		and _choice_group_first_button_visible(main.board_size_buttons) \
		and _choice_group_first_button_visible(main.board_theme_buttons)
	var language_section: Node = main.settings_panel.find_child("LanguageSection", true, false)
	var how_to_play_entry: Node = main.settings_panel.find_child("HowToPlayEntryButton", true, false)
	var about_section: Node = main.settings_panel.find_child("AboutSection", true, false)
	var about_app_version := main.settings_panel.find_child("AboutAppVersion", true, false) as Label
	var support_email_button := main.settings_panel.find_child("SupportEmailButton", true, false) as Button
	var privacy_policy_button: Node = main.settings_panel.find_child("PrivacyPolicyButton", true, false)
	var about_location_ok: bool = language_section != null \
		and how_to_play_entry != null \
		and about_section != null \
		and how_to_play_entry.get_parent() == language_section.get_parent() \
		and how_to_play_entry.get_index() == language_section.get_index() + 1 \
		and about_section.get_parent() == how_to_play_entry.get_parent() \
		and about_section.get_index() == how_to_play_entry.get_index() + 1 \
		and main.settings_panel.is_ancestor_of(about_section)
	var settings_panel_fits_ok: bool = main.settings_overlay.get_global_rect().encloses(
		main.settings_panel.get_global_rect(),
	)
	var export_config := ConfigFile.new()
	var export_config_ok: bool = export_config.load("res://export_presets.cfg") == OK
	var export_version := str(export_config.get_value(
		"preset.1.options",
		"application/short_version",
		"",
	))
	var project_version := str(ProjectSettings.get_setting("application/config/version", ""))
	var about_identity_ok: bool = about_app_version != null \
		and !project_version.is_empty() \
		and export_config_ok \
		and project_version == export_version \
		and about_app_version.text.contains(main._t("app_title")) \
		and about_app_version.text.contains(project_version)
	var about_i18n_ok: bool = true
	for locale_id in ["ko", "en"]:
		var locale_texts: Dictionary = MainScript.TEXT[locale_id]
		for key in ["about_title", "about_app_version", "support_email", "privacy_policy"]:
			about_i18n_ok = about_i18n_ok and locale_texts.has(key)
	var privacy_empty_hidden_ok: bool = MainScript.PRIVACY_POLICY_URL.is_empty() \
		and privacy_policy_button == null
	if support_email_button != null:
		support_email_button.pressed.emit()
	var support_email_open_ok: bool = support_email_button != null \
		and support_email_button.text.contains(MainScript.SUPPORT_EMAIL) \
		and shell_probe.uris == ["mailto:%s" % MainScript.SUPPORT_EMAIL]
	var configured_about_section = main._make_about_section("https://example.invalid/privacy")
	var configured_privacy_button := configured_about_section.find_child(
		"PrivacyPolicyButton",
		true,
		false,
	) as Button
	if configured_privacy_button != null:
		configured_privacy_button.pressed.emit()
	var configured_privacy_open_ok: bool = configured_privacy_button != null \
		and shell_probe.uris == [
			"mailto:%s" % MainScript.SUPPORT_EMAIL,
			"https://example.invalid/privacy",
		]
	configured_about_section.free()
	var hint_toggle_removed_ok: bool = !_visible_button_text_exists(main.settings_overlay, "힌트") \
		and !_visible_button_text_exists(main.settings_overlay, "HINT")
	var haptic_toggle_visible_ok: bool = main.haptic_toggle != null \
		and main.haptic_toggle.is_visible_in_tree() \
		and main.haptic_toggle.text == "진동" \
		and main.haptic_toggle.button_pressed
	main.haptic_toggle.button_pressed = false
	await get_tree().process_frame
	var haptic_toggle_saves_ok: bool = !bool(main.state.get("settings", {}).get("haptic", true))
	main.haptic_toggle.button_pressed = true

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
		and _assert(default_haptic_setting_ok, "ui defaults haptic setting on")
		and _assert(sound_disabled_ok, "ui sound setting suppresses move sound")
		and _assert(unsupported_setting_pruned_ok, "ui prunes unsupported saved vibration setting")
		and _assert(menu_open_ok, "ui settings menu reveals settings controls")
		and _assert(about_location_ok, "ui nests how-to entry and about section after language settings")
		and _assert(settings_panel_fits_ok, "ui keeps the about section inside the settings overlay")
		and _assert(about_identity_ok, "ui displays app name and export-matched version")
		and _assert(about_i18n_ok, "ui provides Korean and English about labels")
		and _assert(privacy_empty_hidden_ok, "ui hides privacy action when URL is empty")
		and _assert(support_email_open_ok, "ui opens the support mailto URI")
		and _assert(configured_privacy_open_ok, "ui opens configured privacy policy URI")
		and _assert(hint_toggle_removed_ok, "ui settings menu omits hint toggle")
		and _assert(haptic_toggle_visible_ok, "ui settings menu exposes Korean haptic toggle")
		and _assert(haptic_toggle_saves_ok, "ui haptic toggle updates saved settings")
		and _assert(inside_tap_keeps_open_ok, "ui settings panel tap keeps menu open")
		and _assert(outside_tap_closes_ok, "ui settings background tap closes menu")
		and _assert(menu_close_ok, "ui settings menu closes")
	)


func _test_move_list_panel() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame

	main.player_stone = ReversiEngine.BLACK
	main.difficulty = "MEDIUM"
	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	var settings: Dictionary = main.state.get("settings", {})
	settings["locale"] = "ko"
	settings["sound"] = false
	main.state["settings"] = settings
	main.state["move_history"] = [
		{"x": 3, "y": 2, "stone": ReversiEngine.BLACK, "turn_index": 0},
		{"x": 2, "y": 4, "stone": ReversiEngine.WHITE, "turn_index": 1},
	]
	main.state["last_move"] = {"x": 2, "y": 4, "stone": ReversiEngine.WHITE}
	main.ai_move_pending = true
	main.input_locked = true
	main._render()
	await get_tree().process_frame

	var helper_ok: bool = MainScript.move_coordinate(2, 3) == "C4"
	var entry_ok: bool = main.move_count_label.text == "기보 02 · E3"
	var state_before: Dictionary = main.state.duplicate(true)
	var input_locked_before: bool = main.input_locked
	var ai_pending_before: bool = main.ai_move_pending
	main.move_count_label.pressed.emit()
	await get_tree().process_frame

	var overlay_ok: bool = main.move_list_overlay.visible \
		and main.move_list_panel != null \
		and main.move_list_overlay.mouse_filter == Control.MOUSE_FILTER_STOP
	var scroll_ok: bool = main.move_list_scroll.horizontal_scroll_mode \
		== ScrollContainer.SCROLL_MODE_DISABLED \
		and main.move_list_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO
	var rows_ok: bool = main.move_list_rows.size() == 2
	var ordered_rows_ok := false
	var stone_icons_ok := false
	if rows_ok:
		var first_row: PanelContainer = main.move_list_rows[0]
		var second_row: PanelContainer = main.move_list_rows[1]
		var first_coordinate := first_row.find_child("MoveListCoordinate", true, false) as Label
		var first_stone := first_row.find_child("MoveListStone", true, false) as Label
		var first_icon := first_row.find_child("MoveListStoneIcon", true, false) as TextureRect
		var second_coordinate := second_row.find_child("MoveListCoordinate", true, false) as Label
		var second_stone := second_row.find_child("MoveListStone", true, false) as Label
		var second_icon := second_row.find_child("MoveListStoneIcon", true, false) as TextureRect
		ordered_rows_ok = first_coordinate != null \
			and first_coordinate.text == "C4" \
			and first_stone != null \
			and first_stone.text == "흑" \
			and second_coordinate != null \
			and second_coordinate.text == "E3" \
			and second_stone != null \
			and second_stone.text == "백"
		stone_icons_ok = first_icon != null \
			and first_icon.texture == main._texture_for_stone(ReversiEngine.BLACK) \
			and second_icon != null \
			and second_icon.texture == main._texture_for_stone(ReversiEngine.WHITE)
	var state_unchanged_ok: bool = main.state == state_before \
		and main.input_locked == input_locked_before \
		and main.ai_move_pending == ai_pending_before

	main._hide_move_list()
	main.result_move_list_button.pressed.emit()
	await get_tree().process_frame
	var result_entry_ok: bool = main.move_list_overlay.visible \
		and main.result_overlay.is_ancestor_of(main.result_move_list_button)

	var long_history: Array = []
	for index in range(32):
		long_history.append({
			"x": index % 8,
			"y": (index * 3) % 8,
			"stone": ReversiEngine.BLACK if index % 2 == 0 else ReversiEngine.WHITE,
			"turn_index": index,
		})
	main.state["move_history"] = long_history
	main._render_move_list()
	var overflow_ok: bool = main.move_list_rows.size() == 32 \
		and main.move_list_content.custom_minimum_size.y \
		> main.move_list_scroll.custom_minimum_size.y

	main._start_new_game(ReversiEngine.BLACK, false)
	await get_tree().process_frame
	var reset_ok: bool = !main.move_list_overlay.visible \
		and main.state.get("move_history", []).is_empty()
	main._show_move_list()
	var empty_ok: bool = main.move_list_rows.is_empty() \
		and main.move_list_empty_label != null \
		and main.move_list_empty_label.text == "아직 기록된 수가 없습니다."
	var i18n_ok: bool = true
	for locale_id in ["ko", "en"]:
		var locale_texts: Dictionary = MainScript.TEXT[locale_id]
		for key in ["move_list_entry", "move_list_title", "move_list_empty"]:
			i18n_ok = i18n_ok and locale_texts.has(key) \
				and !str(locale_texts.get(key, "")).is_empty()

	main.queue_free()
	return (
		_assert(helper_ok, "move list coordinate helper maps column row to C4")
		and _assert(entry_ok, "move list entry shows count and localized last move")
		and _assert(overlay_ok, "move list entry opens an input-blocking overlay")
		and _assert(scroll_ok, "move list enables vertical-only scrolling")
		and _assert(ordered_rows_ok, "move list preserves chronological coordinates and stone labels")
		and _assert(stone_icons_ok, "move list renders the matching black and white stone icons")
		and _assert(state_unchanged_ok, "move list leaves game and input state unchanged")
		and _assert(result_entry_ok, "result overlay exposes the move list entry")
		and _assert(overflow_ok, "long move history exceeds the scroll viewport")
		and _assert(reset_ok, "new game hides and clears the move list")
		and _assert(empty_ok, "empty move list renders a localized empty state")
		and _assert(i18n_ok, "move list has Korean and English strings")
	)


func _test_hint_button() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame

	main.player_stone = ReversiEngine.BLACK
	main.difficulty = "EASY"
	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "EASY", 8, 77)
	var settings: Dictionary = main.state.get("settings", {})
	settings["locale"] = "ko"
	settings["sound"] = false
	settings["reduce_motion"] = true
	main.state["settings"] = settings
	main.ai_move_pending = false
	main.input_locked = false
	main._render()
	await get_tree().process_frame

	var controls_strip: Node = main.find_child("PlayControlsStrip", true, false)
	var entry_ok: bool = main.hint_button != null \
		and main.hint_button.text == "힌트" \
		and !main.hint_button.disabled \
		and main.hint_button.custom_minimum_size.y >= 56.0 \
		and controls_strip != null \
		and controls_strip.is_ancestor_of(main.hint_button)
	var expected_move: Dictionary = ReversiEngine.choose_ai_move(main.state)
	var state_before: Dictionary = main.state.duplicate(true)
	main.hint_button.pressed.emit()
	await get_tree().process_frame

	var highlighted_count := 0
	var highlighted_move := {"x": -1, "y": -1}
	for x in range(main.cell_recommendation_views.size()):
		for y in range(main.cell_recommendation_views[x].size()):
			var highlight: PanelContainer = main.cell_recommendation_views[x][y]
			if highlight.visible:
				highlighted_count += 1
				highlighted_move = {"x": x, "y": y}
	var player_best_move_ok: bool = !expected_move.is_empty() \
		and highlighted_count == 1 \
		and highlighted_move == expected_move \
		and main._is_valid_cell(
			main.state.get("valid_moves", []),
			int(highlighted_move["x"]),
			int(highlighted_move["y"]),
		)
	var state_unchanged_ok: bool = main.state == state_before

	main._on_cell_pressed(0, 0)
	var move_clears_hint_ok: bool = main._hinted_move.is_empty()
	for row in main.cell_recommendation_views:
		for highlight in row:
			move_clears_hint_ok = move_clears_hint_ok \
				and !(highlight as PanelContainer).visible

	main.ai_move_pending = true
	main._render()
	var ai_pending_disabled_ok: bool = main.hint_button.disabled
	main.ai_move_pending = false
	main.input_locked = true
	main._render()
	var input_locked_disabled_ok: bool = main.hint_button.disabled
	main.input_locked = false
	main.state["game_over"] = true
	main._render()
	var game_over_disabled_ok: bool = main.hint_button.disabled
	main.state["game_over"] = false
	main.state["current_turn"] = ReversiEngine.WHITE
	main.state["valid_moves"] = ReversiEngine.get_valid_moves(
		main.state["board"],
		ReversiEngine.WHITE,
	)
	main._render()
	var ai_turn_disabled_ok: bool = main.hint_button.disabled

	main.state["current_turn"] = ReversiEngine.BLACK
	main.state["valid_moves"] = []
	main._render()
	main._on_hint_pressed()
	var no_move_safe_ok: bool = main.hint_button.disabled and main._hinted_move.is_empty()

	main._set_locale("en", false)
	await get_tree().process_frame
	var english_label_ok: bool = main.hint_button.text == "HINT"
	var i18n_ok: bool = true
	for locale_id in ["ko", "en"]:
		var locale_texts: Dictionary = MainScript.TEXT[locale_id]
		i18n_ok = i18n_ok and locale_texts.has("hint") \
			and !str(locale_texts.get("hint", "")).is_empty()

	main.queue_free()
	return (
		_assert(entry_ok, "hint button stays in play controls with a Korean label")
		and _assert(player_best_move_ok, "hint highlights exactly one legal best move for the player")
		and _assert(state_unchanged_ok, "hint search leaves the game state unchanged")
		and _assert(move_clears_hint_ok, "the next board interaction clears the one-shot hint")
		and _assert(ai_pending_disabled_ok, "hint disables while ai move is pending")
		and _assert(input_locked_disabled_ok, "hint disables while input is locked")
		and _assert(game_over_disabled_ok, "hint disables after game over")
		and _assert(ai_turn_disabled_ok, "hint disables outside the player turn")
		and _assert(no_move_safe_ok, "hint safely ignores a pass state without legal moves")
		and _assert(english_label_ok, "hint renders the English label")
		and _assert(i18n_ok, "hint has Korean and English strings")
	)


func _test_how_to_play_sheet() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_how_to_play_%s.json" % suffix
	var save_path := "user://save_how_to_play_%s.json" % suffix
	var skip_prefs_path := "user://prefs_how_to_play_skip_%s.json" % suffix
	var skip_save_path := "user://save_how_to_play_skip_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)
	_rm_user(skip_prefs_path)
	_rm_user(skip_save_path)

	var first = main_scene.instantiate()
	first._prefs_path = prefs_path
	first._save_path = save_path
	add_child(first)
	await get_tree().process_frame
	await get_tree().process_frame

	var state_before := JSON.stringify(ReversiEngine.state_to_save_dict(first.state))
	var stored_after_first_show: Dictionary = first._load_preferences()
	var first_show_once_ok: bool = first.how_to_play_overlay != null \
		and first.how_to_play_overlay.visible \
		and first.how_to_play_is_first_run \
		and !bool(first.preferences.get("how_to_play_seen", false)) \
		and !bool(stored_after_first_show.get("how_to_play_seen", false))
	var settings_only_entry_ok: bool = first.how_to_play_entry_button != null \
		and first.settings_panel.is_ancestor_of(first.how_to_play_entry_button) \
		and !first.gameplay_strip.is_ancestor_of(first.how_to_play_entry_button)
	var rule_content_ok: bool = true
	for rule_name in ["Place", "Flip", "Pass", "Finish"]:
		rule_content_ok = rule_content_ok \
			and first.how_to_play_content.find_child("HowToPlayStep%s" % rule_name, true, false) != null
	var i18n_ok: bool = true
	for locale_id in ["ko", "en"]:
		var locale_texts: Dictionary = MainScript.TEXT[locale_id]
		for key in [
			"how_to_play_entry",
			"how_to_play_title",
			"how_to_play_place_title",
			"how_to_play_place_body",
			"how_to_play_flip_title",
			"how_to_play_flip_body",
			"how_to_play_pass_title",
			"how_to_play_pass_body",
			"how_to_play_finish_title",
			"how_to_play_finish_body",
			"how_to_play_previous",
			"how_to_play_next",
			"how_to_play_done",
			"how_to_play_skip",
			"how_to_play_progress",
		]:
			i18n_ok = i18n_ok and locale_texts.has(key) and !str(locale_texts[key]).is_empty()
	var scroll_ok: bool = first.how_to_play_scroll != null \
		and first.how_to_play_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO \
		and first.how_to_play_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED \
		and first.how_to_play_scroll.is_ancestor_of(first.how_to_play_content) \
		and first.how_to_play_content.custom_minimum_size.y \
			> first.how_to_play_scroll.custom_minimum_size.y
	var step_controls_ok: bool = first.how_to_play_step_cards.size() == 4 \
		and first.how_to_play_step_index == 0 \
		and first.how_to_play_previous_button.disabled \
		and first.how_to_play_skip_button.visible \
		and first.how_to_play_progress_label.text == "1 / 4"
	var step_highlights_ok := true
	for step_index in range(4):
		step_highlights_ok = step_highlights_ok \
			and first.how_to_play_step_index == step_index \
			and _visible_tutorial_highlight_count(first) > 0 \
			and first.how_to_play_step_cards[step_index].modulate.a > 0.9
		if step_index < 3:
			first.how_to_play_next_button.pressed.emit()
			await get_tree().process_frame
	var final_step_ok: bool = first.how_to_play_next_button.text \
		== str(MainScript.TEXT["ko"]["how_to_play_done"]) \
		and !first.how_to_play_previous_button.disabled
	first.how_to_play_next_button.pressed.emit()
	await get_tree().process_frame
	var stored_after_completion: Dictionary = first._load_preferences()
	var completion_persists_ok: bool = !first.how_to_play_overlay.visible \
		and bool(first.preferences.get("how_to_play_seen", false)) \
		and bool(stored_after_completion.get("how_to_play_seen", false)) \
		and _visible_tutorial_highlight_count(first) == 0

	first._show_settings_menu()
	first.how_to_play_entry_button.pressed.emit()
	await get_tree().process_frame
	var settings_reopen_ok: bool = first.how_to_play_overlay.visible \
		and !first.settings_overlay.visible \
		and !first.how_to_play_skip_button.visible \
		and first.how_to_play_step_index == 0
	first.how_to_play_close_button.pressed.emit()
	await get_tree().process_frame
	var close_button_ok: bool = !first.how_to_play_overlay.visible \
		and _visible_tutorial_highlight_count(first) == 0
	first._show_settings_menu()
	first.how_to_play_entry_button.pressed.emit()
	await get_tree().process_frame
	var panel_rect: Rect2 = first.how_to_play_panel.get_global_rect()
	first._on_how_to_play_overlay_gui_input(_make_left_click(panel_rect.get_center()))
	await get_tree().process_frame
	var inside_tap_ok: bool = first.how_to_play_overlay.visible
	first._on_how_to_play_overlay_gui_input(_make_left_click(Vector2(
		maxf(0.0, panel_rect.position.x - 12.0),
		panel_rect.position.y + 12.0,
	)))
	await get_tree().process_frame
	var outside_tap_ok: bool = !first.how_to_play_overlay.visible
	var state_unchanged_ok: bool = state_before \
		== JSON.stringify(ReversiEngine.state_to_save_dict(first.state))
	first.queue_free()
	await get_tree().process_frame

	var restored = main_scene.instantiate()
	restored._prefs_path = prefs_path
	restored._save_path = save_path
	add_child(restored)
	await get_tree().process_frame
	await get_tree().process_frame
	var no_repeat_ok: bool = restored.how_to_play_overlay != null \
		and !restored.how_to_play_overlay.visible
	restored._show_settings_menu()
	restored.how_to_play_entry_button.pressed.emit()
	await get_tree().process_frame
	var later_reopen_ok: bool = restored.how_to_play_overlay.visible \
		and !restored.settings_overlay.visible
	restored.queue_free()
	await get_tree().process_frame

	var skipped = main_scene.instantiate()
	skipped._prefs_path = skip_prefs_path
	skipped._save_path = skip_save_path
	add_child(skipped)
	await get_tree().process_frame
	await get_tree().process_frame
	var skip_control_ok: bool = skipped.how_to_play_overlay.visible \
		and skipped.how_to_play_skip_button.visible
	skipped.how_to_play_skip_button.pressed.emit()
	await get_tree().process_frame
	var skip_stored: Dictionary = skipped._load_preferences()
	var skip_persists_ok: bool = !skipped.how_to_play_overlay.visible \
		and bool(skip_stored.get("how_to_play_seen", false))
	skipped.queue_free()
	await get_tree().process_frame

	var skipped_restored = main_scene.instantiate()
	skipped_restored._prefs_path = skip_prefs_path
	skipped_restored._save_path = skip_save_path
	add_child(skipped_restored)
	await get_tree().process_frame
	await get_tree().process_frame
	var skip_no_repeat_ok: bool = !skipped_restored.how_to_play_overlay.visible
	skipped_restored.queue_free()
	await get_tree().process_frame
	_rm_user(prefs_path)
	_rm_user(save_path)
	_rm_user(skip_prefs_path)
	_rm_user(skip_save_path)
	return (
		_assert(first_show_once_ok, "how-to opens once without completing first-run state early")
		and _assert(settings_only_entry_ok, "how-to entry stays inside settings instead of the main HUD")
		and _assert(rule_content_ok, "how-to contains placement flip pass and winner steps")
		and _assert(i18n_ok, "how-to provides complete Korean and English copy")
		and _assert(scroll_ok, "how-to content scrolls vertically on constrained screens")
		and _assert(step_controls_ok, "how-to starts a four-step sequence with skip and navigation")
		and _assert(step_highlights_ok, "how-to highlights board cells for every rule step")
		and _assert(final_step_ok, "how-to final step exposes the localized completion action")
		and _assert(completion_persists_ok, "how-to completion saves the first-run flag and clears highlights")
		and _assert(close_button_ok, "how-to close button hides the sheet")
		and _assert(settings_reopen_ok, "how-to reopens from settings")
		and _assert(inside_tap_ok, "how-to panel tap keeps the sheet open")
		and _assert(outside_tap_ok, "how-to outside tap closes the sheet")
		and _assert(state_unchanged_ok, "how-to interactions preserve the current game state")
		and _assert(no_repeat_ok, "how-to does not auto-open after the first game")
		and _assert(later_reopen_ok, "how-to remains available from settings after first launch")
		and _assert(skip_control_ok, "how-to exposes skip during first-run onboarding")
		and _assert(skip_persists_ok, "how-to skip saves completion immediately")
		and _assert(skip_no_repeat_ok, "skipped how-to does not auto-open after restart")
	)


func _test_settings_persist_immediately() -> bool:
	var prefs_path := "user://prefs_immediate_%s.json" % str(OS.get_process_id())
	_rm_user(prefs_path)
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame
	main._prefs_path = prefs_path

	main._set_theme("arctic")
	await get_tree().process_frame
	main._set_stone_theme("ember")
	await get_tree().process_frame
	main._set_locale("en")
	await get_tree().process_frame
	main._set_difficulty_from_choice("HARD")
	await get_tree().process_frame
	main.sound_toggle.button_pressed = false
	await get_tree().process_frame
	main.music_toggle.button_pressed = false
	await get_tree().process_frame

	var stored: Dictionary = main._load_preferences()
	var stored_settings: Dictionary = stored.get("settings", {})
	var stored_ok := str(stored.get("difficulty", "")) == "HARD" \
		and str(stored_settings.get("theme", "")) == "arctic" \
		and str(stored_settings.get("stone_theme", "")) == "ember" \
		and str(stored_settings.get("locale", "")) == "en" \
		and !bool(stored_settings.get("sound", true)) \
		and !bool(stored_settings.get("music", true))
	main.queue_free()
	_rm_user(prefs_path)
	return _assert(stored_ok, "every user setting writes preferences immediately")


func _test_difficulty_description_subtitle() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_difficulty_description_%s.json" % suffix
	var save_path := "user://save_difficulty_description_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)

	var description_keys := [
		"difficulty_easy_description",
		"difficulty_medium_description",
		"difficulty_hard_description",
	]
	var catalogs_ok := true
	for locale_id in ["ko", "en"]:
		var catalog: Dictionary = MainScript.TEXT[locale_id]
		var descriptions: Array[String] = []
		for key in description_keys:
			var description := str(catalog.get(key, ""))
			catalogs_ok = !description.is_empty() and !descriptions.has(description) and catalogs_ok
			descriptions.append(description)

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var section: Node = main.settings_panel.find_child("DifficultySection", true, false)
	var subtitle := main.difficulty_subtitle_label as Label
	var settings_only_ok: bool = section != null \
		and subtitle != null \
		and subtitle.get_parent() == section \
		and main.settings_panel.is_ancestor_of(subtitle) \
		and !subtitle.is_visible_in_tree()

	main._show_settings_menu()
	await get_tree().process_frame
	var korean_updates_ok: bool = main.settings_overlay.visible
	for index in range(MainScript.DIFFICULTY_IDS.size()):
		var entry: Dictionary = main.difficulty_buttons[index]
		var button := entry.get("button") as Button
		button.emit_signal("pressed")
		await get_tree().process_frame
		var difficulty_id := str(MainScript.DIFFICULTY_IDS[index])
		korean_updates_ok = main.difficulty_subtitle_label.text \
			== str(MainScript.TEXT["ko"][description_keys[index]]) \
			and main.difficulty == difficulty_id \
			and _choice_group_has_active_id(main.difficulty_buttons, difficulty_id) \
			and korean_updates_ok

	main._set_locale("en", false)
	await get_tree().process_frame
	var english_updates_ok: bool = main.settings_overlay.visible
	for index in range(MainScript.DIFFICULTY_IDS.size()):
		var entry: Dictionary = main.difficulty_buttons[index]
		var button := entry.get("button") as Button
		button.emit_signal("pressed")
		await get_tree().process_frame
		var difficulty_id := str(MainScript.DIFFICULTY_IDS[index])
		english_updates_ok = main.difficulty_subtitle_label.text \
			== str(MainScript.TEXT["en"][description_keys[index]]) \
			and main.difficulty == difficulty_id \
			and _choice_group_has_active_id(main.difficulty_buttons, difficulty_id) \
			and english_updates_ok

	main._hide_settings_menu()
	await get_tree().process_frame
	var hidden_ok: bool = !main.difficulty_subtitle_label.is_visible_in_tree()
	main._show_settings_menu()
	await get_tree().process_frame
	var reopen_ok: bool = main.difficulty == "HARD" \
		and main.difficulty_subtitle_label.is_visible_in_tree() \
		and main.difficulty_subtitle_label.text \
			== str(MainScript.TEXT["en"]["difficulty_hard_description"])

	main.queue_free()
	await get_tree().process_frame
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(catalogs_ok, "difficulty descriptions provide distinct Korean and English copy")
		and _assert(settings_only_ok, "difficulty subtitle stays inside the existing settings section")
		and _assert(korean_updates_ok, "difficulty buttons update the Korean subtitle immediately")
		and _assert(english_updates_ok, "difficulty buttons update the English subtitle immediately")
		and _assert(hidden_ok, "difficulty subtitle is not a persistent HUD element")
		and _assert(reopen_ok, "difficulty subtitle matches the current choice when settings reopen")
	)


func _test_anti_reversi_ui() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_anti_reversi_%s.json" % suffix
	var save_path := "user://save_anti_reversi_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var section: Node = main.settings_panel.find_child("VariantSection", true, false)
	var standard_button := main.variant_buttons[0].get("button") as Button
	var anti_button := main.variant_buttons[1].get("button") as Button
	var settings_only_ok: bool = main.variant_buttons.size() == 2 \
		and section != null \
		and standard_button != null \
		and anti_button != null \
		and section.is_ancestor_of(standard_button) \
		and section.is_ancestor_of(anti_button) \
		and main.settings_panel.is_ancestor_of(section) \
		and !standard_button.is_visible_in_tree()
	var labels_ok: bool = str(MainScript.TEXT["ko"].get("variant_setting", "")) == "규칙" \
		and str(MainScript.TEXT["ko"].get("variant_standard", "")) == "표준" \
		and str(MainScript.TEXT["ko"].get("variant_anti", "")) == "역" \
		and str(MainScript.TEXT["en"].get("variant_setting", "")) == "RULES" \
		and str(MainScript.TEXT["en"].get("variant_standard", "")) == "STANDARD" \
		and str(MainScript.TEXT["en"].get("variant_anti", "")) == "ANTI"

	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	ReversiEngine.play_move(main.state, 2, 3)
	main._render()
	var active_game_had_history: bool = main.state.get("move_history", []).size() == 1
	main._show_settings_menu()
	await get_tree().process_frame
	anti_button.emit_signal("pressed")
	await get_tree().process_frame
	var fresh_counts := ReversiEngine.count_pieces(main.state.get("board", []))
	var stored: Dictionary = main._load_preferences()
	var change_restarts_ok: bool = active_game_had_history \
		and main._current_variant() == ReversiEngine.VARIANT_ANTI \
		and main.state.get("move_history", []).is_empty() \
		and int(fresh_counts["black"]) == 2 \
		and int(fresh_counts["white"]) == 2 \
		and main.settings_overlay.visible \
		and _choice_group_has_active_id(main.variant_buttons, ReversiEngine.VARIANT_ANTI)
	var persistence_ok: bool = str(stored.get("settings", {}).get("variant", "")) \
		== ReversiEngine.VARIANT_ANTI

	var majority_board: Array = []
	for x in range(ReversiEngine.BOARD_SIZE):
		var row: Array = []
		for y in range(ReversiEngine.BOARD_SIZE):
			row.append(
				ReversiEngine.WHITE
				if x == ReversiEngine.BOARD_SIZE - 1 and y == ReversiEngine.BOARD_SIZE - 1
				else ReversiEngine.BLACK
			)
		majority_board.append(row)
	var anti_result := ReversiEngine.create_state_from_board(
		majority_board,
		ReversiEngine.BLACK,
		ReversiEngine.WHITE,
		"MEDIUM",
	)
	var result_settings: Dictionary = main._current_settings()
	result_settings["variant"] = ReversiEngine.VARIANT_ANTI
	anti_result["settings"] = result_settings
	ReversiEngine._refresh_result(anti_result)
	main.state = anti_result
	main.player_stone = ReversiEngine.WHITE
	main._interstitial_shown_this_game = true
	main._result_animation_played_this_game = true
	main._update_result_overlay(false)
	var result_overlay_ok: bool = int(main.state.get("winner", ReversiEngine.NONE)) \
		== ReversiEngine.WHITE \
		and main.result_overlay.visible \
		and main.result_title_label.text == main._t("result_win") \
		and main.result_detail_label.text == main._t("result_detail") % [63, 1]

	main.queue_free()
	await get_tree().process_frame
	var restored = main_scene.instantiate()
	restored._prefs_path = prefs_path
	restored._save_path = save_path
	add_child(restored)
	await get_tree().process_frame
	await get_tree().process_frame
	var restore_ok: bool = restored._current_variant() == ReversiEngine.VARIANT_ANTI \
		and _choice_group_has_active_id(restored.variant_buttons, ReversiEngine.VARIANT_ANTI)
	restored.queue_free()
	await get_tree().process_frame
	_rm_user(prefs_path)
	_rm_user(save_path)

	return (
		_assert(settings_only_ok, "variant selector stays inside the existing settings overlay")
		and _assert(labels_ok, "variant selector has complete Korean and English labels")
		and _assert(change_restarts_ok, "changing variant replaces an active game and keeps settings open")
		and _assert(persistence_ok, "anti variant saves immediately in preferences")
		and _assert(result_overlay_ok, "anti winner drives the existing result overlay verdict")
		and _assert(restore_ok, "anti variant restores after restart")
	)


func _test_puzzle_mode_ui_and_save_isolation() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_puzzle_%s.json" % suffix
	var save_path := "user://save_puzzle_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	main._finish_how_to_play()
	var standard_settings: Dictionary = main._current_settings()
	standard_settings["reduce_motion"] = true
	main.state["settings"] = standard_settings
	main._start_new_game(ReversiEngine.BLACK)
	var standard_save_before := FileAccess.get_file_as_string(save_path)
	var standard_stats := ReversiEngine.normalize_stats(main.state.get("stats", {}))

	var section: Node = main.settings_panel.find_child("PuzzleSection", true, false)
	var settings_depth_ok: bool = section != null \
		and main.puzzle_entry_button != null \
		and section.is_ancestor_of(main.puzzle_entry_button) \
		and main.settings_panel.is_ancestor_of(section) \
		and !main.puzzle_entry_button.is_visible_in_tree()
	main._show_settings_menu()
	main.puzzle_entry_button.emit_signal("pressed")
	await get_tree().process_frame
	var selector_ok: bool = main.puzzle_overlay.visible \
		and !main.settings_overlay.visible \
		and main.puzzle_panel != null \
		and main.puzzle_cards.size() == PuzzleCatalog.all().size() \
		and main.puzzle_cards.size() >= 3
	var localized_catalog_ok := true
	var puzzle_text_keys := [
		"puzzle_section",
		"puzzle_entry",
		"puzzle_select_title",
		"puzzle_select_intro",
		"puzzle_start",
		"puzzle_complete",
		"puzzle_failed",
		"puzzle_standard_game",
		"puzzle_corner_title",
		"puzzle_corner_description",
		"puzzle_corner_goal",
		"puzzle_comeback_title",
		"puzzle_comeback_description",
		"puzzle_comeback_goal",
		"puzzle_white_title",
		"puzzle_white_description",
		"puzzle_white_goal",
	]
	for locale_id in ["ko", "en", "ja"]:
		var catalog: Dictionary = MainScript.TEXT[locale_id]
		for key in puzzle_text_keys:
			localized_catalog_ok = !str(catalog.get(key, "")).is_empty() \
				and localized_catalog_ok
	var korean_cards_ok := true
	for entry_value in main.puzzle_cards:
		var entry: Dictionary = entry_value
		var definition := PuzzleCatalog.get_by_id(str(entry.get("id", "")))
		var title_label := entry.get("title_label") as Label
		var description_label := entry.get("description_label") as Label
		var goal_label := entry.get("goal_label") as Label
		korean_cards_ok = title_label != null \
			and description_label != null \
			and goal_label != null \
			and title_label.text == str(MainScript.TEXT["ko"][definition["title_key"]]) \
			and description_label.text \
				== str(MainScript.TEXT["ko"][definition["description"]]) \
			and goal_label.text == str(MainScript.TEXT["ko"][definition["goal_key"]]) \
			and korean_cards_ok

	var corner_entry: Dictionary = main.puzzle_cards[0]
	var corner_start_button := corner_entry.get("start_button") as Button
	corner_start_button.emit_signal("pressed")
	await get_tree().process_frame
	var corner_definition := PuzzleCatalog.get_by_id("corner_capture")
	var expected_board := PuzzleCatalog.board_from_definition(corner_definition)
	var puzzle_loaded_ok: bool = main._active_puzzle_id == "corner_capture" \
		and !main.puzzle_overlay.visible \
		and main.state.get("board", []) == expected_board \
		and int(main.state.get("current_turn", ReversiEngine.NONE)) \
			== int(corner_definition["current_turn"]) \
		and str(main.state.get("difficulty", "")) == str(corner_definition["difficulty"])
	var ad_probe := _InterstitialProbe.new()
	main._interstitial_probe = Callable(ad_probe, "request")
	var corner_move := ReversiEngine.play_move(main.state, 0, 0)
	var goal_result: Dictionary = main._evaluate_active_puzzle_goal()
	main._save_state()
	main._render()
	await get_tree().process_frame
	var standard_save_after_puzzle := FileAccess.get_file_as_string(save_path)
	var puzzle_result_ok: bool = bool(corner_move.get("ok", false)) \
		and bool(goal_result.get("complete", false)) \
		and bool(goal_result.get("success", false)) \
		and main._puzzle_completed \
		and main._puzzle_success \
		and main.result_overlay.visible \
		and main.result_title_label.text == str(MainScript.TEXT["ko"]["puzzle_complete"]) \
		and main.result_stats_label.text == str(MainScript.TEXT["ko"]["puzzle_corner_goal"]) \
		and main.result_restart_button.text \
			== str(MainScript.TEXT["ko"]["puzzle_standard_game"]) \
		and main.result_replay_button.disabled \
		and ad_probe.requests == 0
	var save_isolation_ok: bool = standard_save_before == standard_save_after_puzzle \
		and ReversiEngine.normalize_stats(main.state.get("stats", {})) == standard_stats

	main._start_new_game(ReversiEngine.BLACK)
	await get_tree().process_frame
	var restored_standard: Dictionary = main._load_state()
	var restored_counts := ReversiEngine.count_pieces(restored_standard.get("board", []))
	var standard_return_ok: bool = !main._is_puzzle_active() \
		and !main.result_overlay.visible \
		and main.state.get("move_history", []).is_empty() \
		and int(restored_counts.get("black", -1)) == 2 \
		and int(restored_counts.get("white", -1)) == 2 \
		and ReversiEngine.get_board_size(restored_standard.get("board", [])) == 8 \
		and !restored_standard.has("puzzle_id")

	main.queue_free()
	await get_tree().process_frame
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(settings_depth_ok, "puzzle entry stays inside the settings sheet")
		and _assert(selector_ok and korean_cards_ok, "puzzle entry opens a localized three-card selector modal")
		and _assert(localized_catalog_ok, "puzzle labels descriptions and goals cover every supported locale")
		and _assert(puzzle_loaded_ok, "puzzle selection creates the configured board turn and difficulty state")
		and _assert(puzzle_result_ok, "puzzle goal reuses the result overlay without stats ads or replay")
		and _assert(save_isolation_ok, "puzzle play leaves the standard save and stats unchanged")
		and _assert(standard_return_ok, "puzzle result returns to a persisted standard new game")
	)


func _test_board_size_ui() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_board_size_%s.json" % suffix
	var save_path := "user://save_board_size_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame
	main._prefs_path = prefs_path
	main._save_path = save_path
	main.state = ReversiEngine.create_new_game(
		ReversiEngine.BLACK,
		"MEDIUM",
		8,
	)
	main._build_ui()
	main._render()
	await get_tree().process_frame

	var defaults_ok: bool = (
		main.board_size_buttons.size() == 3
		and _choice_group_has_active_id(main.board_size_buttons, "8")
		and str(MainScript.TEXT["ko"].get("board_size_setting", "")) == "보드 크기"
		and str(MainScript.TEXT["en"].get("board_size_setting", "")) == "BOARD SIZE"
	)
	main._show_settings_menu()
	await get_tree().process_frame
	var first_size_entry: Dictionary = main.board_size_buttons[0]
	var first_size_button := first_size_entry.get("button") as Button
	var settings_only_ok: bool = (
		first_size_button != null
		and main.settings_panel.is_ancestor_of(first_size_button)
		and first_size_button.is_visible_in_tree()
	)

	main._set_board_size_from_choice("6")
	await get_tree().process_frame
	var six_board: Array = main.state.get("board", [])
	var six_ok: bool = (
		ReversiEngine.get_board_size(six_board) == 6
		and main.cell_buttons.size() == 6
		and main.cell_buttons[0].size() == 6
		and main.cell_buttons[0][0].custom_minimum_size.x
			== MainScript.cell_size_for_board(6)
		and _choice_group_has_active_id(main.board_size_buttons, "6")
		and main.state.get("move_history", []).is_empty()
		and main.settings_overlay.visible
	)

	main._set_board_size_from_choice("10")
	await get_tree().process_frame
	var stored: Dictionary = main._load_preferences()
	var restored: Dictionary = main._load_state()
	var ten_board: Array = main.state.get("board", [])
	var ten_ok: bool = (
		ReversiEngine.get_board_size(ten_board) == 10
		and main.cell_buttons.size() == 10
		and main.cell_buttons[0].size() == 10
		and main.cell_buttons[0][0].custom_minimum_size.x
			== MainScript.cell_size_for_board(10)
		and MainScript.cell_size_for_board(6) > MainScript.cell_size_for_board(8)
		and MainScript.cell_size_for_board(8) > MainScript.cell_size_for_board(10)
		and _choice_group_has_active_id(main.board_size_buttons, "10")
		and int(stored.get("settings", {}).get("board_size", 0)) == 10
		and ReversiEngine.get_board_size(restored.get("board", [])) == 10
	)
	main._hide_settings_menu()
	await get_tree().process_frame
	var hidden_with_menu_ok := !_choice_group_first_button_visible(
		main.board_size_buttons,
	)

	main.queue_free()
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(defaults_ok, "ui exposes 6 8 and 10 board sizes with i18n labels")
		and _assert(settings_only_ok, "ui keeps board size controls inside settings")
		and _assert(six_ok, "ui board size selection starts and renders a 6x6 game")
		and _assert(ten_ok, "ui board size selection persists and renders a 10x10 game")
		and _assert(hidden_with_menu_ok, "ui hides board size controls with settings")
	)


func _test_board_coordinate_labels() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_board_coordinates_%s.json" % suffix
	var save_path := "user://save_board_coordinates_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var default_mapping_ok: bool = main.board_column_labels.size() == 8 \
		and main.board_row_labels.size() == 8 \
		and (main.board_column_labels[0] as Label).text == "A" \
		and (main.board_column_labels[7] as Label).text == "H" \
		and (main.board_row_labels[0] as Label).text == "1" \
		and (main.board_row_labels[7] as Label).text == "8"
	var aligned_ok := true
	var input_safe_ok := true
	for index in range(8):
		var column_label := main.board_column_labels[index] as Label
		var row_label := main.board_row_labels[index] as Label
		var column_cell := main.cell_buttons[0][index] as Button
		var row_cell := main.cell_buttons[index][0] as Button
		aligned_ok = aligned_ok \
			and absf(column_label.get_global_rect().get_center().x \
				- column_cell.get_global_rect().get_center().x) < 0.5 \
			and absf(row_label.get_global_rect().get_center().y \
				- row_cell.get_global_rect().get_center().y) < 0.5
		input_safe_ok = input_safe_ok \
			and column_label.mouse_filter == Control.MOUSE_FILTER_IGNORE \
			and row_label.mouse_filter == Control.MOUSE_FILTER_IGNORE \
			and !column_cell.is_ancestor_of(column_label) \
			and !row_cell.is_ancestor_of(row_label)

	var first_label_id := (main.board_column_labels[0] as Label).get_instance_id()
	var theme_readability_ok := true
	for theme_id in ["classic", "arctic", "ember"]:
		main._set_theme(theme_id, false)
		await get_tree().process_frame
		var label := main.board_column_labels[0] as Label
		var text_color: Color = label.get_theme_color("font_color")
		var frame_color: Color = main._theme_color("board_frame")
		theme_readability_ok = theme_readability_ok \
			and main.board_column_labels.size() == 8 \
			and main.board_row_labels.size() == 8 \
			and label.get_theme_font("font") == MainScript.UI_FONT \
			and text_color == main._theme_color("text_muted") \
			and text_color.get_luminance() - frame_color.get_luminance() > 0.45
	var theme_rebuild_ok: bool = (main.board_column_labels[0] as Label).get_instance_id() \
		!= first_label_id
	var before_locale_id := (main.board_column_labels[0] as Label).get_instance_id()
	main._set_locale("en", false)
	await get_tree().process_frame
	var locale_rebuild_ok: bool = (main.board_column_labels[0] as Label).get_instance_id() \
		!= before_locale_id \
		and (main.board_column_labels[0] as Label).text == "A" \
		and (main.board_column_labels[7] as Label).text == "H"

	main._set_board_size_from_choice("6")
	await get_tree().process_frame
	var six_size_ok: bool = main.board_column_labels.size() == 6 \
		and main.board_row_labels.size() == 6 \
		and (main.board_column_labels[5] as Label).text == "F" \
		and (main.board_row_labels[5] as Label).text == "6"
	main._set_board_size_from_choice("10")
	await get_tree().process_frame
	var ten_size_ok: bool = main.board_column_labels.size() == 10 \
		and main.board_row_labels.size() == 10 \
		and (main.board_column_labels[9] as Label).text == "J" \
		and (main.board_row_labels[9] as Label).text == "10"

	main.queue_free()
	await get_tree().process_frame
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(default_mapping_ok, "board coordinates map A-H and 1-8 from the top-left")
		and _assert(aligned_ok, "board coordinates align with cell centers")
		and _assert(input_safe_ok, "board coordinates ignore input outside cell buttons")
		and _assert(theme_readability_ok, "board coordinates use the UI font and readable muted theme colors")
		and _assert(theme_rebuild_ok, "board coordinates rebuild after every board theme change")
		and _assert(locale_rebuild_ok, "board coordinates rebuild after a locale change")
		and _assert(six_size_ok, "board coordinates adapt to the 6x6 board")
		and _assert(ten_size_ok, "board coordinates adapt to the 10x10 board")
	)


func _test_adaptive_vertical_layout() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var baseline_window := Vector2i(720, 1280)
	var tall_window := Vector2i(1320, 2868)
	var narrow_tall_window := Vector2i(640, 1280)
	var baseline_canvas: Vector2 = MainScript.expanded_canvas_size(baseline_window)
	var tall_canvas: Vector2 = MainScript.expanded_canvas_size(tall_window)
	var narrow_canvas: Vector2 = MainScript.expanded_canvas_size(narrow_tall_window)
	var baseline_math_ok: bool = baseline_canvas == Vector2(720, 1280) \
		and MainScript.adaptive_vertical_surplus(baseline_window) == 0
	var tall_surplus: int = MainScript.adaptive_vertical_surplus(tall_window)
	var tall_math_ok: bool = tall_canvas.y > baseline_canvas.y \
		and tall_surplus == 284
	var board_width: int = MainScript.board_frame_size_for_board(8)
	var narrow_width_ok: bool = board_width <= int(narrow_canvas.x) - 24

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame
	var root := main.find_child("GameRoot", true, false) as VBoxContainer
	var board_frame := main.find_child("BoardFrame", true, false) as PanelContainer
	main._update_adaptive_vertical_spacing(baseline_window)
	await get_tree().process_frame
	var baseline_y: float = main.gameplay_strip.position.y
	var baseline_layout_ok: bool = main.adaptive_play_focus_slot.get_theme_constant("margin_top") == 0 \
		and root != null \
		and root.get_child_count() == 7 \
		and root.is_ancestor_of(main.replay_controls) \
		and !main.replay_controls.visible \
		and main.adaptive_play_focus_slot.get_child_count() == 1 \
		and main.adaptive_play_focus_slot.get_child(0) == main.gameplay_strip
	main._update_adaptive_vertical_spacing(tall_window)
	await get_tree().process_frame
	var tall_shift_ok: bool = main.adaptive_play_focus_slot.get_theme_constant("margin_top") == tall_surplus \
		and is_equal_approx(main.gameplay_strip.position.y - baseline_y, float(tall_surplus))
	var board_fit_ok: bool = board_frame != null \
		and int(board_frame.custom_minimum_size.x) == board_width \
		and board_frame.size_flags_horizontal == Control.SIZE_SHRINK_CENTER
	main._update_adaptive_vertical_spacing(baseline_window)
	main.queue_free()
	return (
		_assert(baseline_math_ok and baseline_layout_ok, "adaptive layout preserves the 720 by 1280 baseline")
		and _assert(tall_math_ok and tall_shift_ok, "adaptive layout moves play controls through tall-screen surplus")
		and _assert(narrow_width_ok and board_fit_ok, "adaptive layout keeps the board inside narrow screens")
	)


func _test_accessibility_settings_and_reduced_motion() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var prefs_path := "user://prefs_accessibility_%s.json" % str(OS.get_process_id())
	_rm_user(prefs_path)
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame
	main._prefs_path = prefs_path
	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	main._build_ui()
	main._render()
	await get_tree().process_frame

	var default_settings := ReversiEngine.default_settings()
	var defaults_ok := is_equal_approx(float(default_settings.get("font_scale", 0.0)), 1.0) \
		and !bool(default_settings.get("reduce_motion", true))
	var korean_labels_ok := str(MainScript.TEXT["ko"].get("font_scale_setting", "")) == "글자 크기" \
		and str(MainScript.TEXT["ko"].get("reduce_motion", "")) == "모션 줄이기"
	var english_labels_ok := str(MainScript.TEXT["en"].get("font_scale_setting", "")) == "TEXT SIZE" \
		and str(MainScript.TEXT["en"].get("reduce_motion", "")) == "REDUCE MOTION"
	var base_score_size: int = main.player_score_label.get_theme_font_size("font_size")
	var base_status_size: int = main.status_label.get_theme_font_size("font_size")
	var base_result_size: int = main.result_title_label.get_theme_font_size("font_size")

	main._set_font_scale_from_choice("1.3")
	await get_tree().process_frame
	var scaled_text_ok: bool = main.player_score_label.get_theme_font_size("font_size") > base_score_size \
		and main.status_label.get_theme_font_size("font_size") > base_status_size \
		and main.result_title_label.get_theme_font_size("font_size") > base_result_size
	var scale_control_ok: bool = main.font_scale_buttons.size() == 3 \
		and _choice_group_has_active_id(main.font_scale_buttons, "1.3")

	main.reduce_motion_toggle.button_pressed = true
	await get_tree().process_frame
	var stored: Dictionary = main._load_preferences()
	var stored_settings: Dictionary = stored.get("settings", {})
	var persistence_ok := is_equal_approx(float(stored_settings.get("font_scale", 0.0)), 1.3) \
		and bool(stored_settings.get("reduce_motion", false))

	var motion_settings: Dictionary = main.state.get("settings", {})
	motion_settings["sound"] = false
	main.state["settings"] = motion_settings
	var before_board := ReversiEngine.clone_board(main.state["board"])
	var move_result := ReversiEngine.play_move(main.state, 2, 3)
	main._motion_tween_count = 0
	await main._render_with_animation(before_board, move_result)
	main._pulse_cell(0, 0, Color.RED)
	var counts := ReversiEngine.count_pieces(main.state["board"])
	var reduced_motion_ok: bool = main._motion_tween_count == 0 \
		and !main.input_locked \
		and main.cell_buttons[0][0].modulate == Color.WHITE
	var score_state_ok: bool = int(counts.get("black", 0)) == 4 \
		and int(counts.get("white", 0)) == 1 \
		and main.player_score_label.text == "4" \
		and main.ai_score_label.text == "1"
	var turn_state_ok: bool = main.turn_badge.text == main._t("turn_ai")
	var expected_legal_moves := ReversiEngine.get_valid_moves(
		main.state["board"],
		int(main.state["current_turn"]),
	)
	var legal_moves_state_ok: bool = main.state.get("valid_moves", []) == expected_legal_moves \
		and main.footer_secondary_label.text == main._t("focus_valid") % expected_legal_moves.size() \
		and _visible_hint_count(main) == 0
	var board_state_ok: bool = main.cell_piece_views[2][3].texture == main._texture_for_stone(ReversiEngine.BLACK) \
		and main.cell_piece_views[3][3].texture == main._texture_for_stone(ReversiEngine.BLACK)

	main._set_locale("en", false)
	await get_tree().process_frame
	var large_scale_entry: Dictionary = main.font_scale_buttons[2]
	var large_scale_button := large_scale_entry.get("button") as Button
	var rendered_english_labels_ok: bool = main.reduce_motion_toggle.text == "REDUCE MOTION" \
		and large_scale_button != null \
		and large_scale_button.text == "130%"
	main.queue_free()
	_rm_user(prefs_path)
	return (
		_assert(defaults_ok, "accessibility settings have safe defaults")
		and _assert(korean_labels_ok and english_labels_ok, "accessibility labels exist in Korean and English")
		and _assert(scaled_text_ok, "font scale enlarges score status and result text")
		and _assert(scale_control_ok, "font scale control tracks the selected scale")
		and _assert(persistence_ok, "accessibility settings persist in preferences")
		and _assert(reduced_motion_ok, "reduced motion skips move and pulse tweens")
		and _assert(score_state_ok, "reduced motion renders the final score")
		and _assert(turn_state_ok, "reduced motion renders the final turn badge")
		and _assert(legal_moves_state_ok, "reduced motion renders final legal moves")
		and _assert(board_state_ok, "reduced motion renders the final board")
		and _assert(rendered_english_labels_ok, "accessibility controls render English labels")
	)


func _test_high_contrast_accessibility() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_high_contrast_%s.json" % suffix
	var save_path := "user://save_high_contrast_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)

	var defaults := ReversiEngine.default_settings()
	var normalization_ok := !bool(defaults.get("high_contrast", true)) \
		and !bool(ReversiEngine.normalize_settings({}).get("high_contrast", true)) \
		and bool(ReversiEngine.normalize_settings({"high_contrast": true}).get("high_contrast", false))
	var labels_ok := str(MainScript.TEXT["ko"].get("high_contrast", "")) == "고대비 색상" \
		and str(MainScript.TEXT["en"].get("high_contrast", "")) == "HIGH CONTRAST"

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	var default_visuals_ok: bool = main._board_cell_color(0, 0) == main._board_cell_color(0, 1) \
		and !main.black_meter_label.visible \
		and !main.white_meter_label.visible
	main._show_settings_menu()
	await get_tree().process_frame
	var toggle_ok: bool = main.settings_panel.is_ancestor_of(main.high_contrast_toggle) \
		and main.high_contrast_toggle.is_visible_in_tree() \
		and main.high_contrast_toggle.text == "고대비 색상"
	main.high_contrast_toggle.button_pressed = true
	await get_tree().process_frame

	var marker_style := main.cell_hint_views[2][3].get_theme_stylebox("panel") as StyleBoxFlat
	var marker_ok: bool = main.cell_hint_views[2][3].visible \
		and marker_style != null \
		and marker_style.border_width_top >= 3 \
		and marker_style.bg_color.a <= 0.05
	var meter_ok: bool = main.black_meter_label.visible \
		and main.white_meter_label.visible \
		and main.black_meter_label.text == "%s 2" % main._t("black") \
		and main.white_meter_label.text == "%s 2" % main._t("white")

	var checker_ok := true
	for theme_id in MainScript.THEME_IDS:
		var settings: Dictionary = main.state.get("settings", {})
		settings["theme"] = theme_id
		main.state["settings"] = settings
		var dark_cell: Color = main._board_cell_color(0, 0)
		var light_cell: Color = main._board_cell_color(0, 1)
		checker_ok = absf(dark_cell.get_luminance() - light_cell.get_luminance()) >= 0.25 \
			and checker_ok

	main.state["last_move"] = {"x": 3, "y": 3, "stone": ReversiEngine.WHITE}
	main._render_cell(3, 3, int(main.state["board"][3][3]), false, true)
	var last_style := main.cell_buttons[3][3].get_theme_stylebox("normal") as StyleBoxFlat
	var last_move_ok := last_style != null and last_style.border_width_top >= 5
	var stored: Dictionary = main._load_preferences()
	var persisted_ok := bool(stored.get("settings", {}).get("high_contrast", false))

	main._set_theme("arctic", false)
	await get_tree().process_frame
	main._set_locale("en", false)
	await get_tree().process_frame
	var rebuild_ok: bool = main._high_contrast_enabled() \
		and main.high_contrast_toggle.button_pressed \
		and main.high_contrast_toggle.text == "HIGH CONTRAST" \
		and main.black_meter_label.visible
	main.queue_free()
	await get_tree().process_frame

	var restored = main_scene.instantiate()
	restored._prefs_path = prefs_path
	restored._save_path = save_path
	add_child(restored)
	await get_tree().process_frame
	var restored_ok: bool = restored._high_contrast_enabled() \
		and restored.high_contrast_toggle.button_pressed \
		and restored.black_meter_label.visible
	restored.queue_free()
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(normalization_ok, "high contrast setting defaults off and normalizes saved values")
		and _assert(labels_ok, "high contrast labels exist in Korean and English")
		and _assert(default_visuals_ok, "high contrast defaults preserve the standard board and meter")
		and _assert(toggle_ok, "high contrast toggle is visible inside settings")
		and _assert(marker_ok, "high contrast legal move uses a hollow thick ring")
		and _assert(meter_ok, "high contrast meter exposes black and white numeric labels")
		and _assert(checker_ok, "high contrast checker luminance differs across every board theme")
		and _assert(last_move_ok, "high contrast last move uses a thick border")
		and _assert(persisted_ok, "high contrast setting persists immediately")
		and _assert(rebuild_ok, "high contrast survives theme and locale rebuilds")
		and _assert(restored_ok, "high contrast restores after restart")
	)


func _test_new_game_confirmation_guard() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var save_path := "user://save_confirmation_%s.json" % str(OS.get_process_id())
	_rm_user(save_path)
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame
	main._save_path = save_path
	main.ai_move_pending = false
	main.input_locked = false
	main.player_stone = ReversiEngine.BLACK
	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	var move_result := ReversiEngine.play_move(main.state, 2, 3)
	main._render()
	await get_tree().process_frame

	var before_board := ReversiEngine.clone_board(main.state["board"])
	var before_history: Array = main.state["move_history"].duplicate(true)
	main.new_game_button.emit_signal("pressed")
	await get_tree().process_frame
	var guarded_new_game_ok: bool = bool(move_result.get("ok", false)) \
		and main.new_game_confirmation_overlay.visible \
		and main.state["board"] == before_board \
		and main.state["move_history"] == before_history
	var korean_labels_ok: bool = str(MainScript.TEXT["ko"].get("confirm_new_game_title", "")) == "대국을 새로 시작할까요?" \
		and str(MainScript.TEXT["ko"].get("confirm_new_game_body", "")) == "진행 중인 대국은 저장되지 않습니다." \
		and main.new_game_confirmation_confirm_button.text == "확인" \
		and main.new_game_confirmation_cancel_button.text == "취소"

	main.new_game_confirmation_cancel_button.emit_signal("pressed")
	await get_tree().process_frame
	var cancel_preserves_ok: bool = !main.new_game_confirmation_overlay.visible \
		and main.state["board"] == before_board \
		and main.state["move_history"] == before_history

	main.new_game_button.emit_signal("pressed")
	main.new_game_confirmation_confirm_button.emit_signal("pressed")
	await get_tree().process_frame
	var confirm_starts_ok: bool = !main.new_game_confirmation_overlay.visible \
		and main.state["move_history"].is_empty() \
		and ReversiEngine.count_pieces(main.state["board"]) == {"black": 2, "white": 2}

	main.new_game_button.emit_signal("pressed")
	var empty_history_skips_ok: bool = !main.new_game_confirmation_overlay.visible \
		and main.state["move_history"].is_empty()

	main.state["move_history"].append({"x": 2, "y": 3, "stone": ReversiEngine.BLACK, "turn_index": 0})
	main.state["game_over"] = true
	main.new_game_button.emit_signal("pressed")
	var completed_game_skips_ok: bool = !main.new_game_confirmation_overlay.visible \
		and main.state["move_history"].is_empty() \
		and !bool(main.state.get("game_over", true))

	main.state = ReversiEngine.create_new_game(ReversiEngine.BLACK, "MEDIUM")
	var color_move_result := ReversiEngine.play_move(main.state, 2, 3)
	main._render()
	before_board = ReversiEngine.clone_board(main.state["board"])
	before_history = main.state["move_history"].duplicate(true)
	main.white_button.emit_signal("pressed")
	await get_tree().process_frame
	var white_guard_ok: bool = bool(color_move_result.get("ok", false)) \
		and main.new_game_confirmation_overlay.visible \
		and main._pending_new_game_stone == ReversiEngine.WHITE \
		and main.state["board"] == before_board \
		and main.state["move_history"] == before_history
	main.new_game_confirmation_cancel_button.emit_signal("pressed")
	main.black_button.emit_signal("pressed")
	await get_tree().process_frame
	var black_guard_ok: bool = main.new_game_confirmation_overlay.visible \
		and main._pending_new_game_stone == ReversiEngine.BLACK \
		and main.state["board"] == before_board \
		and main.state["move_history"] == before_history
	main.new_game_confirmation_cancel_button.emit_signal("pressed")

	main._set_locale("en", false)
	await get_tree().process_frame
	main.new_game_button.emit_signal("pressed")
	await get_tree().process_frame
	var english_labels_ok: bool = main.new_game_confirmation_overlay.visible \
		and str(MainScript.TEXT["en"].get("confirm_new_game_title", "")) == "START A NEW GAME?" \
		and str(MainScript.TEXT["en"].get("confirm_new_game_body", "")) == "Your current game will be discarded." \
		and main.new_game_confirmation_confirm_button.text == "CONFIRM" \
		and main.new_game_confirmation_cancel_button.text == "CANCEL"
	main.new_game_confirmation_cancel_button.emit_signal("pressed")

	main.queue_free()
	_rm_user(save_path)
	return (
		_assert(guarded_new_game_ok, "new game button guards an active game")
		and _assert(korean_labels_ok, "new game confirmation renders Korean text")
		and _assert(cancel_preserves_ok, "new game confirmation cancel preserves state")
		and _assert(confirm_starts_ok, "new game confirmation confirm starts a game")
		and _assert(empty_history_skips_ok, "new game skips confirmation before the first move")
		and _assert(completed_game_skips_ok, "new game skips confirmation after game over")
		and _assert(white_guard_ok and black_guard_ok, "stone color buttons guard an active game")
		and _assert(english_labels_ok, "new game confirmation renders English text")
	)


func _test_visual_theme_switches_are_independent() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
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
	var classic_adjacent_style := main.cell_buttons[0][1].get_theme_stylebox("normal") as StyleBoxFlat
	var board_surface_panel := main.find_child("BoardSurface", true, false) as PanelContainer
	var classic_grid_style := board_surface_panel.get_theme_stylebox("panel") as StyleBoxFlat
	var classic_config: Dictionary = main._theme_config("classic")
	var classic_depth_style := main.cell_surface_depth_views[0][0].get_theme_stylebox("panel") as StyleBoxFlat
	var guide_layer := main.find_child("BoardGuideLayer", true, false) as Control
	var classic_guide_style := main.board_guide_points[0].get_theme_stylebox("panel") as StyleBoxFlat
	var classic_depth_palette: Dictionary = MainScript.board_depth_palette(
		classic_config["board_surface"],
		classic_config["text_muted"],
	)
	var classic_surface_ok: bool = classic_color == classic_adjacent_style.bg_color \
		and classic_color == classic_config["board_surface"] \
		and classic_grid_style.bg_color == classic_config["board_grid"] \
		and classic_color != classic_grid_style.bg_color \
		and classic_color.g > classic_color.r \
		and classic_color.g > classic_color.b
	var classic_depth_ok: bool = classic_depth_style.bg_color == Color.TRANSPARENT \
		and classic_depth_style.border_color == classic_depth_palette["board_highlight"] \
		and classic_depth_style.shadow_color == classic_depth_palette["board_shadow"] \
		and classic_depth_style.shadow_size == 2 \
		and classic_depth_style.shadow_offset == Vector2(1, 1)
	var guide_points_ok: bool = MainScript.board_guide_intersections(8) == PackedInt32Array([2, 6]) \
		and main.board_guide_points.size() == 4 \
		and guide_layer != null \
		and guide_layer.mouse_filter == Control.MOUSE_FILTER_IGNORE \
		and classic_guide_style.bg_color == classic_depth_palette["board_guide"]
	for guide_point_value in main.board_guide_points:
		var guide_point: PanelContainer = guide_point_value
		guide_points_ok = guide_points_ok \
			and guide_point.mouse_filter == Control.MOUSE_FILTER_IGNORE \
			and guide_point.position.x >= 0.0 \
			and guide_point.position.y >= 0.0
	var valid_normal_style := main.cell_buttons[2][3].get_theme_stylebox("normal") as StyleBoxFlat
	var valid_hover_style := main.cell_buttons[2][3].get_theme_stylebox("hover") as StyleBoxFlat
	var hint_and_hover_ok: bool = _visible_hint_count(main) == 4 \
		and main.cell_hint_views[2][3].visible \
		and valid_hover_style.bg_color != valid_normal_style.bg_color \
		and valid_hover_style.border_color == main._theme_color("accent") \
		and valid_hover_style.get_border_width(SIDE_TOP) >= 2

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
	var all_stone_themes_render_ok := true
	for theme_value in MainScript.STONE_THEME_IDS:
		var stone_theme_id := str(theme_value)
		main._set_stone_theme(stone_theme_id, false)
		await get_tree().process_frame
		var black_texture: Texture2D = main._texture_for_stone(ReversiEngine.BLACK)
		var white_texture: Texture2D = main._texture_for_stone(ReversiEngine.WHITE)
		all_stone_themes_render_ok = (
			all_stone_themes_render_ok
			and black_texture != null
			and white_texture != null
			and black_texture != white_texture
			and main.cell_piece_views[3][3].texture == white_texture
			and main.cell_piece_views[3][4].texture == black_texture
		)
	var theme_surface_colors: Array[Color] = []
	var all_board_themes_use_grid_ok := true
	var all_board_themes_use_depth_ok := true
	for theme_value in MainScript.THEME_IDS:
		var board_theme_id := str(theme_value)
		main._set_theme(board_theme_id, false)
		await get_tree().process_frame
		var first_style := main.cell_buttons[0][0].get_theme_stylebox("normal") as StyleBoxFlat
		var adjacent_style := main.cell_buttons[0][1].get_theme_stylebox("normal") as StyleBoxFlat
		var surface_panel := main.find_child("BoardSurface", true, false) as PanelContainer
		var grid_style := surface_panel.get_theme_stylebox("panel") as StyleBoxFlat
		var config: Dictionary = main._theme_config(board_theme_id)
		var depth_style := main.cell_surface_depth_views[0][0].get_theme_stylebox("panel") as StyleBoxFlat
		var guide_style := main.board_guide_points[0].get_theme_stylebox("panel") as StyleBoxFlat
		var depth_palette: Dictionary = MainScript.board_depth_palette(
			config["board_surface"],
			config["text_muted"],
		)
		all_board_themes_use_grid_ok = all_board_themes_use_grid_ok \
			and first_style.bg_color == adjacent_style.bg_color \
			and first_style.bg_color == config["board_surface"] \
			and grid_style.bg_color == config["board_grid"] \
			and first_style.bg_color != grid_style.bg_color
		all_board_themes_use_depth_ok = all_board_themes_use_depth_ok \
			and depth_style.border_color == depth_palette["board_highlight"] \
			and depth_style.shadow_color == depth_palette["board_shadow"] \
			and guide_style.bg_color == depth_palette["board_guide"] \
			and main.board_guide_points.size() == 4
		if !theme_surface_colors.has(first_style.bg_color):
			theme_surface_colors.append(first_style.bg_color)

	main._set_theme("classic", false)
	await get_tree().process_frame
	var guide_instance_before_locale: int = main.board_guide_points[0].get_instance_id()
	main._set_locale("en", false)
	await get_tree().process_frame
	var locale_rebuild_ok: bool = main.board_guide_points.size() == 4 \
		and main.board_guide_points[0].get_instance_id() != guide_instance_before_locale \
		and main.cell_surface_depth_views.size() == 8
	var move_result := ReversiEngine.play_move(main.state, 2, 3)
	main._render()
	var last_move_style := main.cell_buttons[2][3].get_theme_stylebox("normal") as StyleBoxFlat
	var last_move_ok: bool = bool(move_result.get("ok", false)) \
		and last_move_style.border_color == main._theme_color("accent") \
		and last_move_style.get_border_width(SIDE_TOP) == 3
	main.queue_free()
	return (
		_assert(selected_theme_ok, "ui theme setting changes")
		and _assert(classic_surface_ok, "ui classic board uses one green surface with grid lines")
		and _assert(classic_depth_ok, "ui board cells add an inner highlight and shadow")
		and _assert(guide_points_ok, "ui board guide points ignore cell input")
		and _assert(hint_and_hover_ok, "ui keeps legal hints and hover feedback on the grid board")
		and _assert(classic_color != arctic_board_color, "ui board theme switches board color")
		and _assert(classic_texture == board_only_texture, "ui board theme does not switch stone texture")
		and _assert(board_buttons_ok, "ui board theme buttons track selected theme")
		and _assert(selected_stone_ok, "ui stone theme setting changes")
		and _assert(board_only_texture != ember_texture, "ui stone theme switches stone texture")
		and _assert(arctic_board_color == after_stone_color, "ui stone theme does not switch board color")
		and _assert(stone_buttons_ok, "ui stone theme buttons track selected theme")
		and _assert(all_stone_themes_render_ok, "ui renders black and white discs for every stone theme")
		and _assert(all_board_themes_use_grid_ok, "ui derives surface and grid colors for every board theme")
		and _assert(all_board_themes_use_depth_ok, "ui derives depth and guide colors for every board theme")
		and _assert(theme_surface_colors.size() == MainScript.THEME_IDS.size(), "ui keeps board theme surfaces visually distinct")
		and _assert(locale_rebuild_ok, "ui rebuilds board depth and guide points after locale changes")
		and _assert(last_move_ok, "ui keeps the last-move border on the grid board")
	)


func _test_forest_board_theme() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_forest_theme_%s.json" % suffix
	var save_path := "user://save_forest_theme_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	var classic_surface: Color = main._theme_config("classic")["board_surface"]
	var stone_before: Texture2D = main._texture_for_stone(ReversiEngine.BLACK)
	main._show_settings_menu()
	await get_tree().process_frame
	var korean_button_ok: bool = main.board_theme_buttons.size() == MainScript.THEME_IDS.size()
	for entry_value in main.board_theme_buttons:
		var entry: Dictionary = entry_value
		if str(entry.get("id", "")) == "forest":
			var button := entry.get("button") as Button
			korean_button_ok = korean_button_ok and button != null and button.text == "숲"

	main._set_theme("forest")
	await get_tree().process_frame
	var forest_config: Dictionary = main._theme_config("forest")
	var required_keys := [
		"bg", "hud", "hud_dark", "board_frame", "board_frame_border",
		"board_dark", "board_light", "board_surface", "board_grid", "meter_bg",
		"text_primary", "text_muted", "accent", "danger", "success",
		"hint", "hint_border", "board_highlight", "board_shadow", "board_guide",
	]
	var key_set_ok: bool = true
	for key in required_keys:
		key_set_ok = forest_config.has(key) and key_set_ok
	var forest_surface: Color = forest_config["board_surface"]
	var forest_dark: Color = forest_config["board_dark"]
	var forest_light: Color = forest_config["board_light"]
	var green_palette_ok: bool = forest_surface != classic_surface \
		and forest_surface.g > forest_surface.r \
		and forest_surface.g > forest_surface.b \
		and forest_dark.g > forest_dark.r \
		and forest_light.g > forest_light.r
	var rendered_style := main.cell_buttons[0][0].get_theme_stylebox("normal") as StyleBoxFlat
	var rendered_ok: bool = rendered_style != null \
		and rendered_style.bg_color == forest_surface \
		and _choice_group_has_active_id(main.board_theme_buttons, "forest")
	var independence_ok: bool = main._texture_for_stone(ReversiEngine.BLACK) == stone_before
	var contrast_ok: bool = absf(Color(forest_config["hint"]).get_luminance() - forest_surface.get_luminance()) >= 0.35 \
		and absf(Color(forest_config["accent"]).get_luminance() - forest_surface.get_luminance()) >= 0.35
	var stored: Dictionary = main._load_preferences()
	var persisted_ok: bool = str(stored.get("settings", {}).get("theme", "")) == "forest"

	main._set_locale("en", false)
	await get_tree().process_frame
	var english_button_ok: bool = main.board_theme_buttons.size() == MainScript.THEME_IDS.size()
	for entry_value in main.board_theme_buttons:
		var entry: Dictionary = entry_value
		if str(entry.get("id", "")) == "forest":
			var button := entry.get("button") as Button
			english_button_ok = english_button_ok and button != null and button.text == "FOREST"
	main.queue_free()
	await get_tree().process_frame

	var restored = main_scene.instantiate()
	restored._prefs_path = prefs_path
	restored._save_path = save_path
	add_child(restored)
	await get_tree().process_frame
	var restored_ok: bool = restored._current_theme_id() == "forest" \
		and _choice_group_has_active_id(restored.board_theme_buttons, "forest") \
		and restored._texture_for_stone(ReversiEngine.BLACK) == stone_before
	restored.queue_free()
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(korean_button_ok and english_button_ok, "forest is the fourth localized board theme choice")
		and _assert(key_set_ok, "forest theme exposes the complete board palette contract")
		and _assert(green_palette_ok, "forest theme provides a distinct green felt palette")
		and _assert(rendered_ok, "forest selection renders and marks the board theme active")
		and _assert(independence_ok, "forest board theme preserves the selected stone texture")
		and _assert(contrast_ok, "forest hint and last-move accent contrast with the felt surface")
		and _assert(persisted_ok, "forest theme persists immediately")
		and _assert(restored_ok, "forest theme restores without changing stone textures")
	)


func _test_sakura_visual_theme() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_sakura_theme_%s.json" % suffix
	var save_path := "user://save_sakura_theme_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	var initial_game_root: Node = main.find_child("GameRoot", true, false)
	var initial_game_root_child_count: int = initial_game_root.get_child_count()
	main._show_settings_menu()
	await get_tree().process_frame

	var korean_board_label_ok := false
	for entry_value in main.board_theme_buttons:
		var entry: Dictionary = entry_value
		if str(entry.get("id", "")) == "sakura":
			var button := entry.get("button") as Button
			korean_board_label_ok = button != null and button.text == "벚꽃"
	var korean_stone_label_ok := false
	for entry_value in main.stone_theme_buttons:
		var entry: Dictionary = entry_value
		if str(entry.get("id", "")) == "sakura":
			var button := entry.get("button") as Button
			korean_stone_label_ok = button != null and button.text == "벚꽃"

	var board_config: Dictionary = main._theme_config("sakura")
	var board_required_keys := [
		"bg", "hud", "hud_dark", "board_frame", "board_frame_border",
		"board_dark", "board_light", "board_surface", "board_grid", "meter_bg",
		"text_primary", "text_muted", "accent", "danger", "success",
		"hint", "hint_border", "board_highlight", "board_shadow", "board_guide",
	]
	var board_contract_ok: bool = MainScript.THEME_IDS.has("sakura")
	for key in board_required_keys:
		board_contract_ok = board_contract_ok \
			and board_config.has(key) \
			and typeof(board_config[key]) == TYPE_COLOR \
			and Color(board_config[key]) != Color.WHITE

	var stone_config: Dictionary = main._stone_theme_config("sakura")
	var sakura_black := stone_config.get("black_texture") as Texture2D
	var sakura_white := stone_config.get("white_texture") as Texture2D
	var stone_contract_ok: bool = MainScript.STONE_THEME_IDS.has("sakura") \
		and sakura_black != null \
		and sakura_white != null \
		and sakura_black != sakura_white \
		and sakura_black.resource_path == "res://assets/reversi/themes/sakura_black.svg" \
		and sakura_white.resource_path == "res://assets/reversi/themes/sakura_white.svg" \
		and typeof(stone_config.get("black_meter")) == TYPE_COLOR \
		and typeof(stone_config.get("white_meter")) == TYPE_COLOR \
		and Color(stone_config["black_meter"]) != Color.WHITE \
		and Color(stone_config["white_meter"]) != Color.WHITE

	main._set_theme("sakura")
	await get_tree().process_frame
	main._set_stone_theme("sakura")
	await get_tree().process_frame
	var rendered_board_style := main.cell_buttons[0][0].get_theme_stylebox("normal") as StyleBoxFlat
	var selection_render_ok: bool = rendered_board_style != null \
		and rendered_board_style.bg_color == board_config["board_surface"] \
		and _choice_group_has_active_id(main.board_theme_buttons, "sakura") \
		and _choice_group_has_active_id(main.stone_theme_buttons, "sakura")
	var board_texture_ok: bool = main.cell_piece_views[3][3].texture == sakura_white \
		and main.cell_piece_views[3][4].texture == sakura_black
	var score_texture_ok: bool = main.player_stone_view.texture \
			== main._texture_for_stone(main.player_stone) \
		and main.ai_stone_view.texture \
			== main._texture_for_stone(ReversiEngine.opponent(main.player_stone))
	var stored: Dictionary = main._load_preferences()
	var persisted_ok: bool = str(stored.get("settings", {}).get("theme", "")) == "sakura" \
		and str(stored.get("settings", {}).get("stone_theme", "")) == "sakura"
	var current_game_root: Node = main.find_child("GameRoot", true, false)
	var existing_settings_depth_ok: bool = main.settings_overlay.visible \
		and current_game_root.get_child_count() == initial_game_root_child_count

	main._set_locale("en", false)
	await get_tree().process_frame
	var english_board_label_ok := false
	for entry_value in main.board_theme_buttons:
		var entry: Dictionary = entry_value
		if str(entry.get("id", "")) == "sakura":
			var button := entry.get("button") as Button
			english_board_label_ok = button != null and button.text == "SAKURA"
	var english_stone_label_ok := false
	for entry_value in main.stone_theme_buttons:
		var entry: Dictionary = entry_value
		if str(entry.get("id", "")) == "sakura":
			var button := entry.get("button") as Button
			english_stone_label_ok = button != null and button.text == "SAKURA"
	main.queue_free()
	await get_tree().process_frame

	var restored = main_scene.instantiate()
	restored._prefs_path = prefs_path
	restored._save_path = save_path
	add_child(restored)
	await get_tree().process_frame
	var restored_ok: bool = restored._current_theme_id() == "sakura" \
		and restored._current_stone_theme_id() == "sakura" \
		and _choice_group_has_active_id(restored.board_theme_buttons, "sakura") \
		and _choice_group_has_active_id(restored.stone_theme_buttons, "sakura") \
		and restored.cell_piece_views[3][3].texture == sakura_white \
		and restored.cell_piece_views[3][4].texture == sakura_black
	restored.queue_free()
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(korean_board_label_ok and korean_stone_label_ok, "sakura board and stone labels render in Korean")
		and _assert(english_board_label_ok and english_stone_label_ok, "sakura board and stone labels render in English")
		and _assert(board_contract_ok, "sakura board theme avoids color fallback with a complete palette")
		and _assert(stone_contract_ok, "sakura stone theme imports distinct black and white SVG textures")
		and _assert(selection_render_ok, "sakura board and stone selectors rerender as active")
		and _assert(board_texture_ok, "sakura textures render on the board")
		and _assert(score_texture_ok, "sakura textures render in both score panels")
		and _assert(persisted_ok, "sakura board and stone selections persist immediately")
		and _assert(restored_ok, "sakura board and stone selections restore after restart")
		and _assert(existing_settings_depth_ok, "sakura reuses existing settings selectors without a new HUD")
	)


func _test_result_share_button() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame

	var settings := ReversiEngine.default_settings()
	settings["locale"] = "ko"
	settings["sound"] = false
	settings["reduce_motion"] = true
	var full_board: Array = []
	for _x in range(ReversiEngine.BOARD_SIZE):
		var row: Array = []
		for _y in range(ReversiEngine.BOARD_SIZE):
			row.append(ReversiEngine.BLACK)
		full_board.append(row)
	main.player_stone = ReversiEngine.BLACK
	main.state = ReversiEngine.create_state_from_board(full_board, ReversiEngine.BLACK)
	main.state["settings"] = settings
	main._interstitial_shown_this_game = true
	main._render()
	await get_tree().process_frame

	var button_ok: bool = main.result_share_button != null \
		and main.result_share_button.text == "공유" \
		and main.result_overlay.is_ancestor_of(main.result_share_button)
	var probe := _ShareResultProbe.new()
	main._share_result_probe = Callable(probe, "share")
	main.result_share_button.pressed.emit()
	var korean_text_ok: bool = probe.messages.size() == 1 \
		and probe.messages[0] == "루시드 리버시\n승리\n흑 64 / 백 0"

	main._set_locale("en", false)
	await get_tree().process_frame
	main.result_share_button.pressed.emit()
	var english_ok: bool = main.result_share_button.text == "SHARE" \
		and probe.messages.size() == 2 \
		and probe.messages[1] == "LUCID REVERSI\nWIN\nBLACK 64 / WHITE 0"
	var i18n_ok := true
	for locale_id in ["ko", "en", "ja"]:
		var locale_texts: Dictionary = MainScript.TEXT[locale_id]
		i18n_ok = i18n_ok \
			and !str(locale_texts.get("share_result", "")).is_empty() \
			and !str(locale_texts.get("result_share_text", "")).is_empty()

	main._share_result_probe = Callable()
	var unavailable_noop_ok: bool = !main._share_result()
	main.queue_free()
	return (
		_assert(button_ok, "result overlay exposes the localized share button")
		and _assert(korean_text_ok, "result share text contains the Korean outcome and final score")
		and _assert(english_ok, "result share button and payload localize to English")
		and _assert(i18n_ok, "result share strings cover every supported locale")
		and _assert(unavailable_noop_ok, "result share safely no-ops without a channel")
	)


func _test_game_highlights_ui_and_restore() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var completed_state := ReversiEngine.create_new_game(
		ReversiEngine.BLACK,
		"EASY",
		ReversiEngine.BOARD_SIZE,
		600060,
	)
	var guard := 0
	while !bool(completed_state.get("game_over", false)) and guard < 100:
		var moves: Array = completed_state.get("valid_moves", [])
		if moves.is_empty():
			break
		var move: Dictionary = moves[0]
		var result := ReversiEngine.play_move(
			completed_state,
			int(move["x"]),
			int(move["y"]),
		)
		if !bool(result.get("ok", false)):
			break
		guard += 1
	var completed_summary := ReversiEngine.summarize_move_history(
		completed_state.get("move_history", []),
		ReversiEngine.BOARD_SIZE,
	)
	var completed_fixture_ok: bool = bool(completed_state.get("game_over", false)) \
		and int(completed_summary.get("moves_replayed", 0)) == 60 \
		and int(completed_summary.get("max_flip_count", 0)) == 6 \
		and int(completed_summary.get("corner_black", -1)) == 2 \
		and int(completed_summary.get("corner_white", -1)) == 2 \
		and int(completed_summary.get("peak_lead", 0)) == 32 \
		and int(completed_summary.get("peak_lead_stone", ReversiEngine.NONE)) == ReversiEngine.WHITE

	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_highlights_%s.json" % suffix
	var save_path := "user://save_highlights_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)
	var save_file := FileAccess.open(save_path, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(ReversiEngine.state_to_save_dict(completed_state)))
	save_file.close()

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	var restored_korean_ok: bool = bool(main.state.get("game_over", false)) \
		and main.result_overlay.visible \
		and main.result_highlights_panel.visible \
		and main.result_overlay.is_ancestor_of(main.result_highlights_panel) \
		and main.result_highlights_title_label.text == "이 판 하이라이트" \
		and main.result_highlights_label.text == (
			"최대 뒤집기 · 흑 H1 · 6개\n"
			+ "코너 확보 · 흑 2 / 백 2\n"
			+ "최대 우세 · 백 +32"
		)

	main._set_locale("en", false)
	await get_tree().process_frame
	var english_ok: bool = main.result_highlights_panel.visible \
		and main.result_highlights_title_label.text == "GAME HIGHLIGHTS" \
		and main.result_highlights_label.text == (
			"BIGGEST FLIP · BLACK H1 · 6\n"
			+ "CORNERS · BLACK 2 / WHITE 2\n"
			+ "PEAK LEAD · WHITE +32"
		)
	var locale_keys_ok := true
	for locale_id in ["ko", "en", "ja"]:
		var locale_texts: Dictionary = MainScript.TEXT[locale_id]
		for key in [
			"result_highlights_title",
			"result_highlight_flip",
			"result_highlight_corners",
			"result_highlight_lead",
		]:
			locale_keys_ok = locale_keys_ok and !str(locale_texts.get(key, "")).is_empty()

	main.state["move_history"] = []
	main._render()
	var missing_history_hides_ok: bool = !main.result_highlights_panel.visible
	main.queue_free()
	await get_tree().process_frame
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(completed_fixture_ok, "game highlight completed fixture has stable expected metrics")
		and _assert(restored_korean_ok, "restored completed game shows three Korean highlight lines in the result modal")
		and _assert(english_ok, "game highlight card rerenders in English after a locale change")
		and _assert(locale_keys_ok, "game highlight strings cover every supported locale")
		and _assert(missing_history_hides_ok, "game highlight card hides when replay history is unavailable")
	)


func _test_finished_game_replay() -> bool:
	var MainScript = load("res://scripts/bootstrap/main.gd")
	var finished_state := ReversiEngine.create_new_game(
		ReversiEngine.BLACK,
		"EASY",
		ReversiEngine.BOARD_SIZE,
		360036,
	)
	var guard := 0
	while !bool(finished_state.get("game_over", false)) and guard < 100:
		var moves: Array = finished_state.get("valid_moves", [])
		if moves.is_empty():
			break
		var move: Dictionary = moves[0]
		var result := ReversiEngine.play_move(
			finished_state,
			int(move["x"]),
			int(move["y"]),
		)
		if !bool(result.get("ok", false)):
			break
		guard += 1
	var finished_ok: bool = bool(finished_state.get("game_over", false)) \
		and !finished_state.get("move_history", []).is_empty() \
		and MainScript.replay_history_valid(finished_state)

	var suffix := str(OS.get_process_id())
	var prefs_path := "user://prefs_replay_%s.json" % suffix
	var save_path := "user://save_replay_%s.json" % suffix
	_rm_user(prefs_path)
	_rm_user(save_path)
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	main._prefs_path = prefs_path
	main._save_path = save_path
	add_child(main)
	await get_tree().process_frame
	var settings := ReversiEngine.default_settings()
	settings["sound"] = false
	settings["reduce_motion"] = true
	finished_state["settings"] = settings
	main.player_stone = ReversiEngine.BLACK
	main.state = finished_state
	main._interstitial_shown_this_game = true
	main._result_animation_played_this_game = true
	main._save_state()
	var expected_final_state: Dictionary = main.state.duplicate(true)
	var saved_before := FileAccess.get_file_as_string(save_path)
	main._render()
	await get_tree().process_frame
	var entry_ok: bool = main.result_overlay.visible \
		and main.result_replay_button != null \
		and main.result_replay_button.text == "리플레이" \
		and !main.result_replay_button.disabled \
		and main.result_overlay.is_ancestor_of(main.result_replay_button) \
		and !main.replay_controls.visible

	main._enter_replay()
	await get_tree().process_frame
	var initial_replay: Dictionary = MainScript.replay_state_at_step(expected_final_state, 0)
	var mode_ok: bool = main.replay_active \
		and main.input_locked \
		and main.replay_controls.visible \
		and !main.gameplay_strip.visible \
		and !main.result_overlay.visible \
		and main.replay_step == 0 \
		and main.state.get("board", []) == initial_replay.get("board", []) \
		and main.replay_step_label.text == "0 / %d수" % main.replay_history.size()

	await main._advance_replay_step(false)
	var first_replay: Dictionary = MainScript.replay_state_at_step(expected_final_state, 1)
	var next_ok: bool = main.replay_step == 1 \
		and main.state.get("board", []) == first_replay.get("board", [])
	main._set_replay_step(0)
	var previous_ok: bool = main.replay_step == 0 \
		and main.state.get("board", []) == initial_replay.get("board", [])

	main._toggle_replay_playback()
	await get_tree().create_timer(0.05).timeout
	main._toggle_replay_playback()
	var playback_pause_ok: bool = !main.replay_playing \
		and main.replay_step > 0 \
		and main.replay_step < main.replay_history.size() \
		and main.replay_play_button.text == "재생"
	await get_tree().create_timer(0.05).timeout
	main._set_replay_step(main.replay_history.size())
	var final_step_ok: bool = main.state.get("board", []) == expected_final_state.get("board", []) \
		and main.replay_next_button.disabled
	main._set_replay_step(main.replay_history.size() - 1)
	var arbitrary_previous_ok: bool = main.replay_step == main.replay_history.size() - 1 \
		and !main.replay_next_button.disabled

	main._close_replay()
	await get_tree().process_frame
	var restored_ok: bool = !main.replay_active \
		and !main.input_locked \
		and !main.replay_controls.visible \
		and main.gameplay_strip.visible \
		and main.result_overlay.visible \
		and main.state == expected_final_state
	var save_unchanged_ok: bool = FileAccess.get_file_as_string(save_path) == saved_before

	var corrupt_state: Dictionary = expected_final_state.duplicate(true)
	var corrupt_history: Array = corrupt_state.get("move_history", [])
	(corrupt_history[0] as Dictionary)["x"] = -1
	corrupt_state["move_history"] = corrupt_history
	main.state = corrupt_state
	main._render()
	var corrupt_ok: bool = !MainScript.replay_history_valid(corrupt_state) \
		and main.result_replay_button.disabled
	var locale_ok := true
	for locale_id in ["ko", "en", "ja"]:
		var locale_texts: Dictionary = MainScript.TEXT[locale_id]
		for key in [
			"replay",
			"replay_previous",
			"replay_play",
			"replay_pause",
			"replay_next",
			"replay_close",
			"replay_step",
		]:
			locale_ok = locale_ok and !str(locale_texts.get(key, "")).is_empty()

	main.queue_free()
	await get_tree().process_frame
	_rm_user(prefs_path)
	_rm_user(save_path)
	return (
		_assert(finished_ok, "replay accepts a completed game with intact move history")
		and _assert(entry_ok, "result overlay exposes replay only as a modal entry point")
		and _assert(mode_ok, "replay mode locks board input and shows only temporary board controls")
		and _assert(next_ok and previous_ok, "replay next and previous rebuild exact board steps")
		and _assert(playback_pause_ok, "replay playback starts and pauses without reaching the end")
		and _assert(final_step_ok and arbitrary_previous_ok, "replay can seek between the last two moves")
		and _assert(restored_ok, "closing replay restores the completed result state")
		and _assert(save_unchanged_ok, "replay never changes the persisted game save")
		and _assert(corrupt_ok, "empty or corrupt replay history is rejected safely")
		and _assert(locale_ok, "replay controls cover every supported locale")
	)


func _visible_hint_count(main) -> int:
	var count := 0
	for row in main.cell_hint_views:
		for hint in row:
			if hint.visible:
				count += 1
	return count


func _visible_flip_count_count(main) -> int:
	var count := 0
	for row in main.cell_flip_count_labels:
		for label in row:
			if label.visible:
				count += 1
	return count


func _visible_ghost_count(main) -> int:
	var count := 0
	for row in main.cell_ghost_views:
		for ghost_value in row:
			var ghost: TextureRect = ghost_value
			if ghost.visible and ghost.texture != null:
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


func _append_u16(payload: PackedByteArray, value: int) -> void:
	payload.append(value & 0xff)
	payload.append((value >> 8) & 0xff)


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


func _visible_tutorial_highlight_count(main: Node) -> int:
	var count := 0
	for row in main.cell_tutorial_views:
		for highlight in row:
			if (highlight as PanelContainer).visible:
				count += 1
	return count


func _assert(condition: bool, label: String) -> bool:
	if !condition:
		push_error("Smoke failed: %s" % label)
		return false
	print("Smoke passed: %s" % label)
	return true
