extends RefCounted

const BOARD_SIZE := 8
const NONE := 0
const BLACK := 1
const WHITE := 2
const VALID := 3
const SEARCH_MIN := -9223372036854775807
const SEARCH_MAX := 9223372036854775807
const MOBILITY_WEIGHT := BOARD_SIZE

const DIFFICULTY_DEPTH := {
	"EASY": 1,
	"MEDIUM": 3,
	"HARD": 5,
}

const DIRECTIONS := [
	Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1),
	Vector2i(0, -1), Vector2i(0, 1),
	Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1),
]


static func default_settings() -> Dictionary:
	return {
		"sound": true,
		"locale": "ko",
		"theme": "classic",
		"stone_theme": "classic",
	}


static func normalize_settings(raw_settings: Dictionary) -> Dictionary:
	var defaults := default_settings()
	var normalized := defaults.duplicate()
	for key in raw_settings.keys():
		if defaults.has(key):
			normalized[key] = raw_settings[key]
	return normalized


static func default_stats() -> Dictionary:
	return {
		"EASY": {"wins": 0, "draws": 0, "losses": 0},
		"MEDIUM": {"wins": 0, "draws": 0, "losses": 0},
		"HARD": {"wins": 0, "draws": 0, "losses": 0},
	}


static func normalize_stats(raw_stats: Dictionary) -> Dictionary:
	var normalized := default_stats()
	for difficulty in normalized.keys():
		var raw_bucket_value = raw_stats.get(difficulty, {})
		if typeof(raw_bucket_value) != TYPE_DICTIONARY:
			continue
		var raw_bucket: Dictionary = raw_bucket_value
		var bucket: Dictionary = normalized[difficulty]
		for counter in bucket.keys():
			bucket[counter] = maxi(0, int(raw_bucket.get(counter, 0)))
		normalized[difficulty] = bucket
	return normalized


static func create_new_game(player_stone: int = BLACK, difficulty: String = "MEDIUM") -> Dictionary:
	var board := _initial_board()
	var state := {
		"version": 1,
		"board": board,
		"current_turn": BLACK,
		"player_stone": player_stone,
		"ai_stone": opponent(player_stone),
		"difficulty": difficulty,
		"valid_moves": get_valid_moves(board, BLACK),
		"move_history": [],
		"settings": default_settings(),
		"stats": default_stats(),
		"last_move": {},
		"pass_count": 0,
		"game_over": false,
		"winner": NONE,
		"last_saved_at": 0,
	}
	_refresh_result(state)
	return state


static func create_state_from_board(board: Array, current_turn: int = BLACK, player_stone: int = BLACK, difficulty: String = "MEDIUM") -> Dictionary:
	var state := {
		"version": 1,
		"board": clone_board(board),
		"current_turn": current_turn,
		"player_stone": player_stone,
		"ai_stone": opponent(player_stone),
		"difficulty": difficulty,
		"valid_moves": get_valid_moves(board, current_turn),
		"move_history": [],
		"settings": default_settings(),
		"stats": default_stats(),
		"last_move": {},
		"pass_count": 0,
		"game_over": false,
		"winner": NONE,
		"last_saved_at": 0,
	}
	_refresh_result(state)
	return state


static func play_move(state: Dictionary, x: int, y: int) -> Dictionary:
	if bool(state.get("game_over", false)):
		return {"ok": false, "reason": "game_over"}

	var board: Array = state["board"]
	var stone: int = int(state["current_turn"])
	if !_is_valid_move(board, stone, x, y):
		return {"ok": false, "reason": "invalid_move"}

	var flipped := _apply_move(board, stone, x, y)
	state["last_move"] = {"x": x, "y": y, "stone": stone}
	var history: Array = state.get("move_history", [])
	history.append({"x": x, "y": y, "stone": stone, "turn_index": history.size()})
	state["move_history"] = history
	_resolve_next_turn(state, stone)
	_refresh_result(state)
	return {
		"ok": true,
		"placed": {"x": x, "y": y, "stone": stone},
		"flipped": flipped,
	}


static func can_undo_last_round(state: Dictionary) -> bool:
	var player_stone := int(state.get("player_stone", NONE))
	if player_stone != BLACK and player_stone != WHITE:
		return false

	var history: Array = state.get("move_history", [])
	for index in range(history.size() - 1, -1, -1):
		var move: Dictionary = history[index]
		if int(move.get("stone", NONE)) == player_stone:
			return true
	return false


static func undo_last_round(state: Dictionary) -> Dictionary:
	if !can_undo_last_round(state):
		return {"ok": false, "reason": "no_player_move"}

	var history: Array = state.get("move_history", [])
	var player_stone := int(state.get("player_stone", BLACK))
	var undo_from := -1
	for index in range(history.size() - 1, -1, -1):
		var move: Dictionary = history[index]
		if int(move.get("stone", NONE)) == player_stone:
			undo_from = index
			break

	if undo_from < 0:
		return {"ok": false, "reason": "no_player_move"}

	var restored := create_new_game(
		player_stone,
		str(state.get("difficulty", "MEDIUM")),
	)
	restored["settings"] = normalize_settings(state.get("settings", default_settings()))
	restored["stats"] = normalize_stats(state.get("stats", {}))
	restored["last_saved_at"] = int(state.get("last_saved_at", 0))

	for index in range(undo_from):
		var move: Dictionary = history[index]
		if int(restored.get("current_turn", NONE)) != int(move.get("stone", NONE)):
			return {"ok": false, "reason": "history_turn_mismatch"}
		var replay_result := play_move(
			restored,
			int(move.get("x", -1)),
			int(move.get("y", -1)),
		)
		if !bool(replay_result.get("ok", false)):
			return {"ok": false, "reason": "history_replay_failed"}

	var removed_moves := history.size() - undo_from
	state.clear()
	state.merge(restored, true)
	return {
		"ok": true,
		"removed_moves": removed_moves,
	}


static func record_game_result(state: Dictionary, result_kind: String) -> bool:
	var counter := ""
	match result_kind:
		"win":
			counter = "wins"
		"draw":
			counter = "draws"
		"lose":
			counter = "losses"
		_:
			return false

	var difficulty := str(state.get("difficulty", "MEDIUM"))
	if !DIFFICULTY_DEPTH.has(difficulty):
		return false

	var stats := normalize_stats(state.get("stats", {}))
	var bucket: Dictionary = stats[difficulty]
	bucket[counter] = int(bucket.get(counter, 0)) + 1
	stats[difficulty] = bucket
	state["stats"] = stats
	return true


static func get_valid_moves(board: Array, stone: int) -> Array:
	if stone != BLACK and stone != WHITE:
		return []

	var moves: Array = []
	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			if _is_valid_move(board, stone, x, y):
				moves.append({"x": x, "y": y})
	return sort_moves(moves)


static func choose_ai_move(state: Dictionary, search_stats: Dictionary = {}) -> Dictionary:
	var stone: int = int(state.get("current_turn", NONE))
	var moves := get_valid_moves(state.get("board", []), stone)
	if moves.is_empty():
		return {}

	var depth := int(DIFFICULTY_DEPTH.get(str(state.get("difficulty", "MEDIUM")), 3))
	var best_score := SEARCH_MIN
	var best_move: Dictionary = {}
	var alpha := SEARCH_MIN
	var beta := SEARCH_MAX
	# 루트는 sort_moves 순서를 유지해 동점일 때 기존 best move를 보존한다.
	for move in moves:
		var board_after := clone_board(state["board"])
		_apply_move(board_after, stone, int(move["x"]), int(move["y"]))
		var next_turn := _next_turn_for_board(board_after, stone)
		var score := _search_score(
			board_after,
			next_turn,
			stone,
			depth - 1,
			alpha,
			beta,
			search_stats,
		)
		if score > best_score:
			best_score = score
			best_move = move
		alpha = max(alpha, best_score)
	return best_move


static func encode_board_payload(board: Array, current_turn: int, valid_moves: Array = []) -> PackedByteArray:
	var payload := PackedByteArray()
	for x in range(BOARD_SIZE):
		var row_value := 0
		for y in range(BOARD_SIZE):
			var cell := int(board[x][y])
			if cell == NONE and _move_list_has(valid_moves, x, y):
				cell = VALID
			var shift := (BOARD_SIZE - 1 - y) * 2
			row_value |= (cell & 3) << shift
		_append_u16_le(payload, row_value)
	_append_u16_le(payload, current_turn)
	return payload


static func decode_board_payload(payload: PackedByteArray) -> Dictionary:
	if payload.size() != 18:
		return {}

	var board: Array = []
	var valid_moves: Array = []
	for x in range(BOARD_SIZE):
		var row_value := _read_u16_le(payload, x * 2)
		var row: Array = []
		for y in range(BOARD_SIZE):
			var shift := (BOARD_SIZE - 1 - y) * 2
			var cell := (row_value >> shift) & 3
			if cell == VALID:
				row.append(NONE)
				valid_moves.append({"x": x, "y": y})
			else:
				row.append(cell)
		board.append(row)

	return {
		"board": board,
		"current_turn": _read_u16_le(payload, 16),
		"valid_moves": sort_moves(valid_moves),
	}


static func state_to_save_dict(state: Dictionary) -> Dictionary:
	var payload := encode_board_payload(state["board"], int(state["current_turn"]), state.get("valid_moves", []))
	return {
		"version": 1,
		"current_turn": int(state["current_turn"]),
		"player_stone": int(state.get("player_stone", BLACK)),
		"ai_stone": int(state.get("ai_stone", WHITE)),
		"difficulty": str(state.get("difficulty", "MEDIUM")),
		"board_codec": Marshalls.raw_to_base64(payload),
		"move_history": state.get("move_history", []),
		"pass_count": int(state.get("pass_count", 0)),
		"settings": normalize_settings(state.get("settings", default_settings())),
		"stats": normalize_stats(state.get("stats", {})),
		"last_saved_at": int(state.get("last_saved_at", 0)),
	}


static func state_from_save_dict(saved: Dictionary) -> Dictionary:
	if int(saved.get("version", 0)) != 1:
		return {}
	if !saved.has("board_codec"):
		return {}

	var payload := Marshalls.base64_to_raw(str(saved["board_codec"]))
	var decoded := decode_board_payload(payload)
	if decoded.is_empty():
		return {}

	var state := create_state_from_board(
		decoded["board"],
		int(saved.get("current_turn", decoded["current_turn"])),
		int(saved.get("player_stone", BLACK)),
		str(saved.get("difficulty", "MEDIUM"))
	)
	state["ai_stone"] = int(saved.get("ai_stone", opponent(int(state["player_stone"]))))
	state["move_history"] = saved.get("move_history", [])
	state["pass_count"] = int(saved.get("pass_count", 0))
	state["settings"] = normalize_settings(saved.get("settings", default_settings()))
	state["stats"] = normalize_stats(saved.get("stats", {}))
	state["last_saved_at"] = int(saved.get("last_saved_at", 0))
	return state


static func count_pieces(board: Array) -> Dictionary:
	var black := 0
	var white := 0
	for row in board:
		for cell in row:
			if int(cell) == BLACK:
				black += 1
			elif int(cell) == WHITE:
				white += 1
	return {"black": black, "white": white}


static func piece_name(stone: int) -> String:
	match stone:
		BLACK:
			return "BLACK"
		WHITE:
			return "WHITE"
		_:
			return "NONE"


static func opponent(stone: int) -> int:
	if stone == BLACK:
		return WHITE
	if stone == WHITE:
		return BLACK
	return NONE


static func clone_board(board: Array) -> Array:
	var cloned: Array = []
	for row in board:
		cloned.append(row.duplicate())
	return cloned


static func sort_moves(moves: Array) -> Array:
	moves.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["x"]) == int(b["x"]):
			return int(a["y"]) < int(b["y"])
		return int(a["x"]) < int(b["x"])
	)
	return moves


static func _initial_board() -> Array:
	var board: Array = []
	for _x in range(BOARD_SIZE):
		var row: Array = []
		for _y in range(BOARD_SIZE):
			row.append(NONE)
		board.append(row)

	board[3][3] = WHITE
	board[3][4] = BLACK
	board[4][3] = BLACK
	board[4][4] = WHITE
	return board


static func _is_valid_move(board: Array, stone: int, x: int, y: int) -> bool:
	if !_in_bounds(x, y):
		return false
	if int(board[x][y]) != NONE:
		return false

	for direction in DIRECTIONS:
		if _direction_flips(board, stone, x, y, direction).size() > 0:
			return true
	return false


static func _apply_move(board: Array, stone: int, x: int, y: int) -> Array:
	board[x][y] = stone
	var flipped_cells: Array = []
	for direction in DIRECTIONS:
		for flipped in _direction_flips(board, stone, x, y, direction):
			board[int(flipped.x)][int(flipped.y)] = stone
			flipped_cells.append({"x": int(flipped.x), "y": int(flipped.y), "stone": stone})
	return flipped_cells


static func _direction_flips(board: Array, stone: int, x: int, y: int, direction: Vector2i) -> Array:
	var flipped: Array = []
	var cx := x + direction.x
	var cy := y + direction.y
	var other := opponent(stone)

	while _in_bounds(cx, cy) and int(board[cx][cy]) == other:
		flipped.append(Vector2i(cx, cy))
		cx += direction.x
		cy += direction.y

	if flipped.is_empty():
		return []
	if !_in_bounds(cx, cy):
		return []
	if int(board[cx][cy]) != stone:
		return []
	return flipped


static func _resolve_next_turn(state: Dictionary, just_played: int) -> void:
	var board: Array = state["board"]
	var next := opponent(just_played)
	var next_moves := get_valid_moves(board, next)
	if !next_moves.is_empty():
		state["current_turn"] = next
		state["valid_moves"] = next_moves
		return

	var same_moves := get_valid_moves(board, just_played)
	if !same_moves.is_empty():
		state["current_turn"] = just_played
		state["valid_moves"] = same_moves
		state["pass_count"] = int(state.get("pass_count", 0)) + 1
		return

	state["current_turn"] = NONE
	state["valid_moves"] = []
	state["game_over"] = true


static func _refresh_result(state: Dictionary) -> void:
	var board: Array = state["board"]
	var black_moves := get_valid_moves(board, BLACK)
	var white_moves := get_valid_moves(board, WHITE)
	if black_moves.is_empty() and white_moves.is_empty():
		state["game_over"] = true
		state["current_turn"] = NONE
		state["valid_moves"] = []
		var counts := count_pieces(board)
		if int(counts["black"]) > int(counts["white"]):
			state["winner"] = BLACK
		elif int(counts["white"]) > int(counts["black"]):
			state["winner"] = WHITE
		else:
			state["winner"] = NONE
	else:
		state["game_over"] = false
		state["winner"] = NONE
		state["valid_moves"] = get_valid_moves(board, int(state["current_turn"]))


static func _next_turn_for_board(board: Array, just_played: int) -> int:
	var next := opponent(just_played)
	if !get_valid_moves(board, next).is_empty():
		return next
	if !get_valid_moves(board, just_played).is_empty():
		return just_played
	return NONE


static func _search_score(
	board: Array,
	turn: int,
	root_stone: int,
	depth: int,
	alpha: int,
	beta: int,
	search_stats: Dictionary = {},
) -> int:
	_record_search_stat(search_stats, "nodes")
	if depth <= 0 or turn == NONE:
		return _evaluate_board(board, root_stone)

	var moves := get_valid_moves(board, turn)
	if moves.is_empty():
		var other := opponent(turn)
		if get_valid_moves(board, other).is_empty():
			return _evaluate_board(board, root_stone)
		return _search_score(
			board,
			other,
			root_stone,
			depth - 1,
			alpha,
			beta,
			search_stats,
		)

	var maximizing := turn == root_stone
	var best := SEARCH_MIN if maximizing else SEARCH_MAX
	for move in _order_search_moves(moves):
		var next_board := clone_board(board)
		_apply_move(next_board, turn, int(move["x"]), int(move["y"]))
		var next_turn := _next_turn_for_board(next_board, turn)
		var score := _search_score(
			next_board,
			next_turn,
			root_stone,
			depth - 1,
			alpha,
			beta,
			search_stats,
		)
		if maximizing:
			best = max(best, score)
			alpha = max(alpha, best)
			if best >= beta:
				_record_search_stat(search_stats, "max_cutoffs")
				break
		else:
			best = min(best, score)
			beta = min(beta, best)
			if best <= alpha:
				_record_search_stat(search_stats, "min_cutoffs")
				break
	return best


static func _evaluate_board(board: Array, stone: int) -> int:
	var counts := count_pieces(board)
	var score := int(counts["black"]) - int(counts["white"])
	if stone == WHITE:
		score *= -1

	score += _mobility_score(board, stone)

	var corner_value := BOARD_SIZE * 3
	var edge_value := BOARD_SIZE * 2
	var pre_corner_value := -BOARD_SIZE * 2
	var corner_path_value := -BOARD_SIZE

	for point in [Vector2i(0, 0), Vector2i(0, 7), Vector2i(7, 0), Vector2i(7, 7)]:
		score += _weighted_cell(board, point, stone, corner_value)

	for point in [Vector2i(1, 1), Vector2i(1, 6), Vector2i(6, 1), Vector2i(6, 6)]:
		score += _weighted_cell(board, point, stone, pre_corner_value)

	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			var is_edge := x == 0 or y == 0 or x == 7 or y == 7
			var is_corner := (x == 0 or x == 7) and (y == 0 or y == 7)
			if is_edge and !is_corner:
				score += _weighted_cell(board, Vector2i(x, y), stone, edge_value)

	for point in [
		Vector2i(1, 2), Vector2i(1, 3), Vector2i(1, 4), Vector2i(1, 5),
		Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1),
		Vector2i(6, 2), Vector2i(6, 3), Vector2i(6, 4), Vector2i(6, 5),
		Vector2i(2, 6), Vector2i(3, 6), Vector2i(4, 6), Vector2i(5, 6),
	]:
		score += _weighted_cell(board, point, stone, corner_path_value)

	return score


static func _mobility_score(board: Array, stone: int) -> int:
	var own_moves := get_valid_moves(board, stone).size()
	var opponent_moves := get_valid_moves(board, opponent(stone)).size()
	return (own_moves - opponent_moves) * MOBILITY_WEIGHT


static func _order_search_moves(moves: Array) -> Array:
	# 모서리와 가장자리를 먼저 탐색하되 각 버킷 안에서는 sort_moves 순서를 유지한다.
	var corners: Array = []
	var edges: Array = []
	var inner: Array = []
	for move in moves:
		var x := int(move["x"])
		var y := int(move["y"])
		var is_edge := x == 0 or x == BOARD_SIZE - 1 or y == 0 or y == BOARD_SIZE - 1
		var is_corner := (x == 0 or x == BOARD_SIZE - 1) and (y == 0 or y == BOARD_SIZE - 1)
		if is_corner:
			corners.append(move)
		elif is_edge:
			edges.append(move)
		else:
			inner.append(move)
	return corners + edges + inner


static func _record_search_stat(search_stats: Dictionary, key: String) -> void:
	# 빈 Dictionary는 일반 게임 경로다. 테스트가 키를 미리 넣은 경우에만 계측한다.
	if search_stats.is_empty():
		return
	search_stats[key] = int(search_stats.get(key, 0)) + 1


static func _weighted_cell(board: Array, point: Vector2i, stone: int, value: int) -> int:
	var cell := int(board[point.x][point.y])
	if cell == stone:
		return value
	if cell == opponent(stone):
		return -value
	return 0


static func _in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < BOARD_SIZE and y >= 0 and y < BOARD_SIZE


static func _move_list_has(moves: Array, x: int, y: int) -> bool:
	for move in moves:
		if int(move["x"]) == x and int(move["y"]) == y:
			return true
	return false


static func _append_u16_le(payload: PackedByteArray, value: int) -> void:
	payload.append(value & 0xff)
	payload.append((value >> 8) & 0xff)


static func _read_u16_le(payload: PackedByteArray, offset: int) -> int:
	return int(payload[offset]) | (int(payload[offset + 1]) << 8)
