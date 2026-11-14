extends SceneTree

const Driver = preload("res://tools/e2e/e2e_driver.gd")
const EngineRules = preload("res://scripts/reversi_engine.gd")
const MainScene = preload("res://scenes/main.tscn")

class AnalyticsSink:
	extends Node
	var events: Array = []
	func send(event_name: String, params: Dictionary) -> void:
		events.append({"name": event_name, "params": params})

class MusicSink:
	extends RefCounted
	var playing := false
	func play() -> void:
		playing = true
	func stop() -> void:
		playing = false

var driver: RefCounted
var game: Control
var sandbox: String
var ad_requests := 0
var shares: Array[String] = []
var external_uris: Array[String] = []
var sink: Node

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	seed(20261115)
	var args := OS.get_cmdline_user_args()
	var out := args[args.find("--out") + 1] if args.has("--out") else "../build/e2e"
	sandbox = ProjectSettings.globalize_path(out).path_join("sandbox")
	DirAccess.make_dir_recursive_absolute(sandbox)
	for filename in ["save.json", "prefs.json"]:
		DirAccess.remove_absolute(sandbox.path_join(filename))
	driver = Driver.new(self, Vector2i(720, 1280), out, args.has("--capture"))
	await _mount()
	await _tutorial()
	await _ai_match()
	await _ai_finish()
	await _settings()
	await _local_match()
	await _puzzles()
	await _restore_and_recover()
	var status: int = driver.finish({"sourceSha": OS.get_environment("GITHUB_SHA"), "seed": 20261115})
	driver.viewport.queue_free()
	driver = null
	await process_frame
	await process_frame
	call_deferred("quit", status)

func _mount() -> void:
	game = MainScene.instantiate()
	game._save_path = sandbox.path_join("save.json")
	game._prefs_path = sandbox.path_join("prefs.json")
	game._game_seed_source = func() -> int: return 20261115
	game.bgm_player = MusicSink.new()
	game._interstitial_probe = func() -> void: ad_requests += 1
	game._share_result_probe = func(value: String) -> void: shares.append(value)
	game._shell_open_override = func(value: String) -> void: external_uris.append(value)
	await driver.mount(game)
	sink = AnalyticsSink.new()
	sink.add_to_group("persistent_services")
	game.add_child(sink)
	game.analytics.set_sender(sink)

func _tap(control: Control, description: String) -> bool:
	await driver.frames(4)
	var ok: bool = await driver.tap(control)
	if not ok:
		await driver.shot("failed-%s" % description.validate_filename())
	return driver.step(description, ok)

func _tap_point(point: Vector2) -> void:
	driver._push_button(point, true)
	await driver.frames(2)
	driver._push_button(point, false)
	await driver.frames(3)

func _open_settings() -> void:
	if not game.settings_overlay.visible:
		await _tap(game.settings_button, "open settings")
	driver.step("settings visible", game.settings_overlay.visible)

func _close_settings() -> void:
	await _tap_point(Vector2(4, 4))
	driver.step("outside tap closes settings", not game.settings_overlay.visible)

func _choice(property: String, id: String) -> void:
	await driver.frames(4)
	var entries: Array = game.get(property)
	for entry in entries:
		if str(entry.id) == id:
			await _tap(entry.button, "%s=%s" % [property, id])
			return
	driver.step("choice exists: %s/%s" % [property, id], false)

func _settle() -> void:
	driver.step("turn settles", await driver.wait_for(func(): return not game.input_locked and not game.ai_move_pending, 1800))

func _play_one_move() -> void:
	await _settle()
	var legal: Array = EngineRules.get_valid_moves(game.state.board, int(game.state.current_turn))
	if not driver.step("legal move available", not legal.is_empty()):
		return
	var move: Dictionary = legal[0]
	var before: int = game.state.move_history.size()
	await _tap(game.cell_buttons[int(move.x)][int(move.y)], "place legal stone")
	await _settle()
	driver.step("legal input changes match history", game.state.move_history.size() > before)

func _tutorial() -> void:
	driver.begin("first-run-and-icons", ["first-run-tutorial", "app-icon"])
	driver.step("actual start scene", game.scene_file_path == "res://scenes/main.tscn")
	driver.expect_equal("isolated deterministic random seed", int(game.state.game_seed), 20261115)
	driver.step("tutorial appears on first run", game.how_to_play_overlay.visible)
	await driver.shot("01-first-run")
	for index in range(3):
		await _tap(game.how_to_play_next_button, "tutorial next")
		driver.expect_equal("tutorial step", game.how_to_play_step_index, index + 1)
	await _tap(game.how_to_play_previous_button, "tutorial previous")
	driver.expect_equal("tutorial previous step", game.how_to_play_step_index, 2)
	await _tap(game.how_to_play_next_button, "tutorial final step")
	await _tap(game.how_to_play_next_button, "complete tutorial")
	driver.step("tutorial completion persisted", not game.how_to_play_overlay.visible and FileAccess.file_exists(game._prefs_path))
	for item in [["launcher_192.png", 192], ["adaptive_foreground_432.png", 432], ["adaptive_background_432.png", 432], ["adaptive_monochrome_432.svg", 432]]:
		var texture := load("res://branding/android/%s" % item[0]) as Texture2D
		driver.step("Android icon size %s" % item[0], texture != null and texture.get_width() == item[1] and texture.get_height() == item[1])
	await driver.shot("02-board")
	driver.end()

func _ai_match() -> void:
	driver.begin("ai-play-undo-hint-and-cancel", ["ai-match", "analytics"])
	await _open_settings()
	await _choice("difficulty_buttons", "BEGINNER")
	await _close_settings()
	await _tap(game.hint_button, "show hint")
	driver.step("one legal hint", not game._hinted_move.is_empty())
	await _play_one_move()
	driver.step("AI responds with a searched move", game.state.move_history.size() >= 2 and game._ai_sync_fallback_count > 0)
	await _tap(game.move_count_label, "open move list")
	driver.step("move list contains played moves", game.move_list_overlay.visible and game.move_list_rows.size() >= 2)
	await _tap(game.move_list_close_button, "close move list")
	await _tap(game.undo_button, "undo a round")
	driver.expect_equal("round removed", game.state.move_history.size(), 0)
	await _play_one_move()
	var history_size: int = game.state.move_history.size()
	await _tap(game.new_game_button, "request new game")
	driver.step("new game asks confirmation", game.new_game_confirmation_overlay.visible)
	await _tap(game.new_game_confirmation_cancel_button, "cancel new game")
	driver.expect_equal("cancel preserves board", game.state.move_history.size(), history_size)
	await _tap(game.new_game_button, "request new game again")
	await _tap(game.new_game_confirmation_confirm_button, "confirm new game")
	driver.expect_equal("confirmed game starts empty", game.state.move_history.size(), 0)
	driver.step("analytics obeys runtime transport policy", sink.events.is_empty() if DisplayServer.get_name() == "headless" else not sink.events.is_empty())
	await driver.shot("03-ai-match")
	driver.end()

func _settings() -> void:
	driver.begin("settings-localization-accessibility", ["settings-localization", "visual-customization", "accessibility", "audio-haptics", "native-shell"])
	await _open_settings()
	await _choice("difficulty_buttons", "HARD")
	driver.expect_equal("hard selected", game.difficulty, "HARD")
	await _choice("difficulty_buttons", "BEGINNER")
	for property in ["sound_toggle", "music_toggle", "haptic_toggle", "show_moves_toggle", "show_coordinates_toggle", "show_flip_counts_toggle", "reduce_motion_toggle", "high_contrast_toggle"]:
		var before: bool = game.get(property).button_pressed
		await _tap(game.get(property), "toggle %s" % property)
		driver.expect_equal("toggle changes %s" % property, game.get(property).button_pressed, not before)
		if property == "music_toggle":
			driver.expect_equal("music command reaches audio boundary", bool(game.bgm_player.playing), not before)
		if property != "reduce_motion_toggle":
			await _tap(game.get(property), "restore %s" % property)
	await _choice("font_scale_buttons", "1.3")
	driver.expect_equal("large font selected", game._current_font_scale_id(), "1.3")
	await _choice("font_scale_buttons", "1.0")
	await _choice("board_theme_buttons", "sakura")
	driver.expect_equal("board theme selected", game._current_theme_id(), "sakura")
	await _choice("stone_theme_buttons", "arctic")
	driver.expect_equal("independent stone theme", game._current_stone_theme_id(), "arctic")
	await _choice("locale_buttons", "en")
	driver.expect_equal("English selected", game._current_locale_id(), "en")
	await _choice("locale_buttons", "ja")
	driver.expect_equal("Japanese selected", game._current_locale_id(), "ja")
	await _choice("locale_buttons", "ko")
	var support := game.find_child("SupportEmailButton", true, false) as Button
	if support != null:
		await _tap(support, "open support boundary")
		driver.step("support URI delivered", external_uris.size() == 1)
	await _tap(game.how_to_play_entry_button, "reopen tutorial")
	driver.step("tutorial accessible from settings", game.how_to_play_overlay.visible)
	await _tap(game.how_to_play_close_button, "close tutorial")
	await _open_settings()
	await driver.shot("04-settings")
	await _close_settings()
	await driver.shot("05-customized-board")
	driver.end()

func _ai_finish() -> void:
	driver.begin("ai-difficulties-colors-and-finished-stats", ["ai-match", "results-replay", "save-restore"])
	await _open_settings()
	await _choice("board_size_buttons", "6")
	for id in ["EASY", "MEDIUM", "HARD"]:
		await _choice("difficulty_buttons", id)
		driver.expect_equal("difficulty selection persists", game.difficulty, id)
	await _close_settings()
	await _play_one_move()
	driver.step("hard AI completes off main thread", game._ai_worker_completed_count > 0 and game._ai_worker_ran_off_main_thread)
	await _tap(game.undo_button, "undo hard AI round")
	await _open_settings()
	await _choice("difficulty_buttons", "BEGINNER")
	await _close_settings()
	await _tap(game.white_button, "choose white")
	await _settle()
	driver.expect_equal("white player selected", game.player_stone, EngineRules.WHITE)
	driver.step("AI opens when player is white", game.state.move_history.size() >= 1)
	var moves := 0
	while not bool(game.state.game_over) and moves < 40:
		await _play_one_move()
		moves += 1
	driver.step("AI match finishes", bool(game.state.game_over) and game.result_overlay.visible)
	var stats: Dictionary = game.state.stats.BEGINNER
	driver.expect_equal("one result counted", int(stats.wins) + int(stats.draws) + int(stats.losses), 1)
	await driver.shot("03b-ai-result-stats")
	await _tap(game.result_restart_button, "restart after AI game")
	await _settle()
	await _tap(game.black_button, "choose black")
	if game.new_game_confirmation_overlay.visible:
		await _tap(game.new_game_confirmation_confirm_button, "confirm color change after AI opening")
	await _settle()
	driver.expect_equal("black player selected", game.player_stone, EngineRules.BLACK)
	driver.end()

func _local_match() -> void:
	driver.begin("local-anti-game-results-replay", ["local-match", "anti-reversi", "results-replay", "native-admob", "native-shell"])
	var ads_before := ad_requests
	await _open_settings()
	await _choice("opponent_mode_buttons", "local")
	await _choice("variant_buttons", "anti")
	driver.expect_equal("anti variant selected", game._current_variant(), "anti")
	await _choice("board_size_buttons", "10")
	driver.expect_equal("10x10 board built", game.cell_buttons.size(), 10)
	await _choice("board_size_buttons", "6")
	driver.expect_equal("6x6 board built", game.cell_buttons.size(), 6)
	await _close_settings()
	var moves := 0
	while not bool(game.state.game_over) and moves < 40:
		await _play_one_move()
		moves += 1
	driver.step("local game reaches terminal state", bool(game.state.game_over))
	driver.step("results and highlights appear", game.result_overlay.visible and game.result_highlights_label.text.length() > 0)
	driver.expect_equal("one ad boundary request per finished game", ad_requests, ads_before + 1)
	await driver.shot("06-result")
	await _tap(game.result_share_button, "share result")
	driver.step("result share delivered to platform boundary", shares.size() == 1 and not shares[0].is_empty())
	await _tap(game.result_move_list_button, "results move list")
	driver.expect_equal("complete chronological move list", game.move_list_rows.size(), game.state.move_history.size())
	await _tap(game.move_list_close_button, "close results move list")
	await _tap(game.result_replay_button, "start replay")
	driver.step("replay active", game.replay_active)
	await _tap(game.replay_next_button, "replay next")
	driver.expect_equal("replay advances", game.replay_step, 1)
	await _tap(game.replay_previous_button, "replay previous")
	driver.expect_equal("replay goes back", game.replay_step, 0)
	await _tap(game.replay_play_button, "replay play")
	await driver.frames(4)
	await _tap(game.replay_play_button, "replay pause")
	await _tap(game.replay_close_button, "close replay")
	driver.step("result restored after replay", not game.replay_active and game.result_overlay.visible)
	driver.expect_equal("replay never requests a second ad", ad_requests, ads_before + 1)
	await driver.unmount(game)
	await _mount()
	driver.step("finished game restored", bool(game.state.game_over) and game.result_overlay.visible)
	driver.expect_equal("restore never requests ad again", ad_requests, ads_before + 1)
	await _tap(game.result_restart_button, "start another game")
	driver.expect_equal("new match has no history", game.state.move_history.size(), 0)
	driver.end()

func _puzzles() -> void:
	driver.begin("puzzle-and-save-isolation", ["puzzles", "save-restore"])
	await _open_settings()
	await _choice("variant_buttons", "standard")
	await _tap(game.puzzle_entry_button, "open puzzles")
	driver.step("puzzle catalog visible", game.puzzle_overlay.visible and game.puzzle_cards.size() == 3)
	await driver.shot("07-puzzles")
	await _tap(game.puzzle_cards[0].start_button, "start first puzzle")
	driver.step("puzzle active", not game._active_puzzle_id.is_empty())
	await _play_one_move()
	driver.step("puzzle produces outcome", game._puzzle_completed)
	await driver.shot("08-puzzle-outcome")
	await driver.unmount(game)
	await _mount()
	driver.step("normal match survives puzzle restart", game._active_puzzle_id.is_empty() and not bool(game.state.game_over))
	driver.end()

func _restore_and_recover() -> void:
	driver.begin("save-restart-corruption-recovery", ["save-restore", "settings-localization"])
	await _play_one_move()
	var before: Dictionary = game.state.duplicate(true)
	await driver.unmount(game)
	await _mount()
	driver.expect_equal("played board restored", game.state.board, before.board)
	driver.expect_equal("move history restored", game.state.move_history, JSON.parse_string(JSON.stringify(before.move_history)))
	driver.expect_equal("theme preference restored", game._current_theme_id(), "sakura")
	driver.expect_equal("stone preference restored", game._current_stone_theme_id(), "arctic")
	driver.step("tutorial stays completed", not game.how_to_play_overlay.visible)
	await driver.unmount(game)
	var file := FileAccess.open(sandbox.path_join("save.json"), FileAccess.WRITE)
	file.store_string('{"invalid":"save"}')
	file.close()
	await _mount()
	driver.expect_equal("invalid save starts safe board", game.state.move_history.size(), 0)
	driver.expect_equal("invalid save preserves settings", game._current_theme_id(), "sakura")
	await driver.shot("09-restored")
	driver.end()
	await driver.unmount(game)
