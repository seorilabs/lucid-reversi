extends SceneTree
## [임시] App Store 스크린샷용 save 상태 생성기.
## 테마별로 몇 수 진행된 대국 상태를 user://sshot_<theme>.json 으로 저장한다.
## 이 json 을 시뮬레이터 앱 컨테이너의 save_v1.json 으로 복사한 뒤 앱을 실행하면 해당 화면이 뜬다.

const RE = preload("res://scripts/reversi_engine.gd")


func _init() -> void:
	_gen("classic", "classic", 6)
	_gen("arctic", "arctic", 8)
	_gen("ember", "ember", 10)
	print("USER_DIR:", OS.get_user_data_dir())
	quit()


func _gen(name: String, theme: String, moves: int) -> void:
	var s: Dictionary = RE.create_new_game(RE.BLACK, "MEDIUM")
	for i in range(moves):
		var vm: Array = s.get("valid_moves", [])
		if vm.is_empty():
			break
		RE.play_move(s, int(vm[0]["x"]), int(vm[0]["y"]))
	var settings: Dictionary = s["settings"].duplicate()
	settings["locale"] = "ko"
	settings["theme"] = theme
	settings["stone_theme"] = theme
	settings["sound"] = true
	s["settings"] = settings
	# _load_state 는 state_to_save_dict 형식(board_codec base64)을 기대하므로 그 형식으로 저장한다.
	var f := FileAccess.open("user://sshot_%s.json" % name, FileAccess.WRITE)
	f.store_string(JSON.stringify(RE.state_to_save_dict(s)))
	f.close()
	var placed := 0
	for row in s["board"]:
		for cell in row:
			if int(cell) != 0:
				placed += 1
	print("wrote sshot_", name, " (stones=", placed, ")")
