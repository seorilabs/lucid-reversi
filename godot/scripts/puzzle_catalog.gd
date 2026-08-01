extends RefCounted

const ReversiEngine = preload("res://scripts/reversi_engine.gd")

const GOAL_WIN := "win"
const GOAL_CORNER := "corner"

# board는 사람이 읽기 쉬운 행 우선 문자열 배열이다. board_from_definition에서
# ReversiEngine의 열 우선 board[x][y] 배열로 변환한다.
const DEFINITIONS := [
	{
		"id": "corner_capture",
		"board": [
			"..WWWWW.",
			"WWWWBW..",
			"WWWWWWW.",
			"WWBWBW.B",
			"WWWBWWBB",
			"WWWWB.BB",
			"WWWWWBBB",
			"B.W.B.BB",
		],
		"current_turn": ReversiEngine.BLACK,
		"player_stone": ReversiEngine.BLACK,
		"title_key": "puzzle_corner_title",
		"description": "puzzle_corner_description",
		"goal_key": "puzzle_corner_goal",
		"goal": {
			"type": GOAL_CORNER,
			"x": 0,
			"y": 0,
			"target_stone": ReversiEngine.BLACK,
		},
		"difficulty": "MEDIUM",
	},
	{
		"id": "endgame_comeback",
		"board": [
			"WWWWWWW.",
			"BBBBBWWB",
			"B.WWWBW.",
			"BBWWWBWB",
			"BBBBWWW.",
			"BBBWBWWW",
			".WWBBBW.",
			".W.WBWWW",
		],
		"current_turn": ReversiEngine.BLACK,
		"player_stone": ReversiEngine.BLACK,
		"title_key": "puzzle_comeback_title",
		"description": "puzzle_comeback_description",
		"goal_key": "puzzle_comeback_goal",
		"goal": {
			"type": GOAL_WIN,
			"target_stone": ReversiEngine.BLACK,
		},
		"difficulty": "HARD",
	},
	{
		"id": "white_finish",
		"board": [
			"WWWWWWWW",
			"WWWWWWWW",
			"WWWWWWWW",
			"WWWWWWWW",
			"WWWWWWWW",
			"WWWWWWWW",
			"WWWWWWWW",
			"WWWWW.BW",
		],
		"current_turn": ReversiEngine.WHITE,
		"player_stone": ReversiEngine.WHITE,
		"title_key": "puzzle_white_title",
		"description": "puzzle_white_description",
		"goal_key": "puzzle_white_goal",
		"goal": {
			"type": GOAL_WIN,
			"target_stone": ReversiEngine.WHITE,
		},
		"difficulty": "EASY",
	},
]


static func all() -> Array:
	return DEFINITIONS.duplicate(true)


static func get_by_id(puzzle_id: String) -> Dictionary:
	for definition_value in DEFINITIONS:
		var definition: Dictionary = definition_value
		if str(definition.get("id", "")) == puzzle_id:
			return definition.duplicate(true)
	return {}


static func board_from_definition(definition: Dictionary) -> Array:
	var rows_value = definition.get("board", [])
	if typeof(rows_value) != TYPE_ARRAY:
		return []
	var rows: Array = rows_value
	if rows.is_empty():
		return []
	var board_size := rows.size()
	for row_value in rows:
		if str(row_value).length() != board_size:
			return []

	var board: Array = []
	for x in range(board_size):
		var column: Array = []
		for y in range(board_size):
			var cell := str(rows[y]).substr(x, 1)
			match cell:
				"B":
					column.append(ReversiEngine.BLACK)
				"W":
					column.append(ReversiEngine.WHITE)
				".":
					column.append(ReversiEngine.NONE)
				_:
					return []
		board.append(column)
	return board


static func create_state(definition: Dictionary, game_seed: int = -1) -> Dictionary:
	if !definition_is_valid(definition):
		return {}
	return ReversiEngine.create_state_from_board(
		board_from_definition(definition),
		int(definition["current_turn"]),
		int(definition["player_stone"]),
		str(definition["difficulty"]),
		game_seed,
	)


static func definition_is_valid(definition: Dictionary) -> bool:
	if str(definition.get("id", "")).is_empty() \
		or str(definition.get("title_key", "")).is_empty() \
		or str(definition.get("description", "")).is_empty() \
		or str(definition.get("goal_key", "")).is_empty():
		return false
	var current_turn := int(definition.get("current_turn", ReversiEngine.NONE))
	var player_stone := int(definition.get("player_stone", ReversiEngine.NONE))
	if ![ReversiEngine.BLACK, ReversiEngine.WHITE].has(current_turn) \
		or ![ReversiEngine.BLACK, ReversiEngine.WHITE].has(player_stone) \
		or !ReversiEngine.DIFFICULTY_DEPTH.has(str(definition.get("difficulty", ""))):
		return false
	var board := board_from_definition(definition)
	if ReversiEngine.get_board_size(board) != ReversiEngine.DEFAULT_BOARD_SIZE:
		return false
	var goal_value = definition.get("goal", {})
	if typeof(goal_value) != TYPE_DICTIONARY:
		return false
	var goal: Dictionary = goal_value
	var goal_type := str(goal.get("type", ""))
	var target_stone := int(goal.get("target_stone", ReversiEngine.NONE))
	if ![GOAL_WIN, GOAL_CORNER].has(goal_type) \
		or ![ReversiEngine.BLACK, ReversiEngine.WHITE].has(target_stone):
		return false
	if goal_type == GOAL_CORNER:
		var board_size := ReversiEngine.get_board_size(board)
		var x := int(goal.get("x", -1))
		var y := int(goal.get("y", -1))
		if ![0, board_size - 1].has(x) or ![0, board_size - 1].has(y):
			return false
	var state := ReversiEngine.create_state_from_board(
		board,
		current_turn,
		player_stone,
		str(definition["difficulty"]),
		1,
	)
	return !state.is_empty() \
		and !bool(state.get("game_over", true)) \
		and !state.get("valid_moves", []).is_empty()


static func evaluate_goal(definition: Dictionary, state: Dictionary) -> Dictionary:
	if !definition_is_valid(definition) or state.is_empty():
		return {"complete": true, "success": false}
	var goal: Dictionary = definition["goal"]
	var target_stone := int(goal["target_stone"])
	match str(goal["type"]):
		GOAL_CORNER:
			var board: Array = state.get("board", [])
			var x := int(goal["x"])
			var y := int(goal["y"])
			var corner_stone := int(board[x][y])
			if corner_stone == target_stone:
				return {"complete": true, "success": true}
			if corner_stone == ReversiEngine.opponent(target_stone) \
				or bool(state.get("game_over", false)):
				return {"complete": true, "success": false}
			return {"complete": false, "success": false}
		GOAL_WIN:
			if !bool(state.get("game_over", false)):
				return {"complete": false, "success": false}
			return {
				"complete": true,
				"success": int(state.get("winner", ReversiEngine.NONE)) == target_stone,
			}
	return {"complete": true, "success": false}
