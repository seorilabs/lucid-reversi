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


func _ready() -> void:
	var ok := true
	ok = _test_main_scene_exists() and ok
	ok = _test_initial_valid_moves() and ok
	ok = _test_first_move_flip() and ok
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
	var i18n_ok := await _test_i18n_defaults_and_locale_switch()
	ok = i18n_ok and ok
	var japanese_locale_ok := await _test_japanese_locale_and_font_fallback()
	ok = japanese_locale_ok and ok
	var settings_menu_ok := await _test_settings_menu_keeps_playfield_focused()
	ok = settings_menu_ok and ok
	var settings_persistence_ok := await _test_settings_persist_immediately()
	ok = settings_persistence_ok and ok
	var board_size_ui_ok := await _test_board_size_ui()
	ok = board_size_ui_ok and ok
	var accessibility_ok := await _test_accessibility_settings_and_reduced_motion()
	ok = accessibility_ok and ok
	var new_game_confirmation_ok := await _test_new_game_confirmation_guard()
	ok = new_game_confirmation_ok and ok
	var theme_ok := await _test_visual_theme_switches_are_independent()
	ok = theme_ok and ok
	var ui_ok := await _test_ui_hints_return_after_animation()
	ok = ui_ok and ok
	var show_moves_ok := await _test_show_moves_setting()
	ok = show_moves_ok and ok
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
	var haptic_ok := await _test_haptic_feedback()
	ok = haptic_ok and ok
	get_tree().quit(0 if ok else 1)


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
	var first_sorted_move: Dictionary = ReversiEngine.create_new_game(
		ReversiEngine.BLACK,
		"EASY",
		8,
		11,
	)["valid_moves"][0]
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
			easy_choices.size() == 1
				and easy_choices.has("%d,%d" % [first_sorted_move["x"], first_sorted_move["y"]]),
			"EASY keeps the first sorted move for every game seed",
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
		and _visible_hint_count(main) == expected_hints
	main._show_settings_menu()
	await get_tree().process_frame
	var settings_depth_ok: bool = main.settings_panel.is_ancestor_of(main.show_moves_toggle) \
		and main.show_moves_toggle.is_visible_in_tree() \
		and main.show_moves_toggle.text == "착수 표시" \
		and str(MainScript.TEXT["en"].get("show_moves", "")) == "MOVES"

	main.show_moves_toggle.button_pressed = false
	await get_tree().process_frame
	var hidden_ok: bool = !main._show_moves_enabled() \
		and _visible_hint_count(main) == 0
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
		and _visible_hint_count(restored_main) == 0
	restored_main._set_locale("en", false)
	await get_tree().process_frame
	var english_label_ok: bool = restored_main.show_moves_toggle.text == "MOVES"
	restored_main.show_moves_toggle.button_pressed = true
	await get_tree().process_frame
	var restored_on_ok: bool = restored_main._show_moves_enabled() \
		and _visible_hint_count(restored_main) == int(
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
	var game_over_disabled_ok: bool = !main._can_undo()
	main.state["game_over"] = false
	main._render()

	main._on_undo_pressed(false)
	var undo_board_ok: bool = main.state["board"] == initial_board
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
		and _assert(game_over_disabled_ok, "ui disables undo after game over")
		and _assert(undo_board_ok, "ui undo restores the previous board")
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
		and main.board_theme_buttons.size() == 3 \
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
	var about_section: Node = main.settings_panel.find_child("AboutSection", true, false)
	var about_app_version := main.settings_panel.find_child("AboutAppVersion", true, false) as Label
	var support_email_button := main.settings_panel.find_child("SupportEmailButton", true, false) as Button
	var privacy_policy_button: Node = main.settings_panel.find_child("PrivacyPolicyButton", true, false)
	var about_location_ok: bool = language_section != null \
		and about_section != null \
		and about_section.get_parent() == language_section.get_parent() \
		and about_section.get_index() == language_section.get_index() + 1 \
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
		and _assert(about_location_ok, "ui nests about section directly after language settings")
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

	var stored: Dictionary = main._load_preferences()
	var stored_settings: Dictionary = stored.get("settings", {})
	var stored_ok := str(stored.get("difficulty", "")) == "HARD" \
		and str(stored_settings.get("theme", "")) == "arctic" \
		and str(stored_settings.get("stone_theme", "")) == "ember" \
		and str(stored_settings.get("locale", "")) == "en" \
		and !bool(stored_settings.get("sound", true))
	main.queue_free()
	_rm_user(prefs_path)
	return _assert(stored_ok, "every user setting writes preferences immediately")


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
	var all_stone_themes_render_ok := true
	for theme_value in ["classic", "arctic", "ember"]:
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
		and _assert(all_stone_themes_render_ok, "ui renders black and white discs for every stone theme")
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


func _assert(condition: bool, label: String) -> bool:
	if !condition:
		push_error("Smoke failed: %s" % label)
		return false
	print("Smoke passed: %s" % label)
	return true
