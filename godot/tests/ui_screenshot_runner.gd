extends Node

const ReversiEngine = preload("res://scripts/reversi_engine.gd")
const MainScene = preload("res://scenes/main.tscn")


func _ready() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var suffix := str(OS.get_process_id())
	var main = MainScene.instantiate()
	main._prefs_path = "user://prefs_ui_capture_%s.json" % suffix
	main._save_path = "user://save_ui_capture_%s.json" % suffix
	add_child(main)
	await get_tree().process_frame

	var fixture := ReversiEngine.create_new_game(
		ReversiEngine.BLACK,
		"MEDIUM",
		ReversiEngine.DEFAULT_BOARD_SIZE,
		20260918,
	)
	var first_move := ReversiEngine.play_move(fixture, 2, 3)
	if !bool(first_move.get("ok", false)):
		push_error("Could not prepare the first UI fixture move.")
		get_tree().quit(1)
		return
	var next_moves: Array = fixture.get("valid_moves", [])
	if next_moves.is_empty():
		push_error("Could not prepare the second UI fixture move.")
		get_tree().quit(1)
		return
	var next_move: Dictionary = next_moves[0]
	var second_move := ReversiEngine.play_move(
		fixture,
		int(next_move["x"]),
		int(next_move["y"]),
	)
	if !bool(second_move.get("ok", false)):
		push_error("Could not apply the second UI fixture move.")
		get_tree().quit(1)
		return

	var settings := ReversiEngine.default_settings()
	settings["locale"] = "ko"
	settings["opponent_mode"] = "ai"
	settings["sound"] = false
	settings["music"] = false
	settings["reduce_motion"] = true
	fixture["settings"] = settings
	main.state = fixture
	main.player_stone = ReversiEngine.BLACK
	main.preferences = ReversiEngine.normalize_preferences({
		"difficulty": "MEDIUM",
		"how_to_play_seen": true,
		"settings": settings,
	})
	main.ai_move_pending = false
	main.input_locked = false
	main._build_ui()
	main._render()
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var output_path := _output_path()
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Could not save UI runtime screenshot: %s" % error_string(error))
		get_tree().quit(1)
		return
	print(
		"UI_RUNTIME_RESULT path=%s size=%dx%d moves=%d score=3-3" % [
			output_path,
			image.get_width(),
			image.get_height(),
			fixture.get("move_history", []).size(),
		]
	)
	main.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit(0)


func _output_path() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			return argument.trim_prefix("--output=")
	return ProjectSettings.globalize_path(
		"res://../docs/game-design/ui/runtime-moonlit-lacquer-720x1280.png"
	)
