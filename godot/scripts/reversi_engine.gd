extends RefCounted

const DEFAULT_BOARD_SIZE := 8
# 기존 8×8 fixture와 외부 호출의 호환용 별칭. 실제 규칙은 board 배열 크기를 사용한다.
const BOARD_SIZE := DEFAULT_BOARD_SIZE
const SUPPORTED_BOARD_SIZES := [6, 8, 10]
const NONE := 0
const BLACK := 1
const WHITE := 2
const VALID := 3
const SEARCH_MIN := -9223372036854775807
const SEARCH_MAX := 9223372036854775807
const MOBILITY_WEIGHT := DEFAULT_BOARD_SIZE
const DISC_WEIGHT_OPENING := 0
const DISC_WEIGHT_MIDDLE := 1
const DISC_WEIGHT_ENDGAME := 4
const CODEC_MAGIC_0 := 0x4c
const CODEC_MAGIC_1 := 0x52
const CODEC_VERSION := 2
const CODEC_HEADER_SIZE := 5

const DIFFICULTY_DEPTH := {
	"EASY": 1,
	"MEDIUM": 3,
	"HARD": 5,
}
const ENDGAME_EXACT_EMPTIES := {
	"MEDIUM": 6,
	"HARD": 8,
}

const DIRECTIONS := [
	Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1),
	Vector2i(0, -1), Vector2i(0, 1),
	Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1),
]


static func default_settings() -> Dictionary:
	return {
		"sound": true,
		"haptic": true,
		"locale": "ko",
		"theme": "classic",
		"stone_theme": "classic",
		"font_scale": 1.0,
		"reduce_motion": false,
		"high_contrast": false,
		"show_moves": true,
		"show_flip_counts": false,
		"board_size": DEFAULT_BOARD_SIZE,
	}


static func normalize_settings(raw_settings: Dictionary) -> Dictionary:
	var defaults := default_settings()
	var normalized := defaults.duplicate()
	for key in raw_settings.keys():
		if defaults.has(key):
			normalized[key] = raw_settings[key]
	normalized["board_size"] = normalize_board_size(
		int(raw_settings.get("board_size", DEFAULT_BOARD_SIZE))
	)
	return normalized


static func normalize_board_size(value: int) -> int:
	if SUPPORTED_BOARD_SIZES.has(value):
		return value
	if value <= 6:
		return 6
	if value >= 10:
		return 10
	return DEFAULT_BOARD_SIZE


static func default_preferences(default_locale: String = "ko") -> Dictionary:
	var settings := default_settings()
	settings["locale"] = default_locale
	return {
		"version": 1,
		"difficulty": "MEDIUM",
		"how_to_play_seen": false,
		"settings": settings,
	}


static func normalize_preferences(raw_preferences: Dictionary, default_locale: String = "ko") -> Dictionary:
	var normalized := default_preferences(default_locale)
	var difficulty := str(raw_preferences.get("difficulty", "MEDIUM"))
	if DIFFICULTY_DEPTH.has(difficulty):
		normalized["difficulty"] = difficulty
	normalized["how_to_play_seen"] = bool(raw_preferences.get("how_to_play_seen", false))
	var raw_settings_value = raw_preferences.get("settings", {})
	if typeof(raw_settings_value) == TYPE_DICTIONARY:
		normalized["settings"] = normalize_settings(raw_settings_value)
	return normalized


static func preferences_from_legacy_save(saved: Dictionary, default_locale: String = "ko") -> Dictionary:
	if !saved.has("settings") and !saved.has("difficulty"):
		return {}
	return normalize_preferences({
		"difficulty": saved.get("difficulty", "MEDIUM"),
		"settings": saved.get("settings", {}),
	}, default_locale)


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


static func create_new_game(
	player_stone: int = BLACK,
	difficulty: String = "MEDIUM",
	board_size: int = DEFAULT_BOARD_SIZE,
	game_seed: int = -1,
) -> Dictionary:
	var normalized_size := normalize_board_size(board_size)
	var board := _initial_board(normalized_size)
	var settings := default_settings()
	settings["board_size"] = normalized_size
	var normalized_seed := game_seed if game_seed >= 0 else _generate_game_seed()
	var state := {
		"version": 1,
		"board": board,
		"current_turn": BLACK,
		"player_stone": player_stone,
		"ai_stone": opponent(player_stone),
		"difficulty": difficulty,
		"game_seed": normalized_seed,
		"valid_moves": get_valid_moves(board, BLACK),
		"move_history": [],
		"settings": settings,
		"stats": default_stats(),
		"last_move": {},
		"pass_count": 0,
		"last_turn_was_pass": false,
		"game_over": false,
		"winner": NONE,
		"last_saved_at": 0,
	}
	_refresh_result(state)
	return state


static func create_state_from_board(
	board: Array,
	current_turn: int = BLACK,
	player_stone: int = BLACK,
	difficulty: String = "MEDIUM",
	game_seed: int = -1,
) -> Dictionary:
	var board_size := get_board_size(board)
	if board_size == 0:
		return {}
	var settings := default_settings()
	settings["board_size"] = board_size
	var normalized_seed := game_seed if game_seed >= 0 else _generate_game_seed()
	var state := {
		"version": 1,
		"board": clone_board(board),
		"current_turn": current_turn,
		"player_stone": player_stone,
		"ai_stone": opponent(player_stone),
		"difficulty": difficulty,
		"game_seed": normalized_seed,
		"valid_moves": get_valid_moves(board, current_turn),
		"move_history": [],
		"settings": settings,
		"stats": default_stats(),
		"last_move": {},
		"pass_count": 0,
		"last_turn_was_pass": false,
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
		get_board_size(state.get("board", [])),
		int(state.get("game_seed", -1)),
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
	var board_size := get_board_size(board)
	if board_size == 0:
		return []

	var moves: Array = []
	for x in range(board_size):
		for y in range(board_size):
			if _is_valid_move(board, stone, x, y):
				moves.append({"x": x, "y": y})
	return sort_moves(moves)


static func count_flips(board: Array, stone: int, x: int, y: int) -> int:
	if stone != BLACK and stone != WHITE:
		return 0
	if !_in_bounds(board, x, y) or int(board[x][y]) != NONE:
		return 0

	var total := 0
	for direction in DIRECTIONS:
		total += _direction_flips(board, stone, x, y, direction).size()
	return total


static func choose_ai_move(state: Dictionary, search_stats: Dictionary = {}) -> Dictionary:
	var stone: int = int(state.get("current_turn", NONE))
	var board: Array = state.get("board", [])
	var moves := get_valid_moves(board, stone)
	if moves.is_empty():
		return {}

	var difficulty := str(state.get("difficulty", "MEDIUM"))
	var depth := int(DIFFICULTY_DEPTH.get(difficulty, 3))
	var empty_count := _count_empty_cells(board)
	var exact_threshold := int(ENDGAME_EXACT_EMPTIES.get(difficulty, -1))
	var use_exact_search := exact_threshold >= 0 and empty_count <= exact_threshold
	var best_score := SEARCH_MIN
	var best_moves: Array = []
	for move in moves:
		var board_after := clone_board(board)
		_apply_move(board_after, stone, int(move["x"]), int(move["y"]))
		var next_turn := _next_turn_for_board(board_after, stone)
		var score := (
			_search_exact_score(
				board_after,
				next_turn,
				stone,
				SEARCH_MIN,
				SEARCH_MAX,
				search_stats,
			)
			if use_exact_search
			else _search_score(
				board_after,
				next_turn,
				stone,
				depth - 1,
				SEARCH_MIN,
				SEARCH_MAX,
				search_stats,
			)
		)
		if score > best_score:
			best_score = score
			best_moves = [move]
		elif score == best_score:
			best_moves.append(move)

	if !search_stats.is_empty():
		search_stats["best_score"] = best_score
		search_stats["tie_count"] = best_moves.size()
		search_stats["empty_count"] = empty_count
		search_stats["exact_search"] = use_exact_search
	if best_moves.is_empty():
		return {}
	if best_moves.size() == 1:
		return best_moves[0]

	# 모든 난이도에서 최적 점수는 유지하되, 대국 seed로 동점 최선 수만 분산한다.
	var rng := RandomNumberGenerator.new()
	rng.seed = _ai_tie_seed(state, stone)
	return best_moves[rng.randi_range(0, best_moves.size() - 1)]


static func encode_board_payload(board: Array, current_turn: int, valid_moves: Array = []) -> PackedByteArray:
	var board_size := get_board_size(board)
	if board_size == 0:
		return PackedByteArray()

	var payload := PackedByteArray()
	payload.append(CODEC_MAGIC_0)
	payload.append(CODEC_MAGIC_1)
	payload.append(CODEC_VERSION)
	payload.append(board_size)
	payload.append(current_turn & 0xff)

	var packed_byte := 0
	var packed_count := 0
	for x in range(board_size):
		for y in range(board_size):
			var cell := int(board[x][y])
			if cell == NONE and _move_list_has(valid_moves, x, y):
				cell = VALID
			var shift := (3 - packed_count) * 2
			packed_byte |= (cell & 3) << shift
			packed_count += 1
			if packed_count == 4:
				payload.append(packed_byte)
				packed_byte = 0
				packed_count = 0
	if packed_count > 0:
		payload.append(packed_byte)
	return payload


static func decode_board_payload(payload: PackedByteArray) -> Dictionary:
	if payload.size() == 18:
		return _decode_legacy_board_payload(payload)
	if payload.size() < CODEC_HEADER_SIZE:
		return {}
	if (
		int(payload[0]) != CODEC_MAGIC_0
		or int(payload[1]) != CODEC_MAGIC_1
		or int(payload[2]) != CODEC_VERSION
	):
		return {}

	var board_size := int(payload[3])
	if !SUPPORTED_BOARD_SIZES.has(board_size):
		return {}
	var packed_size := int(ceili(float(board_size * board_size) / 4.0))
	if payload.size() != CODEC_HEADER_SIZE + packed_size:
		return {}

	var board: Array = []
	var valid_moves: Array = []
	var cell_index := 0
	for x in range(board_size):
		var row: Array = []
		for y in range(board_size):
			var packed_byte := int(payload[CODEC_HEADER_SIZE + int(cell_index / 4)])
			var shift := (3 - cell_index % 4) * 2
			var cell := (packed_byte >> shift) & 3
			if cell == VALID:
				row.append(NONE)
				valid_moves.append({"x": x, "y": y})
			else:
				row.append(cell)
			cell_index += 1
		board.append(row)

	return {
		"board": board,
		"current_turn": int(payload[4]),
		"valid_moves": sort_moves(valid_moves),
	}


static func _decode_legacy_board_payload(payload: PackedByteArray) -> Dictionary:
	var board: Array = []
	var valid_moves: Array = []
	for x in range(DEFAULT_BOARD_SIZE):
		var row_value := _read_u16_le(payload, x * 2)
		var row: Array = []
		for y in range(DEFAULT_BOARD_SIZE):
			var shift := (DEFAULT_BOARD_SIZE - 1 - y) * 2
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
		"game_seed": int(state.get("game_seed", 0)),
		"board_codec": Marshalls.raw_to_base64(payload),
		"move_history": state.get("move_history", []),
		"pass_count": int(state.get("pass_count", 0)),
		"last_turn_was_pass": bool(state.get("last_turn_was_pass", false)),
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
	var restored_seed := int(saved.get("game_seed", _seed_from_payload(payload)))

	var state := create_state_from_board(
		decoded["board"],
		int(saved.get("current_turn", decoded["current_turn"])),
		int(saved.get("player_stone", BLACK)),
		str(saved.get("difficulty", "MEDIUM")),
		restored_seed,
	)
	state["ai_stone"] = int(saved.get("ai_stone", opponent(int(state["player_stone"]))))
	state["move_history"] = saved.get("move_history", [])
	state["pass_count"] = int(saved.get("pass_count", 0))
	state["last_turn_was_pass"] = bool(saved.get("last_turn_was_pass", false))
	var settings := normalize_settings(saved.get("settings", default_settings()))
	settings["board_size"] = get_board_size(decoded["board"])
	state["settings"] = settings
	state["stats"] = normalize_stats(saved.get("stats", {}))
	state["last_saved_at"] = int(saved.get("last_saved_at", 0))
	return state


static func _generate_game_seed() -> int:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return int(rng.randi()) & 0x7fffffff


static func _seed_from_payload(payload: PackedByteArray) -> int:
	var seed := 2166136261 & 0x7fffffff
	for byte in payload:
		seed = ((seed ^ int(byte)) * 16777619) & 0x7fffffff
	return seed


static func _ai_tie_seed(state: Dictionary, stone: int) -> int:
	var seed := int(state.get("game_seed", 0)) & 0x7fffffff
	seed = (seed * 1103515245 + stone + 12345) & 0x7fffffff
	var board: Array = state.get("board", [])
	for row in board:
		for cell in row:
			seed = (seed * 31 + int(cell) + 1) & 0x7fffffff
	return seed


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


static func _count_empty_cells(board: Array) -> int:
	var board_size := get_board_size(board)
	if board_size == 0:
		return 0
	var counts := count_pieces(board)
	return board_size * board_size - int(counts["black"]) - int(counts["white"])


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


static func get_board_size(board: Array) -> int:
	var size := board.size()
	if !SUPPORTED_BOARD_SIZES.has(size):
		return 0
	for row_value in board:
		if typeof(row_value) != TYPE_ARRAY or row_value.size() != size:
			return 0
	return size


static func sort_moves(moves: Array) -> Array:
	moves.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["x"]) == int(b["x"]):
			return int(a["y"]) < int(b["y"])
		return int(a["x"]) < int(b["x"])
	)
	return moves


static func _initial_board(board_size: int = DEFAULT_BOARD_SIZE) -> Array:
	var normalized_size := normalize_board_size(board_size)
	var board: Array = []
	for _x in range(normalized_size):
		var row: Array = []
		for _y in range(normalized_size):
			row.append(NONE)
		board.append(row)

	var center := int(normalized_size / 2)
	board[center - 1][center - 1] = WHITE
	board[center - 1][center] = BLACK
	board[center][center - 1] = BLACK
	board[center][center] = WHITE
	return board


static func _is_valid_move(board: Array, stone: int, x: int, y: int) -> bool:
	if !_in_bounds(board, x, y):
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

	while _in_bounds(board, cx, cy) and int(board[cx][cy]) == other:
		flipped.append(Vector2i(cx, cy))
		cx += direction.x
		cy += direction.y

	if flipped.is_empty():
		return []
	if !_in_bounds(board, cx, cy):
		return []
	if int(board[cx][cy]) != stone:
		return []
	return flipped


static func _resolve_next_turn(state: Dictionary, just_played: int) -> void:
	state["last_turn_was_pass"] = false
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
		state["last_turn_was_pass"] = true
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
	for move in _order_search_moves(moves, get_board_size(board)):
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


static func _search_exact_score(
	board: Array,
	turn: int,
	root_stone: int,
	alpha: int,
	beta: int,
	search_stats: Dictionary = {},
) -> int:
	_record_search_stat(search_stats, "exact_nodes")
	if turn == NONE:
		_record_search_stat(search_stats, "exact_terminals")
		return _terminal_piece_difference(board, root_stone)

	var moves := get_valid_moves(board, turn)
	if moves.is_empty():
		var other := opponent(turn)
		if get_valid_moves(board, other).is_empty():
			_record_search_stat(search_stats, "exact_terminals")
			return _terminal_piece_difference(board, root_stone)
		_record_search_stat(search_stats, "exact_passes")
		return _search_exact_score(
			board,
			other,
			root_stone,
			alpha,
			beta,
			search_stats,
		)

	var maximizing := turn == root_stone
	var best := SEARCH_MIN if maximizing else SEARCH_MAX
	for move in _order_search_moves(moves, get_board_size(board)):
		var next_board := clone_board(board)
		_apply_move(next_board, turn, int(move["x"]), int(move["y"]))
		var next_turn := _next_turn_for_board(next_board, turn)
		var score := _search_exact_score(
			next_board,
			next_turn,
			root_stone,
			alpha,
			beta,
			search_stats,
		)
		if maximizing:
			best = max(best, score)
			alpha = max(alpha, best)
			if best >= beta:
				_record_search_stat(search_stats, "exact_max_cutoffs")
				break
		else:
			best = min(best, score)
			beta = min(beta, best)
			if best <= alpha:
				_record_search_stat(search_stats, "exact_min_cutoffs")
				break
	return best


static func _terminal_piece_difference(board: Array, stone: int) -> int:
	var counts := count_pieces(board)
	var score := int(counts["black"]) - int(counts["white"])
	return score if stone == BLACK else -score


static func _evaluate_board(board: Array, stone: int) -> int:
	var board_size := get_board_size(board)
	if board_size == 0:
		return 0
	var counts := count_pieces(board)
	var score := int(counts["black"]) - int(counts["white"])
	if stone == WHITE:
		score *= -1
	score *= _disc_weight_for_board(board)

	score += _mobility_score(board, stone)

	var corner_value := board_size * 3
	var edge_value := board_size * 2
	var pre_corner_value := -board_size * 2
	var corner_path_value := -board_size
	var last := board_size - 1
	var near_last := board_size - 2

	for point in [Vector2i(0, 0), Vector2i(0, last), Vector2i(last, 0), Vector2i(last, last)]:
		score += _weighted_cell(board, point, stone, corner_value)

	for point in [Vector2i(1, 1), Vector2i(1, near_last), Vector2i(near_last, 1), Vector2i(near_last, near_last)]:
		score += _weighted_cell(board, point, stone, pre_corner_value)

	for x in range(board_size):
		for y in range(board_size):
			var is_edge := x == 0 or y == 0 or x == last or y == last
			var is_corner := (x == 0 or x == last) and (y == 0 or y == last)
			if is_edge and !is_corner:
				score += _weighted_cell(board, Vector2i(x, y), stone, edge_value)

	for offset in range(2, board_size - 2):
		for point in [
			Vector2i(1, offset),
			Vector2i(offset, 1),
			Vector2i(near_last, offset),
			Vector2i(offset, near_last),
		]:
			score += _weighted_cell(board, point, stone, corner_path_value)

	return score


static func _disc_weight_for_board(board: Array) -> int:
	var board_size := get_board_size(board)
	if board_size == 0:
		return DISC_WEIGHT_OPENING
	var total_cells := board_size * board_size
	var empty_cells := _count_empty_cells(board)
	if empty_cells * 3 >= total_cells * 2:
		return DISC_WEIGHT_OPENING
	if empty_cells * 3 >= total_cells:
		return DISC_WEIGHT_MIDDLE
	return DISC_WEIGHT_ENDGAME


static func _mobility_score(board: Array, stone: int) -> int:
	var own_moves := get_valid_moves(board, stone).size()
	var opponent_moves := get_valid_moves(board, opponent(stone)).size()
	return (own_moves - opponent_moves) * get_board_size(board)


static func _order_search_moves(moves: Array, board_size: int = DEFAULT_BOARD_SIZE) -> Array:
	# 모서리와 가장자리를 먼저 탐색하되 각 버킷 안에서는 sort_moves 순서를 유지한다.
	var corners: Array = []
	var edges: Array = []
	var inner: Array = []
	for move in moves:
		var x := int(move["x"])
		var y := int(move["y"])
		var is_edge := x == 0 or x == board_size - 1 or y == 0 or y == board_size - 1
		var is_corner := (x == 0 or x == board_size - 1) and (y == 0 or y == board_size - 1)
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
	if !_in_bounds(board, point.x, point.y):
		return 0
	var cell := int(board[point.x][point.y])
	if cell == stone:
		return value
	if cell == opponent(stone):
		return -value
	return 0


static func _in_bounds(board: Array, x: int, y: int) -> bool:
	return (
		x >= 0
		and x < board.size()
		and y >= 0
		and y < board[x].size()
	)


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
