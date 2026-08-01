extends Control

const ReversiEngine = preload("res://scripts/reversi_engine.gd")
const ReversiAnalytics = preload("res://scripts/analytics.gd")
const PuzzleCatalog = preload("res://scripts/puzzle_catalog.gd")
const GA4_SENDER_SCRIPT = preload("res://scripts/ga4_mp_sender.gd")
const IOS_ADS_SCRIPT = preload("res://scripts/ios_ads.gd")
const PLACE_SFX = preload("res://assets/audio/place.wav")
const FLIP_SFX = preload("res://assets/audio/flip.wav")
const BIG_FLIP_SFX = preload("res://assets/audio/big_flip.wav")
const BGM_STREAM = preload("res://assets/audio/bgm_lucid_board.ogg")
const CLASSIC_BLACK_TEXTURE = preload("res://assets/reversi/themes/classic_black.svg")
const CLASSIC_WHITE_TEXTURE = preload("res://assets/reversi/themes/classic_white.svg")
const ARCTIC_BLACK_TEXTURE = preload("res://assets/reversi/themes/arctic_black.svg")
const ARCTIC_WHITE_TEXTURE = preload("res://assets/reversi/themes/arctic_white.svg")
const EMBER_BLACK_TEXTURE = preload("res://assets/reversi/themes/ember_black.svg")
const EMBER_WHITE_TEXTURE = preload("res://assets/reversi/themes/ember_white.svg")
const SAKURA_BLACK_TEXTURE = preload("res://assets/reversi/themes/sakura_black.svg")
const SAKURA_WHITE_TEXTURE = preload("res://assets/reversi/themes/sakura_white.svg")
const UI_FONT = preload("res://assets/fonts/DoHyeon-Regular.ttf")
const JAPANESE_FONT = preload("res://assets/fonts/MPLUSRounded1c-Regular.ttf")

const SAVE_PATH := "user://save_v1.json"
const PREFS_PATH := "user://prefs_v1.json"
const SUPPORT_EMAIL := "cs@seorilabs.com"
const PRIVACY_POLICY_URL := ""
const DESIGN_VIEWPORT_SIZE := Vector2(720, 1280)
const CELL_SIZE := 84
const CELL_GAP := 2
const BOARD_PADDING := 4
const BOARD_COORDINATE_GUTTER := 20
const BOARD_COORDINATE_GAP := 2
const BOARD_GUIDE_POINT_SIZE := 7
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
const LEGAL_MOVE_GHOST_ALPHA := 0.42
const LEGAL_MOVE_GHOST_SCALE := 0.86
const BGM_VOLUME_DB := -24.0
const SFX_BUS := &"SFX"
const MUSIC_BUS := &"Music"
const AI_THINK_DELAY_BASE := {
	"EASY": 0.16,
	"MEDIUM": 0.32,
	"HARD": 0.48,
}
const AI_THINK_DELAY_JITTER := 0.04
const DIFFICULTY_IDS := ["EASY", "MEDIUM", "HARD"]
const OPPONENT_MODE_IDS := ["ai", "local"]
const VARIANT_IDS := [ReversiEngine.VARIANT_STANDARD, ReversiEngine.VARIANT_ANTI]
const BOARD_SIZE_IDS := ["6", "8", "10"]
const BOARD_SIZE_LABELS := ["6×6", "8×8", "10×10"]
const THEME_IDS := ["classic", "arctic", "ember", "forest", "sakura"]
const THEME_LABELS := ["CLASSIC", "ARCTIC", "EMBER", "FOREST", "SAKURA"]
const STONE_THEME_IDS := ["classic", "arctic", "ember", "sakura"]
const STONE_THEME_LABELS := ["CLASSIC", "ARCTIC", "EMBER", "SAKURA"]
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
		"difficulty_easy_description": "다음 수를 중심으로 가볍게 살핍니다.",
		"difficulty_medium_description": "여러 수 앞의 흐름을 균형 있게 읽습니다.",
		"difficulty_hard_description": "장기 흐름까지 깊게 읽어 도전합니다.",
		"new_game": "새 게임",
		"confirm_new_game_title": "대국을 새로 시작할까요?",
		"confirm_new_game_body": "진행 중인 대국은 저장되지 않습니다.",
		"confirm_yes": "확인",
		"confirm_no": "취소",
		"undo": "무르기",
		"hint": "힌트",
		"restart": "다시",
		"board": "보드",
		"share_result": "공유",
		"replay": "리플레이",
		"replay_previous": "이전",
		"replay_play": "재생",
		"replay_pause": "일시정지",
		"replay_next": "다음",
		"replay_close": "닫기",
		"replay_step": "%d / %d수",
		"settings": "설정",
		"close": "닫기",
		"sound": "소리",
		"music": "음악",
		"haptic": "진동",
		"difficulty_setting": "난이도",
		"opponent_mode_setting": "대전 상대",
		"opponent_ai": "AI",
		"opponent_local": "2인",
		"variant_setting": "규칙",
		"variant_standard": "표준",
		"variant_anti": "역",
		"puzzle_section": "퍼즐",
		"puzzle_entry": "퍼즐 도전",
		"puzzle_select_title": "퍼즐 선택",
		"puzzle_select_intro": "정해진 국면에서 목표를 달성하세요.",
		"puzzle_start": "도전",
		"puzzle_difficulty": "권장 난이도 · %s",
		"puzzle_complete": "퍼즐 성공",
		"puzzle_failed": "퍼즐 실패",
		"puzzle_standard_game": "일반 새 게임",
		"puzzle_corner_title": "코너를 잡아라",
		"puzzle_corner_description": "위험한 끝내기 국면에서 왼쪽 위 코너를 확보하세요.",
		"puzzle_corner_goal": "목표 · 왼쪽 위 코너에 흑 돌 놓기",
		"puzzle_comeback_title": "마지막 역전",
		"puzzle_comeback_description": "남은 8칸의 수순을 읽어 흑으로 승리하세요.",
		"puzzle_comeback_goal": "목표 · 종국에 흑 승리",
		"puzzle_white_title": "백의 마무리",
		"puzzle_white_description": "마지막 빈칸을 찾아 백의 승리를 완성하세요.",
		"puzzle_white_goal": "목표 · 종국에 백 승리",
		"black_player": "흑 플레이어",
		"white_player": "백 플레이어",
		"board_size_setting": "보드 크기",
		"board_theme_title": "보드",
		"stone_theme_title": "돌",
		"language_setting": "언어",
		"how_to_play_entry": "플레이 방법",
		"how_to_play_title": "플레이 방법",
		"how_to_play_place_title": "1. 착수",
		"how_to_play_place_body": "상대 돌을 하나 이상 뒤집을 수 있는 빈칸에 내 돌을 놓습니다.",
		"how_to_play_flip_title": "2. 뒤집기",
		"how_to_play_flip_body": "새 돌과 기존 내 돌 사이에 가로·세로·대각선으로 낀 상대 돌을 모두 내 색으로 뒤집습니다.",
		"how_to_play_pass_title": "3. 패스",
		"how_to_play_pass_body": "둘 수 있는 합법수가 없으면 자동으로 패스하고 상대가 계속 둡니다.",
		"how_to_play_finish_title": "4. 종료와 승패",
		"how_to_play_finish_body": "보드가 가득 차거나 양쪽 모두 둘 곳이 없으면 끝납니다. 내 색 돌이 더 많으면 승리합니다.",
		"how_to_play_previous": "이전",
		"how_to_play_next": "다음",
		"how_to_play_done": "완료",
		"how_to_play_skip": "건너뛰기",
		"how_to_play_progress": "%d / %d",
		"move_list_entry": "기보 %02d · %s",
		"move_list_title": "기보",
		"move_list_empty": "아직 기록된 수가 없습니다.",
		"about_title": "정보",
		"about_app_version": "%s · 버전 %s",
		"support_email": "지원 이메일 · %s",
		"privacy_policy": "개인정보 처리방침",
		"font_scale_setting": "글자 크기",
		"reduce_motion": "모션 줄이기",
		"high_contrast": "고대비 색상",
		"show_moves": "착수 표시",
		"show_flip_counts": "뒤집기 수",
		"board_theme": "보드 %s",
		"stone_theme": "돌 %s",
		"locale": "언어 %s",
		"theme_classic": "기본",
		"theme_arctic": "빙하",
		"theme_ember": "노을",
		"theme_forest": "숲",
		"theme_sakura": "벚꽃",
		"status_game_over": "게임 종료",
		"status_flip": "뒤집는 중",
		"status_ai_thinking": "AI 생각 중",
		"status_pass": "패스",
		"status_your_move": "내 차례",
		"status_ai_turn": "AI 차례",
		"status_black_turn": "흑 차례",
		"status_white_turn": "백 차례",
		"turn_final": "종료",
		"turn_player": "차례",
		"turn_ai": "AI",
		"turn_black": "흑",
		"turn_white": "백",
		"focus_even": "균형",
		"focus_player_leads": "우세 +%d",
		"focus_ai_leads": "추격 -%d",
		"focus_black_leads": "흑 우세 +%d",
		"focus_white_leads": "백 우세 +%d",
		"focus_valid": "착수 %d",
		"result_win": "승리",
		"result_draw": "무승부",
		"result_lose": "패배",
		"result_black_wins": "흑 승리",
		"result_white_wins": "백 승리",
		"result_detail": "흑 %d / 백 %d",
		"result_highlights_title": "이 판 하이라이트",
		"result_highlight_flip": "최대 뒤집기 · %s %s · %d개",
		"result_highlight_corners": "코너 확보 · 흑 %d / 백 %d",
		"result_highlight_lead": "최대 우세 · %s +%d",
		"result_share_text": "%s\n%s\n%s",
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
		"difficulty_easy_description": "Looks just ahead for a relaxed game.",
		"difficulty_medium_description": "Reads several moves for balanced play.",
		"difficulty_hard_description": "Reads deep into the game for a challenge.",
		"new_game": "NEW",
		"confirm_new_game_title": "START A NEW GAME?",
		"confirm_new_game_body": "Your current game will be discarded.",
		"confirm_yes": "CONFIRM",
		"confirm_no": "CANCEL",
		"undo": "UNDO",
		"hint": "HINT",
		"restart": "RESTART",
		"board": "BOARD",
		"share_result": "SHARE",
		"replay": "REPLAY",
		"replay_previous": "BACK",
		"replay_play": "PLAY",
		"replay_pause": "PAUSE",
		"replay_next": "NEXT",
		"replay_close": "CLOSE",
		"replay_step": "MOVE %d / %d",
		"settings": "SET",
		"close": "CLOSE",
		"sound": "SOUND",
		"music": "MUSIC",
		"haptic": "HAPTIC",
		"difficulty_setting": "LEVEL",
		"opponent_mode_setting": "OPPONENT",
		"opponent_ai": "AI",
		"opponent_local": "2 PLAYERS",
		"variant_setting": "RULES",
		"variant_standard": "STANDARD",
		"variant_anti": "ANTI",
		"puzzle_section": "PUZZLES",
		"puzzle_entry": "PUZZLE CHALLENGE",
		"puzzle_select_title": "CHOOSE A PUZZLE",
		"puzzle_select_intro": "Reach the objective from a fixed board position.",
		"puzzle_start": "START",
		"puzzle_difficulty": "RECOMMENDED · %s",
		"puzzle_complete": "PUZZLE CLEARED",
		"puzzle_failed": "PUZZLE FAILED",
		"puzzle_standard_game": "STANDARD NEW GAME",
		"puzzle_corner_title": "TAKE THE CORNER",
		"puzzle_corner_description": "Secure the upper-left corner in this sharp endgame.",
		"puzzle_corner_goal": "GOAL · PLACE BLACK IN THE UPPER-LEFT CORNER",
		"puzzle_comeback_title": "FINAL COMEBACK",
		"puzzle_comeback_description": "Read the final eight squares and win as Black.",
		"puzzle_comeback_goal": "GOAL · BLACK WINS AT THE END",
		"puzzle_white_title": "WHITE FINISH",
		"puzzle_white_description": "Find the last move and complete White's victory.",
		"puzzle_white_goal": "GOAL · WHITE WINS AT THE END",
		"black_player": "BLACK PLAYER",
		"white_player": "WHITE PLAYER",
		"board_size_setting": "BOARD SIZE",
		"board_theme_title": "BOARD",
		"stone_theme_title": "STONE",
		"language_setting": "LANG",
		"how_to_play_entry": "HOW TO PLAY",
		"how_to_play_title": "HOW TO PLAY",
		"how_to_play_place_title": "1. PLACE",
		"how_to_play_place_body": "Place a disc on an empty square only when it flips at least one opponent disc.",
		"how_to_play_flip_title": "2. FLIP",
		"how_to_play_flip_body": "Flip every opponent disc bracketed horizontally, vertically, or diagonally by your new disc and another of your discs.",
		"how_to_play_pass_title": "3. PASS",
		"how_to_play_pass_body": "If you have no legal move, your turn passes automatically and your opponent continues.",
		"how_to_play_finish_title": "4. END AND WINNER",
		"how_to_play_finish_body": "The game ends when the board is full or neither player can move. The player with more discs wins.",
		"how_to_play_previous": "BACK",
		"how_to_play_next": "NEXT",
		"how_to_play_done": "DONE",
		"how_to_play_skip": "SKIP",
		"how_to_play_progress": "%d / %d",
		"move_list_entry": "MOVES %02d · %s",
		"move_list_title": "MOVE LIST",
		"move_list_empty": "NO MOVES RECORDED YET.",
		"about_title": "ABOUT",
		"about_app_version": "%s · VERSION %s",
		"support_email": "SUPPORT · %s",
		"privacy_policy": "PRIVACY POLICY",
		"font_scale_setting": "TEXT SIZE",
		"reduce_motion": "REDUCE MOTION",
		"high_contrast": "HIGH CONTRAST",
		"show_moves": "MOVES",
		"show_flip_counts": "FLIP COUNTS",
		"board_theme": "BOARD %s",
		"stone_theme": "STONE %s",
		"locale": "LANG %s",
		"theme_classic": "CLASSIC",
		"theme_arctic": "ARCTIC",
		"theme_ember": "EMBER",
		"theme_forest": "FOREST",
		"theme_sakura": "SAKURA",
		"status_game_over": "GAME OVER",
		"status_flip": "FLIP",
		"status_ai_thinking": "AI THINKING",
		"status_pass": "PASS",
		"status_your_move": "YOUR MOVE",
		"status_ai_turn": "AI TURN",
		"status_black_turn": "BLACK TO MOVE",
		"status_white_turn": "WHITE TO MOVE",
		"turn_final": "FINAL",
		"turn_player": "TURN",
		"turn_ai": "AI",
		"turn_black": "BLACK",
		"turn_white": "WHITE",
		"focus_even": "EVEN",
		"focus_player_leads": "LEAD +%d",
		"focus_ai_leads": "CHASE -%d",
		"focus_black_leads": "BLACK +%d",
		"focus_white_leads": "WHITE +%d",
		"focus_valid": "VALID %d",
		"result_win": "WIN",
		"result_draw": "DRAW",
		"result_lose": "LOSE",
		"result_black_wins": "BLACK WINS",
		"result_white_wins": "WHITE WINS",
		"result_detail": "BLACK %d / WHITE %d",
		"result_highlights_title": "GAME HIGHLIGHTS",
		"result_highlight_flip": "BIGGEST FLIP · %s %s · %d",
		"result_highlight_corners": "CORNERS · BLACK %d / WHITE %d",
		"result_highlight_lead": "PEAK LEAD · %s +%d",
		"result_share_text": "%s\n%s\n%s",
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
		"difficulty_easy_description": "次の一手を中心に気軽に考えます。",
		"difficulty_medium_description": "数手先の流れをバランスよく読みます。",
		"difficulty_hard_description": "長い流れまで深く読み、挑戦します。",
		"new_game": "新しい対局",
		"confirm_new_game_title": "新しい対局を始めますか？",
		"confirm_new_game_body": "進行中の対局は保存されません。",
		"confirm_yes": "決定",
		"confirm_no": "キャンセル",
		"undo": "一手戻す",
		"hint": "ヒント",
		"restart": "もう一度",
		"board": "盤面",
		"share_result": "共有",
		"replay": "リプレイ",
		"replay_previous": "戻る",
		"replay_play": "再生",
		"replay_pause": "一時停止",
		"replay_next": "次へ",
		"replay_close": "閉じる",
		"replay_step": "%d / %d手",
		"settings": "設定",
		"close": "閉じる",
		"sound": "サウンド",
		"music": "音楽",
		"haptic": "振動",
		"difficulty_setting": "難易度",
		"opponent_mode_setting": "対戦相手",
		"opponent_ai": "AI",
		"opponent_local": "2人",
		"variant_setting": "ルール",
		"variant_standard": "標準",
		"variant_anti": "逆転",
		"puzzle_section": "パズル",
		"puzzle_entry": "パズルに挑戦",
		"puzzle_select_title": "パズル選択",
		"puzzle_select_intro": "決められた局面から目標を達成しましょう。",
		"puzzle_start": "挑戦",
		"puzzle_difficulty": "推奨難易度 · %s",
		"puzzle_complete": "パズル成功",
		"puzzle_failed": "パズル失敗",
		"puzzle_standard_game": "通常の新しい対局",
		"puzzle_corner_title": "コーナーを取れ",
		"puzzle_corner_description": "鋭い終盤で左上のコーナーを確保しましょう。",
		"puzzle_corner_goal": "目標 · 左上のコーナーに黒石を置く",
		"puzzle_comeback_title": "最後の逆転",
		"puzzle_comeback_description": "残り8マスの手順を読み、黒で勝利しましょう。",
		"puzzle_comeback_goal": "目標 · 終局時に黒の勝利",
		"puzzle_white_title": "白の仕上げ",
		"puzzle_white_description": "最後の一手を見つけ、白の勝利を完成させましょう。",
		"puzzle_white_goal": "目標 · 終局時に白の勝利",
		"black_player": "黒プレイヤー",
		"white_player": "白プレイヤー",
		"board_size_setting": "盤面サイズ",
		"board_theme_title": "盤面",
		"stone_theme_title": "石",
		"language_setting": "言語",
		"how_to_play_entry": "遊び方",
		"how_to_play_title": "遊び方",
		"how_to_play_place_title": "1. 石を置く",
		"how_to_play_place_body": "相手の石を1つ以上返せる空きマスに自分の石を置きます。",
		"how_to_play_flip_title": "2. 石を返す",
		"how_to_play_flip_body": "新しい石と自分の石で縦・横・斜めに挟んだ相手の石をすべて自分の色に返します。",
		"how_to_play_pass_title": "3. パス",
		"how_to_play_pass_body": "置ける場所がない場合は自動でパスし、相手の手番になります。",
		"how_to_play_finish_title": "4. 終了と勝敗",
		"how_to_play_finish_body": "盤面が埋まるか両者とも置けなくなると終了し、石が多い方の勝ちです。",
		"how_to_play_previous": "戻る",
		"how_to_play_next": "次へ",
		"how_to_play_done": "完了",
		"how_to_play_skip": "スキップ",
		"how_to_play_progress": "%d / %d",
		"move_list_entry": "棋譜 %02d · %s",
		"move_list_title": "棋譜",
		"move_list_empty": "まだ着手記録がありません。",
		"about_title": "情報",
		"about_app_version": "%s · バージョン %s",
		"support_email": "サポート · %s",
		"privacy_policy": "プライバシーポリシー",
		"font_scale_setting": "文字サイズ",
		"reduce_motion": "動きを減らす",
		"high_contrast": "ハイコントラスト",
		"show_moves": "着手表示",
		"show_flip_counts": "反転数",
		"board_theme": "盤面 %s",
		"stone_theme": "石 %s",
		"locale": "言語 %s",
		"theme_classic": "クラシック",
		"theme_arctic": "氷河",
		"theme_ember": "夕焼け",
		"theme_forest": "フォレスト",
		"theme_sakura": "桜",
		"status_game_over": "対局終了",
		"status_flip": "反転中",
		"status_ai_thinking": "AI思考中",
		"status_pass": "パス",
		"status_your_move": "あなたの番",
		"status_ai_turn": "AIの番",
		"status_black_turn": "黒の番",
		"status_white_turn": "白の番",
		"turn_final": "終了",
		"turn_player": "手番",
		"turn_ai": "AI",
		"turn_black": "黒",
		"turn_white": "白",
		"focus_even": "互角",
		"focus_player_leads": "優勢 +%d",
		"focus_ai_leads": "劣勢 -%d",
		"focus_black_leads": "黒優勢 +%d",
		"focus_white_leads": "白優勢 +%d",
		"focus_valid": "着手 %d",
		"result_win": "勝利",
		"result_draw": "引き分け",
		"result_lose": "敗北",
		"result_black_wins": "黒の勝ち",
		"result_white_wins": "白の勝ち",
		"result_detail": "黒 %d / 白 %d",
		"result_highlights_title": "この対局のハイライト",
		"result_highlight_flip": "最大返し · %s %s · %d個",
		"result_highlight_corners": "コーナー · 黒 %d / 白 %d",
		"result_highlight_lead": "最大リード · %s +%d",
		"result_share_text": "%s\n%s\n%s",
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
var _active_ai_search_thread: Thread
var _ai_worker_started_count := 0
var _ai_worker_completed_count := 0
var _ai_sync_fallback_count := 0
var _ai_worker_ran_off_main_thread := false
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
var _hinted_move: Dictionary = {}
var _share_result_probe: Callable
var replay_active := false
var replay_playing := false
var replay_step := 0
var replay_history: Array = []
var replay_original_state: Dictionary = {}
var _replay_generation := 0
var _replay_transitioning := false

var cell_buttons: Array = []
var cell_piece_views: Array = []
var cell_ghost_views: Array = []
var cell_hint_views: Array = []
var cell_flip_count_labels: Array = []
var cell_recommendation_views: Array = []
var cell_tutorial_views: Array = []
var cell_surface_depth_views: Array = []
var board_guide_points: Array = []
var board_column_labels: Array = []
var board_row_labels: Array = []
var player_score_label: Label
var ai_score_label: Label
var player_info_label: Label
var ai_info_label: Label
var player_stone_view: TextureRect
var ai_stone_view: TextureRect
var turn_badge: Label
var status_label: Label
var move_count_label: Button
var settings_button: Button
var settings_overlay: ColorRect
var settings_panel: PanelContainer
var puzzle_entry_button: Button
var puzzle_overlay: ColorRect
var puzzle_panel: PanelContainer
var puzzle_close_button: Button
var puzzle_cards: Array = []
var how_to_play_entry_button: Button
var how_to_play_overlay: ColorRect
var how_to_play_panel: PanelContainer
var how_to_play_scroll: ScrollContainer
var how_to_play_content: VBoxContainer
var how_to_play_close_button: Button
var how_to_play_step_cards: Array = []
var how_to_play_progress_label: Label
var how_to_play_previous_button: Button
var how_to_play_next_button: Button
var how_to_play_skip_button: Button
var how_to_play_step_index := 0
var how_to_play_is_first_run := false
var move_list_overlay: ColorRect
var move_list_panel: PanelContainer
var move_list_scroll: ScrollContainer
var move_list_content: VBoxContainer
var move_list_close_button: Button
var move_list_empty_label: Label
var move_list_rows: Array = []
var sound_toggle: CheckButton
var music_toggle: CheckButton
var haptic_toggle: CheckButton
var gameplay_strip: PanelContainer
var adaptive_play_focus_slot: MarginContainer
var black_button: Button
var white_button: Button
var undo_button: Button
var hint_button: Button
var new_game_button: Button
var difficulty_buttons: Array = []
var difficulty_subtitle_label: Label
var opponent_mode_buttons: Array = []
var variant_buttons: Array = []
var board_size_buttons: Array = []
var board_theme_buttons: Array = []
var stone_theme_buttons: Array = []
var locale_buttons: Array = []
var font_scale_buttons: Array = []
var reduce_motion_toggle: CheckButton
var high_contrast_toggle: CheckButton
var show_moves_toggle: CheckButton
var show_flip_counts_toggle: CheckButton
var result_overlay: ColorRect
var result_panel: PanelContainer
var result_winner_stone_view: TextureRect
var result_title_label: Label
var result_score_label: Label
var result_detail_label: Label
var result_highlights_panel: PanelContainer
var result_highlights_title_label: Label
var result_highlights_label: Label
var result_stats_label: Label
var result_move_list_button: Button
var result_replay_button: Button
var result_share_button: Button
var result_restart_button: Button
var replay_controls: PanelContainer
var replay_step_label: Label
var replay_previous_button: Button
var replay_play_button: Button
var replay_next_button: Button
var replay_close_button: Button
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
var black_meter_label: Label
var white_meter_label: Label
var _shell_open_override := Callable()
var _active_puzzle_id := ""
var _puzzle_completed := false
var _puzzle_success := false
var bgm_player: Object


func _ready() -> void:
	configure_screen_keep_on(DisplayServer.get_name())
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
	_setup_bgm_player()
	_build_ui()
	var viewport_resize := Callable(self, "_update_adaptive_vertical_spacing")
	if !get_viewport().size_changed.is_connected(viewport_resize):
		get_viewport().size_changed.connect(viewport_resize)
	_render()
	call_deferred("_show_first_game_how_to_play")
	call_deferred("_maybe_play_ai_turn")


static func configure_screen_keep_on(
	display_name: String,
	set_keep_on: Callable = Callable(),
) -> bool:
	if display_name == "headless":
		return false
	if set_keep_on.is_valid():
		set_keep_on.call(true)
	else:
		DisplayServer.screen_set_keep_on(true)
	return true


func _exit_tree() -> void:
	if _active_ai_search_thread != null and _active_ai_search_thread.is_started():
		_active_ai_search_thread.wait_to_finish()
	_active_ai_search_thread = null


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
	_hinted_move.clear()
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
	_build_replay_controls(root)
	_build_play_focus_strip(root)
	_build_result_overlay()
	_build_settings_overlay()
	_build_puzzle_overlay()
	_build_how_to_play_overlay()
	_build_move_list_overlay()
	_build_new_game_confirmation_overlay()
	_update_adaptive_vertical_spacing()


static func expanded_canvas_size(window_size: Vector2i) -> Vector2:
	if window_size.x <= 0 or window_size.y <= 0:
		return DESIGN_VIEWPORT_SIZE
	var scale := minf(
		float(window_size.x) / DESIGN_VIEWPORT_SIZE.x,
		float(window_size.y) / DESIGN_VIEWPORT_SIZE.y,
	)
	if scale <= 0.0:
		return DESIGN_VIEWPORT_SIZE
	return Vector2(window_size) / scale


static func adaptive_vertical_surplus(window_size: Vector2i) -> int:
	var canvas_size := expanded_canvas_size(window_size)
	return maxi(0, roundi(canvas_size.y - DESIGN_VIEWPORT_SIZE.y))


func _update_adaptive_vertical_spacing(window_size: Vector2i = Vector2i.ZERO) -> void:
	if adaptive_play_focus_slot == null:
		return
	var measured_size := window_size
	if measured_size == Vector2i.ZERO:
		measured_size = DisplayServer.window_get_size()
	adaptive_play_focus_slot.add_theme_constant_override(
		"margin_top",
		adaptive_vertical_surplus(measured_size),
	)


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

	move_count_label = Button.new()
	move_count_label.name = "MoveListEntryButton"
	move_count_label.custom_minimum_size = Vector2(196, 42)
	move_count_label.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	move_count_label.focus_mode = Control.FOCUS_NONE
	move_count_label.flat = true
	move_count_label.add_theme_font_size_override("font_size", _font_size(16))
	move_count_label.add_theme_color_override("font_color", _theme_color("text_muted"))
	move_count_label.add_theme_color_override("font_hover_color", _theme_color("text_primary"))
	_apply_text_visibility(move_count_label, 1, _theme_color("text_muted"))
	move_count_label.pressed.connect(_show_move_list)
	status.add_child(move_count_label)


func _build_board(root: VBoxContainer) -> void:
	var board_size := _current_board_size()
	var cell_size := cell_size_for_board(board_size)
	var piece_margin := maxi(5, int(round(float(cell_size) / 12.0)))
	var hint_margin := maxi(16, int(round(float(cell_size) / 3.0)))
	var board_frame := PanelContainer.new()
	board_frame.name = "BoardFrame"
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

	var board_layout := GridContainer.new()
	board_layout.name = "BoardCoordinateLayout"
	board_layout.columns = 2
	board_layout.add_theme_constant_override("h_separation", BOARD_COORDINATE_GAP)
	board_layout.add_theme_constant_override("v_separation", BOARD_COORDINATE_GAP)
	board_margin.add_child(board_layout)

	var coordinate_corner := Control.new()
	coordinate_corner.name = "BoardCoordinateCorner"
	coordinate_corner.custom_minimum_size = Vector2(
		BOARD_COORDINATE_GUTTER,
		BOARD_COORDINATE_GUTTER,
	)
	coordinate_corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_layout.add_child(coordinate_corner)

	var column_coordinates := GridContainer.new()
	column_coordinates.name = "BoardColumnCoordinates"
	column_coordinates.columns = board_size
	column_coordinates.add_theme_constant_override("h_separation", CELL_GAP)
	board_layout.add_child(column_coordinates)

	board_column_labels.clear()
	for y in range(board_size):
		var column_label := _make_board_coordinate_label(
			"ABCDEFGHIJKLMNOPQRSTUVWXYZ".substr(y, 1),
			Vector2(cell_size, BOARD_COORDINATE_GUTTER),
		)
		column_label.name = "BoardColumn%s" % column_label.text
		column_coordinates.add_child(column_label)
		board_column_labels.append(column_label)

	var row_coordinates := GridContainer.new()
	row_coordinates.name = "BoardRowCoordinates"
	row_coordinates.columns = 1
	row_coordinates.add_theme_constant_override("v_separation", CELL_GAP)
	board_layout.add_child(row_coordinates)

	board_row_labels.clear()
	for x in range(board_size):
		var row_label := _make_board_coordinate_label(
			str(x + 1),
			Vector2(BOARD_COORDINATE_GUTTER, cell_size),
		)
		row_label.name = "BoardRow%s" % row_label.text
		row_coordinates.add_child(row_label)
		board_row_labels.append(row_label)

	var board_surface := PanelContainer.new()
	board_surface.name = "BoardSurface"
	board_surface.add_theme_stylebox_override(
		"panel",
		_make_style(_theme_color("board_grid"), 0, Color.TRANSPARENT, 2),
	)
	board_layout.add_child(board_surface)

	var board := GridContainer.new()
	board.name = "BoardGrid"
	board.columns = board_size
	board.add_theme_constant_override("h_separation", CELL_GAP)
	board.add_theme_constant_override("v_separation", CELL_GAP)
	board_surface.add_child(board)

	cell_buttons.clear()
	cell_piece_views.clear()
	cell_ghost_views.clear()
	cell_hint_views.clear()
	cell_flip_count_labels.clear()
	cell_recommendation_views.clear()
	cell_tutorial_views.clear()
	cell_surface_depth_views.clear()
	board_guide_points.clear()
	for x in range(board_size):
		var button_row: Array = []
		var piece_row: Array = []
		var ghost_row: Array = []
		var hint_row: Array = []
		var flip_count_row: Array = []
		var recommendation_row: Array = []
		var tutorial_row: Array = []
		var depth_row: Array = []
		for y in range(board_size):
			var cell_x := x
			var cell_y := y
			var button := Button.new()
			button.custom_minimum_size = Vector2(cell_size, cell_size)
			button.focus_mode = Control.FOCUS_NONE
			button.clip_contents = true
			button.text = ""
			button.pressed.connect(func() -> void: _on_cell_pressed(cell_x, cell_y))

			var surface_depth := PanelContainer.new()
			surface_depth.name = "CellSurfaceDepth%d_%d" % [x, y]
			surface_depth.mouse_filter = Control.MOUSE_FILTER_IGNORE
			surface_depth.set_anchors_preset(Control.PRESET_FULL_RECT)
			surface_depth.offset_left = 1
			surface_depth.offset_top = 1
			surface_depth.offset_right = -2
			surface_depth.offset_bottom = -2
			surface_depth.add_theme_stylebox_override("panel", _make_board_cell_depth_style())
			button.add_child(surface_depth)

			var ghost := TextureRect.new()
			ghost.name = "LegalMoveGhost%d_%d" % [x, y]
			ghost.visible = false
			ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
			ghost.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			ghost.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			ghost.set_anchors_preset(Control.PRESET_FULL_RECT)
			ghost.offset_left = piece_margin
			ghost.offset_top = piece_margin
			ghost.offset_right = -piece_margin
			ghost.offset_bottom = -piece_margin
			button.add_child(ghost)

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

			var flip_count_label := Label.new()
			flip_count_label.name = "FlipCount%d_%d" % [x, y]
			flip_count_label.visible = false
			flip_count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			flip_count_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			flip_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			flip_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			flip_count_label.add_theme_font_size_override("font_size", _font_size(16))
			hint.add_child(flip_count_label)

			var recommendation := PanelContainer.new()
			recommendation.name = "HintRecommendation%d_%d" % [x, y]
			recommendation.visible = false
			recommendation.mouse_filter = Control.MOUSE_FILTER_IGNORE
			recommendation.set_anchors_preset(Control.PRESET_FULL_RECT)
			recommendation.offset_left = 4
			recommendation.offset_top = 4
			recommendation.offset_right = -4
			recommendation.offset_bottom = -4
			recommendation.add_theme_stylebox_override(
				"panel",
				_make_style(Color(1.0, 0.82, 0.18, 0.12), 4, _theme_color("accent"), 8),
			)
			button.add_child(recommendation)

			var tutorial_highlight := PanelContainer.new()
			tutorial_highlight.name = "TutorialHighlight%d_%d" % [x, y]
			tutorial_highlight.visible = false
			tutorial_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tutorial_highlight.set_anchors_preset(Control.PRESET_FULL_RECT)
			tutorial_highlight.offset_left = 3
			tutorial_highlight.offset_top = 3
			tutorial_highlight.offset_right = -3
			tutorial_highlight.offset_bottom = -3
			tutorial_highlight.add_theme_stylebox_override(
				"panel",
				_make_style(Color.TRANSPARENT, 4, _theme_color("accent"), 8),
			)
			button.add_child(tutorial_highlight)

			board.add_child(button)
			button_row.append(button)
			piece_row.append(piece)
			ghost_row.append(ghost)
			hint_row.append(hint)
			flip_count_row.append(flip_count_label)
			recommendation_row.append(recommendation)
			tutorial_row.append(tutorial_highlight)
			depth_row.append(surface_depth)
		cell_buttons.append(button_row)
		cell_piece_views.append(piece_row)
		cell_ghost_views.append(ghost_row)
		cell_hint_views.append(hint_row)
		cell_flip_count_labels.append(flip_count_row)
		cell_recommendation_views.append(recommendation_row)
		cell_tutorial_views.append(tutorial_row)
		cell_surface_depth_views.append(depth_row)

	var guide_layer := Control.new()
	guide_layer.name = "BoardGuideLayer"
	guide_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guide_layer.z_index = 2
	guide_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	board_surface.add_child(guide_layer)
	var board_span := float(board_size * cell_size + (board_size - 1) * CELL_GAP)
	for guide_x in board_guide_intersections(board_size):
		for guide_y in board_guide_intersections(board_size):
			var guide_point := PanelContainer.new()
			guide_point.name = "BoardGuidePoint%d_%d" % [guide_x, guide_y]
			guide_point.mouse_filter = Control.MOUSE_FILTER_IGNORE
			guide_point.custom_minimum_size = Vector2(BOARD_GUIDE_POINT_SIZE, BOARD_GUIDE_POINT_SIZE)
			guide_point.size = Vector2(BOARD_GUIDE_POINT_SIZE, BOARD_GUIDE_POINT_SIZE)
			guide_point.position = Vector2(
				float(guide_y * (cell_size + CELL_GAP)) - float(CELL_GAP) * 0.5,
				float(guide_x * (cell_size + CELL_GAP)) - float(CELL_GAP) * 0.5,
			) - Vector2.ONE * float(BOARD_GUIDE_POINT_SIZE) * 0.5
			guide_point.position.x = clampf(guide_point.position.x, 0.0, board_span - BOARD_GUIDE_POINT_SIZE)
			guide_point.position.y = clampf(guide_point.position.y, 0.0, board_span - BOARD_GUIDE_POINT_SIZE)
			guide_point.add_theme_stylebox_override(
				"panel",
				_make_style(_theme_color("board_guide"), 1, _theme_color("board_highlight"), 4),
			)
			guide_layer.add_child(guide_point)
			board_guide_points.append(guide_point)


static func board_guide_intersections(board_size: int) -> PackedInt32Array:
	var near_intersection := maxi(1, board_size / 4)
	return PackedInt32Array([near_intersection, board_size - near_intersection])


func _make_board_cell_depth_style() -> StyleBoxFlat:
	var style := _make_style(Color.TRANSPARENT, 1, _theme_color("board_highlight"), 1)
	style.shadow_color = _theme_color("board_shadow")
	style.shadow_size = 2
	style.shadow_offset = Vector2(1, 1)
	return style


func _make_board_coordinate_label(text: String, minimum_size: Vector2) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = minimum_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", UI_FONT)
	label.add_theme_font_size_override("font_size", _font_size(14))
	label.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(label, 1, _theme_color("text_muted"))
	return label


func _build_replay_controls(root: VBoxContainer) -> void:
	replay_controls = PanelContainer.new()
	replay_controls.name = "ReplayControls"
	replay_controls.visible = replay_active
	replay_controls.custom_minimum_size = Vector2(0, 64)
	replay_controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	replay_controls.add_theme_stylebox_override(
		"panel",
		_make_style(_theme_color("hud_dark"), 1, _theme_color("accent"), 8),
	)
	root.add_child(replay_controls)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	replay_controls.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	margin.add_child(row)

	replay_previous_button = _make_action_button(
		_t("replay_previous"),
		func() -> void: _set_replay_step(replay_step - 1),
	)
	replay_previous_button.name = "ReplayPreviousButton"
	row.add_child(replay_previous_button)

	replay_play_button = _make_action_button(
		_t("replay_play"),
		func() -> void: _toggle_replay_playback(),
		true,
	)
	replay_play_button.name = "ReplayPlayButton"
	row.add_child(replay_play_button)

	replay_next_button = _make_action_button(
		_t("replay_next"),
		func() -> void: _advance_replay_step(true),
	)
	replay_next_button.name = "ReplayNextButton"
	row.add_child(replay_next_button)

	replay_step_label = Label.new()
	replay_step_label.name = "ReplayStepLabel"
	replay_step_label.custom_minimum_size = Vector2(106, ACTION_BUTTON_HEIGHT)
	replay_step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	replay_step_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	replay_step_label.add_theme_font_size_override("font_size", _font_size(16))
	replay_step_label.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(replay_step_label, 1, _theme_color("text_primary"))
	row.add_child(replay_step_label)

	replay_close_button = _make_action_button(
		_t("replay_close"),
		func() -> void: _close_replay(),
	)
	replay_close_button.name = "ReplayCloseButton"
	row.add_child(replay_close_button)


func _build_play_focus_strip(root: VBoxContainer) -> void:
	adaptive_play_focus_slot = MarginContainer.new()
	adaptive_play_focus_slot.name = "AdaptivePlayFocusSlot"
	adaptive_play_focus_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	adaptive_play_focus_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(adaptive_play_focus_slot)

	gameplay_strip = PanelContainer.new()
	gameplay_strip.custom_minimum_size = Vector2(0, 48)
	gameplay_strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gameplay_strip.add_theme_stylebox_override("panel", _make_style(_theme_color("hud_dark"), 1, Color(1, 1, 1, 0.08), 8))
	adaptive_play_focus_slot.add_child(gameplay_strip)

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
	black_meter_label = _make_meter_label(Color.WHITE)
	black_meter.add_child(black_meter_label)

	white_meter = ColorRect.new()
	white_meter.custom_minimum_size = Vector2(12, 0)
	white_meter.color = _stone_theme_color("white_meter")
	white_meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meter.add_child(white_meter)
	white_meter_label = _make_meter_label(Color(0.03, 0.035, 0.045, 1.0))
	white_meter.add_child(white_meter_label)
	var controls_strip := PanelContainer.new()
	controls_strip.name = "PlayControlsStrip"
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

	hint_button = _make_action_button(_t("hint"), func() -> void: _on_hint_pressed())
	hint_button.name = "HintButton"
	hint_button.custom_minimum_size = Vector2(112, PLAY_BUTTON_HEIGHT)
	controls_row.add_child(hint_button)

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


func _make_meter_label(font_color: Color) -> Label:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", _font_size(12))
	label.add_theme_color_override("font_color", font_color)
	_apply_text_visibility(label, 1, font_color)
	return label


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

	result_highlights_panel = PanelContainer.new()
	result_highlights_panel.name = "ResultHighlightsCard"
	result_highlights_panel.visible = false
	result_highlights_panel.custom_minimum_size = Vector2(340, 0)
	result_highlights_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	result_highlights_panel.add_theme_stylebox_override(
		"panel",
		_make_style(_theme_color("hud"), 1, Color(1, 1, 1, 0.13), 8),
	)
	box.add_child(result_highlights_panel)

	var highlights_margin := MarginContainer.new()
	highlights_margin.add_theme_constant_override("margin_left", 14)
	highlights_margin.add_theme_constant_override("margin_top", 10)
	highlights_margin.add_theme_constant_override("margin_right", 14)
	highlights_margin.add_theme_constant_override("margin_bottom", 10)
	result_highlights_panel.add_child(highlights_margin)

	var highlights_box := VBoxContainer.new()
	highlights_box.add_theme_constant_override("separation", 5)
	highlights_margin.add_child(highlights_box)

	result_highlights_title_label = Label.new()
	result_highlights_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_highlights_title_label.add_theme_font_size_override("font_size", _font_size(18))
	result_highlights_title_label.add_theme_color_override("font_color", _theme_color("accent"))
	_apply_text_visibility(result_highlights_title_label, 1, _theme_color("accent"))
	highlights_box.add_child(result_highlights_title_label)

	result_highlights_label = Label.new()
	result_highlights_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_highlights_label.add_theme_font_size_override("font_size", _font_size(15))
	result_highlights_label.add_theme_color_override("font_color", _theme_color("text_primary"))
	result_highlights_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_apply_text_visibility(result_highlights_label, 1, _theme_color("text_primary"))
	highlights_box.add_child(result_highlights_label)

	result_stats_label = Label.new()
	result_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_stats_label.add_theme_font_size_override("font_size", _font_size(18))
	result_stats_label.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(result_stats_label, 1, _theme_color("text_primary"))
	box.add_child(result_stats_label)

	result_replay_button = _make_action_button(
		_t("replay"),
		func() -> void: _enter_replay(),
		true,
	)
	result_replay_button.name = "ResultReplayButton"
	result_replay_button.custom_minimum_size = Vector2(300, ACTION_BUTTON_HEIGHT)
	result_replay_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(result_replay_button)

	result_move_list_button = _make_action_button(
		_t("move_list_title"),
		func() -> void: _show_move_list(),
	)
	result_move_list_button.name = "ResultMoveListButton"
	result_move_list_button.custom_minimum_size = Vector2(300, ACTION_BUTTON_HEIGHT)
	result_move_list_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(result_move_list_button)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 8)
	box.add_child(buttons)

	result_restart_button = _make_action_button(
		_t("restart"),
		func() -> void: _start_new_game(player_stone),
		true,
	)
	result_restart_button.name = "ResultRestartButton"
	buttons.add_child(result_restart_button)
	result_share_button = _make_action_button(_t("share_result"), func() -> void: _share_result())
	result_share_button.name = "ResultShareButton"
	buttons.add_child(result_share_button)
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
	settings_panel.custom_minimum_size = Vector2(420, 1160)
	settings_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_panel.add_theme_stylebox_override("panel", _make_style(_theme_color("hud_dark"), 2, Color(1, 1, 1, 0.14), 10))
	row.add_child(settings_panel)

	var scroll := ScrollContainer.new()
	scroll.name = "SettingsScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	settings_panel.add_child(scroll)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	scroll.add_child(margin)

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
		_t("opponent_mode_setting"),
		OPPONENT_MODE_IDS,
		[_t("opponent_ai"), _t("opponent_local")],
		_current_opponent_mode(),
		Callable(self, "_set_opponent_mode_from_choice"),
		opponent_mode_buttons
	))

	var variant_section := _make_choice_section(
		_t("variant_setting"),
		VARIANT_IDS,
		[_t("variant_standard"), _t("variant_anti")],
		_current_variant(),
		Callable(self, "_set_variant_from_choice"),
		variant_buttons
	)
	variant_section.name = "VariantSection"
	box.add_child(variant_section)

	var difficulty_section := _make_choice_section(
		_t("difficulty_setting"),
		DIFFICULTY_IDS,
		[_t("easy_short"), _t("medium_short"), _t("hard_short")],
		difficulty,
		Callable(self, "_set_difficulty_from_choice"),
		difficulty_buttons
	)
	difficulty_section.name = "DifficultySection"
	difficulty_subtitle_label = Label.new()
	difficulty_subtitle_label.name = "DifficultySubtitle"
	difficulty_subtitle_label.text = _difficulty_description(difficulty)
	difficulty_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	difficulty_subtitle_label.add_theme_font_size_override("font_size", _font_size(14))
	difficulty_subtitle_label.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(difficulty_subtitle_label, 1, _theme_color("text_muted"))
	difficulty_section.add_child(difficulty_subtitle_label)
	box.add_child(difficulty_section)

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
	music_toggle = _make_toggle_button(_t("music"), "music")
	box.add_child(music_toggle)
	haptic_toggle = _make_toggle_button(_t("haptic"), "haptic")
	box.add_child(haptic_toggle)
	show_moves_toggle = _make_toggle_button(_t("show_moves"), "show_moves")
	box.add_child(show_moves_toggle)
	show_flip_counts_toggle = _make_toggle_button(_t("show_flip_counts"), "show_flip_counts")
	box.add_child(show_flip_counts_toggle)
	reduce_motion_toggle = _make_toggle_button(_t("reduce_motion"), "reduce_motion")
	box.add_child(reduce_motion_toggle)
	high_contrast_toggle = _make_toggle_button(_t("high_contrast"), "high_contrast")
	box.add_child(high_contrast_toggle)

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

	var puzzle_section := VBoxContainer.new()
	puzzle_section.name = "PuzzleSection"
	puzzle_section.add_theme_constant_override("separation", 5)
	var puzzle_title := Label.new()
	puzzle_title.name = "PuzzleSectionTitle"
	puzzle_title.text = _t("puzzle_section")
	puzzle_title.add_theme_font_size_override("font_size", _font_size(16))
	puzzle_title.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(puzzle_title, 1, _theme_color("text_muted"))
	puzzle_section.add_child(puzzle_title)
	puzzle_entry_button = _make_action_button(
		_t("puzzle_entry"),
		func() -> void: _show_puzzle_selector(),
	)
	puzzle_entry_button.name = "PuzzleEntryButton"
	puzzle_entry_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	puzzle_section.add_child(puzzle_entry_button)
	box.add_child(puzzle_section)
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
	how_to_play_entry_button = _make_action_button(
		_t("how_to_play_entry"),
		func() -> void: _show_how_to_play(),
	)
	how_to_play_entry_button.name = "HowToPlayEntryButton"
	how_to_play_entry_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(how_to_play_entry_button)
	box.add_child(_make_about_section(PRIVACY_POLICY_URL))


func _build_puzzle_overlay() -> void:
	puzzle_overlay = ColorRect.new()
	puzzle_overlay.name = "PuzzleOverlay"
	puzzle_overlay.visible = false
	puzzle_overlay.color = Color(0.005, 0.008, 0.014, 0.72)
	puzzle_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	puzzle_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	puzzle_overlay.gui_input.connect(_on_puzzle_overlay_gui_input)
	add_child(puzzle_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	puzzle_overlay.add_child(center)

	puzzle_panel = PanelContainer.new()
	puzzle_panel.name = "PuzzlePanel"
	puzzle_panel.custom_minimum_size = Vector2(560, 850)
	puzzle_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	puzzle_panel.add_theme_stylebox_override(
		"panel",
		_make_style(_theme_color("hud_dark"), 2, Color(1, 1, 1, 0.14), 12),
	)
	center.add_child(puzzle_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	puzzle_panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 10)
	layout.add_child(header)

	var title := Label.new()
	title.name = "PuzzleSelectTitle"
	title.text = _t("puzzle_select_title")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", _font_size(28))
	title.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(title, 2, _theme_color("text_primary"))
	header.add_child(title)

	puzzle_close_button = _make_action_button(
		_t("close"),
		func() -> void: _hide_puzzle_selector(),
	)
	puzzle_close_button.name = "PuzzleCloseButton"
	header.add_child(puzzle_close_button)

	var intro := Label.new()
	intro.name = "PuzzleSelectIntro"
	intro.text = _t("puzzle_select_intro")
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_font_size_override("font_size", _font_size(17))
	intro.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(intro, 1, _theme_color("text_muted"))
	layout.add_child(intro)

	var scroll := ScrollContainer.new()
	scroll.name = "PuzzleScroll"
	scroll.custom_minimum_size = Vector2(0, 690)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	layout.add_child(scroll)

	var list := VBoxContainer.new()
	list.name = "PuzzleList"
	list.custom_minimum_size = Vector2(500, 0)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)

	puzzle_cards.clear()
	for definition_value in PuzzleCatalog.all():
		var definition: Dictionary = definition_value
		var card := _make_puzzle_card(definition)
		list.add_child(card)


func _make_puzzle_card(definition: Dictionary) -> PanelContainer:
	var puzzle_id := str(definition.get("id", ""))
	var card := PanelContainer.new()
	card.name = "PuzzleCard%s" % puzzle_id.to_pascal_case()
	card.custom_minimum_size = Vector2(0, 205)
	card.add_theme_stylebox_override(
		"panel",
		_make_style(_theme_color("hud"), 1, Color(1, 1, 1, 0.10), 9),
	)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 13)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 13)
	card.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	margin.add_child(content)

	var title := Label.new()
	title.name = "PuzzleCardTitle"
	title.text = _t(str(definition.get("title_key", "")))
	title.add_theme_font_size_override("font_size", _font_size(22))
	title.add_theme_color_override("font_color", _theme_color("accent"))
	_apply_text_visibility(title, 1, _theme_color("accent"))
	content.add_child(title)

	var description := Label.new()
	description.name = "PuzzleCardDescription"
	description.text = _t(str(definition.get("description", "")))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", _font_size(16))
	description.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(description, 1, _theme_color("text_primary"))
	content.add_child(description)

	var goal := Label.new()
	goal.name = "PuzzleCardGoal"
	goal.text = _t(str(definition.get("goal_key", "")))
	goal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal.add_theme_font_size_override("font_size", _font_size(15))
	goal.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(goal, 1, _theme_color("text_muted"))
	content.add_child(goal)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 10)
	content.add_child(footer)

	var difficulty_label := Label.new()
	difficulty_label.name = "PuzzleDifficulty"
	difficulty_label.text = _t("puzzle_difficulty") % [
		_difficulty_label(str(definition.get("difficulty", "MEDIUM"))),
	]
	difficulty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	difficulty_label.add_theme_font_size_override("font_size", _font_size(15))
	difficulty_label.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(difficulty_label, 1, _theme_color("text_muted"))
	footer.add_child(difficulty_label)

	var start_button := _make_action_button(
		_t("puzzle_start"),
		Callable(self, "_start_puzzle").bind(puzzle_id),
		true,
	)
	start_button.name = "PuzzleStartButton"
	footer.add_child(start_button)

	puzzle_cards.append({
		"id": puzzle_id,
		"card": card,
		"start_button": start_button,
		"title_label": title,
		"description_label": description,
		"goal_label": goal,
	})
	return card


func _build_how_to_play_overlay() -> void:
	how_to_play_overlay = ColorRect.new()
	how_to_play_overlay.name = "HowToPlayOverlay"
	how_to_play_overlay.visible = false
	how_to_play_overlay.color = Color(0.005, 0.008, 0.014, 0.58)
	how_to_play_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	how_to_play_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	how_to_play_overlay.gui_input.connect(_on_how_to_play_overlay_gui_input)
	add_child(how_to_play_overlay)

	var sheet_stack := VBoxContainer.new()
	sheet_stack.set_anchors_preset(Control.PRESET_FULL_RECT)
	sheet_stack.offset_left = 18
	sheet_stack.offset_top = 28
	sheet_stack.offset_right = -18
	sheet_stack.offset_bottom = -28
	how_to_play_overlay.add_child(sheet_stack)

	var spacer := Control.new()
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sheet_stack.add_child(spacer)

	how_to_play_panel = PanelContainer.new()
	how_to_play_panel.name = "HowToPlayPanel"
	how_to_play_panel.custom_minimum_size = Vector2(560, 430)
	how_to_play_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	how_to_play_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	how_to_play_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	how_to_play_panel.add_theme_stylebox_override(
		"panel",
		_make_style(_theme_color("hud_dark"), 2, Color(1, 1, 1, 0.14), 12),
	)
	sheet_stack.add_child(how_to_play_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	how_to_play_panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 10)
	layout.add_child(header)

	var title := Label.new()
	title.name = "HowToPlayTitle"
	title.text = _t("how_to_play_title")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", _font_size(28))
	title.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(title, 2, _theme_color("text_primary"))
	header.add_child(title)

	how_to_play_close_button = _make_action_button(
		_t("close"),
		func() -> void: _hide_how_to_play(),
	)
	how_to_play_close_button.name = "HowToPlayCloseButton"
	header.add_child(how_to_play_close_button)

	how_to_play_scroll = ScrollContainer.new()
	how_to_play_scroll.name = "HowToPlayScroll"
	how_to_play_scroll.custom_minimum_size = Vector2(0, 220)
	how_to_play_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	how_to_play_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	how_to_play_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	how_to_play_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	layout.add_child(how_to_play_scroll)

	how_to_play_content = VBoxContainer.new()
	how_to_play_content.name = "HowToPlayContent"
	how_to_play_content.custom_minimum_size = Vector2(500, 760)
	how_to_play_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	how_to_play_content.add_theme_constant_override("separation", 12)
	how_to_play_scroll.add_child(how_to_play_content)

	how_to_play_step_cards.clear()
	var rule_keys := ["place", "flip", "pass", "finish"]
	for rule_key in rule_keys:
		var step_card := _make_how_to_play_step(str(rule_key))
		how_to_play_content.add_child(step_card)
		how_to_play_step_cards.append(step_card)

	var footer := HBoxContainer.new()
	footer.name = "HowToPlayFooter"
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 8)
	layout.add_child(footer)

	how_to_play_skip_button = _make_action_button(
		_t("how_to_play_skip"),
		func() -> void: _finish_how_to_play(),
	)
	how_to_play_skip_button.name = "HowToPlaySkipButton"
	how_to_play_skip_button.custom_minimum_size = Vector2(116, ACTION_BUTTON_HEIGHT)
	footer.add_child(how_to_play_skip_button)

	how_to_play_previous_button = _make_action_button(
		_t("how_to_play_previous"),
		func() -> void: _move_how_to_play_step(-1),
	)
	how_to_play_previous_button.name = "HowToPlayPreviousButton"
	how_to_play_previous_button.custom_minimum_size = Vector2(116, ACTION_BUTTON_HEIGHT)
	footer.add_child(how_to_play_previous_button)

	how_to_play_progress_label = Label.new()
	how_to_play_progress_label.name = "HowToPlayProgress"
	how_to_play_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	how_to_play_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	how_to_play_progress_label.add_theme_font_size_override("font_size", _font_size(18))
	how_to_play_progress_label.add_theme_color_override("font_color", _theme_color("text_muted"))
	_apply_text_visibility(how_to_play_progress_label, 1, _theme_color("text_muted"))
	footer.add_child(how_to_play_progress_label)

	how_to_play_next_button = _make_action_button(
		_t("how_to_play_next"),
		func() -> void: _move_how_to_play_step(1),
		true,
	)
	how_to_play_next_button.name = "HowToPlayNextButton"
	how_to_play_next_button.custom_minimum_size = Vector2(116, ACTION_BUTTON_HEIGHT)
	footer.add_child(how_to_play_next_button)


func _make_how_to_play_step(rule_key: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "HowToPlayStep%s" % rule_key.capitalize()
	card.custom_minimum_size = Vector2(0, 160)
	card.add_theme_stylebox_override(
		"panel",
		_make_style(_theme_color("hud"), 1, Color(1, 1, 1, 0.10), 8),
	)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(margin)

	var text_box := VBoxContainer.new()
	text_box.add_theme_constant_override("separation", 8)
	margin.add_child(text_box)

	var title := Label.new()
	title.text = _t("how_to_play_%s_title" % rule_key)
	title.add_theme_font_size_override("font_size", _font_size(22))
	title.add_theme_color_override("font_color", _theme_color("accent"))
	_apply_text_visibility(title, 1, _theme_color("accent"))
	text_box.add_child(title)

	var body := Label.new()
	body.text = _t("how_to_play_%s_body" % rule_key)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", _font_size(18))
	body.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(body, 1, _theme_color("text_primary"))
	text_box.add_child(body)
	return card


func _build_move_list_overlay() -> void:
	move_list_overlay = ColorRect.new()
	move_list_overlay.name = "MoveListOverlay"
	move_list_overlay.visible = false
	move_list_overlay.color = Color(0.005, 0.008, 0.014, 0.72)
	move_list_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	move_list_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(move_list_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	move_list_overlay.add_child(center)

	move_list_panel = PanelContainer.new()
	move_list_panel.name = "MoveListPanel"
	move_list_panel.custom_minimum_size = Vector2(520, 720)
	move_list_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	move_list_panel.add_theme_stylebox_override(
		"panel",
		_make_style(_theme_color("hud_dark"), 2, Color(1, 1, 1, 0.14), 12),
	)
	center.add_child(move_list_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	move_list_panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 10)
	layout.add_child(header)

	var title := Label.new()
	title.name = "MoveListTitle"
	title.text = _t("move_list_title")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", _font_size(28))
	title.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(title, 2, _theme_color("text_primary"))
	header.add_child(title)

	move_list_close_button = _make_action_button(
		_t("close"),
		func() -> void: _hide_move_list(),
	)
	move_list_close_button.name = "MoveListCloseButton"
	header.add_child(move_list_close_button)

	move_list_scroll = ScrollContainer.new()
	move_list_scroll.name = "MoveListScroll"
	move_list_scroll.custom_minimum_size = Vector2(0, 620)
	move_list_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	move_list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	move_list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	move_list_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	layout.add_child(move_list_scroll)

	move_list_content = VBoxContainer.new()
	move_list_content.name = "MoveListContent"
	move_list_content.custom_minimum_size = Vector2(460, 0)
	move_list_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	move_list_content.add_theme_constant_override("separation", 8)
	move_list_scroll.add_child(move_list_content)


func _show_move_list() -> void:
	if move_list_overlay == null:
		return
	_render_move_list()
	move_list_overlay.visible = true


func _hide_move_list() -> void:
	if move_list_overlay != null:
		move_list_overlay.visible = false


func _render_move_list() -> void:
	if move_list_content == null:
		return
	for child in move_list_content.get_children():
		child.free()
	move_list_rows.clear()
	move_list_empty_label = null

	var history: Array = state.get("move_history", [])
	move_list_content.custom_minimum_size = Vector2(460, maxf(0.0, history.size() * 56.0))
	if history.is_empty():
		move_list_empty_label = Label.new()
		move_list_empty_label.name = "MoveListEmpty"
		move_list_empty_label.text = _t("move_list_empty")
		move_list_empty_label.custom_minimum_size = Vector2(0, 120)
		move_list_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		move_list_empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		move_list_empty_label.add_theme_font_size_override("font_size", _font_size(18))
		move_list_empty_label.add_theme_color_override("font_color", _theme_color("text_muted"))
		_apply_text_visibility(move_list_empty_label, 1, _theme_color("text_muted"))
		move_list_content.add_child(move_list_empty_label)
		return

	for index in range(history.size()):
		var move: Dictionary = history[index]
		var stone := int(move.get("stone", ReversiEngine.NONE))
		var row := PanelContainer.new()
		row.name = "MoveListRow%d" % (index + 1)
		row.custom_minimum_size = Vector2(0, 48)
		row.add_theme_stylebox_override(
			"panel",
			_make_style(_theme_color("hud"), 1, Color(1, 1, 1, 0.10), 7),
		)

		var row_margin := MarginContainer.new()
		row_margin.add_theme_constant_override("margin_left", 12)
		row_margin.add_theme_constant_override("margin_top", 6)
		row_margin.add_theme_constant_override("margin_right", 12)
		row_margin.add_theme_constant_override("margin_bottom", 6)
		row.add_child(row_margin)

		var row_content := HBoxContainer.new()
		row_content.add_theme_constant_override("separation", 12)
		row_margin.add_child(row_content)

		var number_label := Label.new()
		number_label.text = "%02d" % (index + 1)
		number_label.custom_minimum_size = Vector2(44, 0)
		number_label.add_theme_font_size_override("font_size", _font_size(17))
		number_label.add_theme_color_override("font_color", _theme_color("text_muted"))
		_apply_text_visibility(number_label, 1, _theme_color("text_muted"))
		row_content.add_child(number_label)

		var stone_view := TextureRect.new()
		stone_view.name = "MoveListStoneIcon"
		stone_view.custom_minimum_size = Vector2(32, 32)
		stone_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		stone_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stone_view.texture = _texture_for_stone(stone)
		row_content.add_child(stone_view)

		var coordinate_label := Label.new()
		coordinate_label.name = "MoveListCoordinate"
		coordinate_label.text = move_coordinate(
			int(move.get("y", -1)),
			int(move.get("x", -1)),
		)
		coordinate_label.custom_minimum_size = Vector2(72, 0)
		coordinate_label.add_theme_font_size_override("font_size", _font_size(20))
		coordinate_label.add_theme_color_override("font_color", _theme_color("accent"))
		_apply_text_visibility(coordinate_label, 1, _theme_color("accent"))
		row_content.add_child(coordinate_label)

		var stone_label := Label.new()
		stone_label.name = "MoveListStone"
		stone_label.text = _piece_label(stone)
		stone_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stone_label.add_theme_font_size_override("font_size", _font_size(18))
		stone_label.add_theme_color_override("font_color", _theme_color("text_primary"))
		_apply_text_visibility(stone_label, 1, _theme_color("text_primary"))
		row_content.add_child(stone_label)

		move_list_content.add_child(row)
		move_list_rows.append(row)


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
	var default_settings := ReversiEngine.default_settings()
	var settings: Dictionary = state.get("settings", default_settings)
	toggle.button_pressed = bool(settings.get(key, default_settings.get(key, true)))
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
		if key == "music":
			_sync_music_playback()
		if key == "show_moves" or key == "show_flip_counts" or key == "high_contrast":
			_render()
	)
	return toggle


func _show_settings_menu() -> void:
	if settings_overlay != null:
		settings_overlay.visible = true


func _hide_settings_menu() -> void:
	if settings_overlay != null:
		settings_overlay.visible = false


func _show_puzzle_selector() -> void:
	_hide_settings_menu()
	if puzzle_overlay != null:
		puzzle_overlay.visible = true


func _hide_puzzle_selector() -> void:
	if puzzle_overlay != null:
		puzzle_overlay.visible = false


func _on_puzzle_overlay_gui_input(event: InputEvent) -> void:
	if !_puzzle_overlay_tap_should_close(event):
		return
	_hide_puzzle_selector()
	puzzle_overlay.accept_event()


func _puzzle_overlay_tap_should_close(event: InputEvent) -> bool:
	if puzzle_overlay == null or !puzzle_overlay.visible:
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
	return puzzle_panel == null or !puzzle_panel.get_global_rect().has_point(position)


func _start_puzzle(puzzle_id: String) -> bool:
	var definition := PuzzleCatalog.get_by_id(puzzle_id)
	var puzzle_state := PuzzleCatalog.create_state(definition)
	if puzzle_state.is_empty():
		return false
	_clear_hint_highlight()
	_hide_move_list()
	_hide_settings_menu()
	_hide_puzzle_selector()
	ai_move_pending = false
	input_locked = false
	_interstitial_shown_this_game = false
	_result_animation_played_this_game = false
	var current_settings := _current_settings().duplicate(true)
	var current_stats := ReversiEngine.normalize_stats(state.get("stats", {}))
	var board_size := ReversiEngine.get_board_size(puzzle_state.get("board", []))
	current_settings["board_size"] = board_size
	current_settings["opponent_mode"] = "ai"
	current_settings["variant"] = ReversiEngine.VARIANT_STANDARD
	puzzle_state["settings"] = current_settings
	puzzle_state["stats"] = current_stats
	_active_puzzle_id = puzzle_id
	_puzzle_completed = false
	_puzzle_success = false
	player_stone = int(definition.get("player_stone", ReversiEngine.BLACK))
	state = puzzle_state
	if cell_buttons.size() != board_size:
		_build_ui()
	_sync_identity_labels()
	_render()
	call_deferred("_maybe_play_ai_turn")
	return true


func _active_puzzle_definition() -> Dictionary:
	return PuzzleCatalog.get_by_id(_active_puzzle_id)


func _is_puzzle_active() -> bool:
	return !_active_puzzle_id.is_empty()


func _clear_active_puzzle() -> void:
	_active_puzzle_id = ""
	_puzzle_completed = false
	_puzzle_success = false


func _evaluate_active_puzzle_goal() -> Dictionary:
	if !_is_puzzle_active():
		return {"complete": false, "success": false}
	var result := PuzzleCatalog.evaluate_goal(_active_puzzle_definition(), state)
	if !bool(result.get("complete", false)) or _puzzle_completed:
		return result
	_puzzle_completed = true
	_puzzle_success = bool(result.get("success", false))
	state["game_over"] = true
	state["current_turn"] = ReversiEngine.NONE
	state["valid_moves"] = []
	state["winner"] = (
		player_stone if _puzzle_success else ReversiEngine.opponent(player_stone)
	)
	return result


func _show_first_game_how_to_play() -> void:
	if !bool(preferences.get("how_to_play_seen", false)):
		_show_how_to_play(true)


func _show_how_to_play(is_first_run: bool = false) -> void:
	_hide_settings_menu()
	if how_to_play_overlay == null:
		return
	how_to_play_is_first_run = is_first_run
	how_to_play_step_index = 0
	how_to_play_overlay.visible = true
	if how_to_play_skip_button != null:
		how_to_play_skip_button.visible = is_first_run
	_apply_how_to_play_step()


func _move_how_to_play_step(direction: int) -> void:
	if direction > 0 and how_to_play_step_index >= how_to_play_step_cards.size() - 1:
		_finish_how_to_play()
		return
	how_to_play_step_index = clampi(
		how_to_play_step_index + direction,
		0,
		maxi(0, how_to_play_step_cards.size() - 1),
	)
	_apply_how_to_play_step()


func _apply_how_to_play_step() -> void:
	if how_to_play_step_cards.is_empty():
		return
	how_to_play_step_index = clampi(
		how_to_play_step_index,
		0,
		how_to_play_step_cards.size() - 1,
	)
	for index in range(how_to_play_step_cards.size()):
		var card: PanelContainer = how_to_play_step_cards[index]
		card.modulate = Color.WHITE if index == how_to_play_step_index else Color(1, 1, 1, 0.42)
	if how_to_play_progress_label != null:
		how_to_play_progress_label.text = _t("how_to_play_progress") % [
			how_to_play_step_index + 1,
			how_to_play_step_cards.size(),
		]
	if how_to_play_previous_button != null:
		how_to_play_previous_button.disabled = how_to_play_step_index == 0
	if how_to_play_next_button != null:
		how_to_play_next_button.text = (
			_t("how_to_play_done")
			if how_to_play_step_index == how_to_play_step_cards.size() - 1
			else _t("how_to_play_next")
		)
	_clear_how_to_play_highlights()
	for cell in _how_to_play_highlight_cells(how_to_play_step_index):
		var x := int(cell.get("x", -1))
		var y := int(cell.get("y", -1))
		if x < 0 or x >= cell_tutorial_views.size():
			continue
		if y < 0 or y >= cell_tutorial_views[x].size():
			continue
		var highlight: PanelContainer = cell_tutorial_views[x][y]
		highlight.visible = true
		_pulse_cell(x, y, Color(1.0, 0.93, 0.58, 1.0))
	call_deferred("_scroll_how_to_play_step_into_view", how_to_play_step_index)


func _how_to_play_highlight_cells(step_index: int) -> Array:
	var board: Array = state.get("board", [])
	var board_size := ReversiEngine.get_board_size(board)
	if board_size <= 0:
		return []
	var cells: Array = []
	match step_index:
		0:
			for move in state.get("valid_moves", []):
				cells.append({"x": int(move.get("x", -1)), "y": int(move.get("y", -1))})
		1:
			var center_low := board_size / 2 - 1
			var center_high := board_size / 2
			cells = [
				{"x": center_low, "y": center_low},
				{"x": center_low, "y": center_high},
				{"x": center_high, "y": center_low},
				{"x": center_high, "y": center_high},
			]
		2:
			var edge_mid := board_size / 2
			cells = [
				{"x": 0, "y": edge_mid},
				{"x": board_size - 1, "y": edge_mid - 1},
				{"x": edge_mid, "y": 0},
				{"x": edge_mid - 1, "y": board_size - 1},
			]
		_:
			for x in range(board_size):
				for y in range(board_size):
					if int(board[x][y]) != ReversiEngine.NONE:
						cells.append({"x": x, "y": y})
	if cells.is_empty():
		cells.append({"x": board_size / 2 - 1, "y": board_size / 2 - 1})
	return cells


func _scroll_how_to_play_step_into_view(expected_index: int) -> void:
	if how_to_play_scroll == null or expected_index != how_to_play_step_index:
		return
	var card: PanelContainer = how_to_play_step_cards[expected_index]
	how_to_play_scroll.scroll_vertical = roundi(card.position.y)


func _clear_how_to_play_highlights() -> void:
	for row in cell_tutorial_views:
		for highlight in row:
			(highlight as PanelContainer).visible = false


func _finish_how_to_play() -> void:
	if !bool(preferences.get("how_to_play_seen", false)):
		preferences["how_to_play_seen"] = true
		_save_preferences()
	if how_to_play_overlay != null:
		how_to_play_overlay.visible = false
	how_to_play_is_first_run = false
	_clear_how_to_play_highlights()


func _hide_how_to_play() -> void:
	_finish_how_to_play()


func _on_how_to_play_overlay_gui_input(event: InputEvent) -> void:
	if !_how_to_play_overlay_tap_should_close(event):
		return
	_hide_how_to_play()
	how_to_play_overlay.accept_event()


func _how_to_play_overlay_tap_should_close(event: InputEvent) -> bool:
	if how_to_play_overlay == null or !how_to_play_overlay.visible:
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
	return how_to_play_panel == null \
		or !how_to_play_panel.get_global_rect().has_point(position)


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


static func replay_state_at_step(source_state: Dictionary, target_step: int) -> Dictionary:
	var history_value = source_state.get("move_history", [])
	if typeof(history_value) != TYPE_ARRAY:
		return {}
	var history: Array = history_value
	if target_step < 0 or target_step > history.size():
		return {}
	var source_board_value = source_state.get("board", [])
	if typeof(source_board_value) != TYPE_ARRAY:
		return {}
	var board_size := ReversiEngine.get_board_size(source_board_value)
	if board_size == 0:
		return {}
	var replay_state := ReversiEngine.create_new_game(
		int(source_state.get("player_stone", ReversiEngine.BLACK)),
		str(source_state.get("difficulty", "MEDIUM")),
		board_size,
		int(source_state.get("game_seed", -1)),
	)
	var source_settings_value = source_state.get("settings", {})
	if typeof(source_settings_value) == TYPE_DICTIONARY:
		replay_state["settings"] = (source_settings_value as Dictionary).duplicate(true)
	var source_stats_value = source_state.get("stats", {})
	if typeof(source_stats_value) == TYPE_DICTIONARY:
		replay_state["stats"] = (source_stats_value as Dictionary).duplicate(true)
	for index in range(target_step):
		var record_value = history[index]
		if typeof(record_value) != TYPE_DICTIONARY:
			return {}
		var record: Dictionary = record_value
		if !record.has("x") or !record.has("y") or !record.has("stone"):
			return {}
		if int(record["stone"]) != int(replay_state.get("current_turn", ReversiEngine.NONE)):
			return {}
		var move_result := ReversiEngine.play_move(
			replay_state,
			int(record["x"]),
			int(record["y"]),
		)
		if !bool(move_result.get("ok", false)):
			return {}
	return replay_state


static func replay_history_valid(source_state: Dictionary) -> bool:
	var history_value = source_state.get("move_history", [])
	if !bool(source_state.get("game_over", false)) \
		or typeof(history_value) != TYPE_ARRAY \
		or (history_value as Array).is_empty():
		return false
	var replayed := replay_state_at_step(source_state, (history_value as Array).size())
	return !replayed.is_empty() \
		and replayed.get("board", []) == source_state.get("board", []) \
		and bool(replayed.get("game_over", false)) \
		and int(replayed.get("winner", ReversiEngine.NONE)) \
			== int(source_state.get("winner", ReversiEngine.NONE))


func _enter_replay() -> void:
	if replay_active or !replay_history_valid(state):
		return
	replay_original_state = state.duplicate(true)
	replay_history = state.get("move_history", []).duplicate(true)
	var initial_state := replay_state_at_step(replay_original_state, 0)
	if initial_state.is_empty():
		replay_original_state.clear()
		replay_history.clear()
		return
	replay_active = true
	replay_playing = false
	replay_step = 0
	_replay_generation += 1
	state = initial_state
	input_locked = true
	result_overlay.visible = false
	_render()


func _set_replay_step(target_step: int) -> void:
	if !replay_active or _replay_transitioning:
		return
	replay_playing = false
	_replay_generation += 1
	var clamped_step := clampi(target_step, 0, replay_history.size())
	var next_state := replay_state_at_step(replay_original_state, clamped_step)
	if next_state.is_empty():
		return
	state = next_state
	replay_step = clamped_step
	input_locked = true
	_render()


func _advance_replay_step(animate: bool = true) -> void:
	if !replay_active or _replay_transitioning or replay_step >= replay_history.size():
		return
	var record_value = replay_history[replay_step]
	if typeof(record_value) != TYPE_DICTIONARY:
		replay_playing = false
		_update_replay_controls()
		return
	var record: Dictionary = record_value
	var before_board := ReversiEngine.clone_board(state.get("board", []))
	var result := ReversiEngine.play_move(state, int(record.get("x", -1)), int(record.get("y", -1)))
	if !bool(result.get("ok", false)):
		replay_playing = false
		_update_replay_controls()
		return
	replay_step += 1
	_replay_transitioning = true
	input_locked = true
	_render()
	if animate:
		await get_tree().process_frame
		await _animate_move_result(before_board, result)
	_replay_transitioning = false
	input_locked = true
	_render()


func _toggle_replay_playback() -> void:
	if !replay_active:
		return
	if replay_playing:
		replay_playing = false
		_replay_generation += 1
		_update_replay_controls()
		return
	if _replay_transitioning:
		return
	if replay_step >= replay_history.size():
		_set_replay_step(0)
	replay_playing = true
	_replay_generation += 1
	var generation := _replay_generation
	_update_replay_controls()
	while (
		replay_active
		and replay_playing
		and generation == _replay_generation
		and replay_step < replay_history.size()
	):
		await _advance_replay_step(true)
		if replay_playing and replay_step < replay_history.size():
			await get_tree().create_timer(0.18).timeout
	if generation == _replay_generation:
		replay_playing = false
		_update_replay_controls()


func _close_replay() -> void:
	if !replay_active:
		return
	replay_playing = false
	_replay_generation += 1
	replay_active = false
	_replay_transitioning = false
	state = replay_original_state.duplicate(true)
	replay_original_state.clear()
	replay_history.clear()
	replay_step = 0
	input_locked = false
	_render()


func _update_replay_controls() -> void:
	if replay_controls == null:
		return
	replay_controls.visible = replay_active
	if gameplay_strip != null:
		gameplay_strip.visible = !replay_active
	if !replay_active:
		return
	replay_step_label.text = _t("replay_step") % [replay_step, replay_history.size()]
	replay_previous_button.disabled = _replay_transitioning or replay_step <= 0
	replay_next_button.disabled = _replay_transitioning or replay_step >= replay_history.size()
	replay_play_button.disabled = replay_history.is_empty() \
		or (_replay_transitioning and !replay_playing)
	replay_play_button.text = _t("replay_pause") if replay_playing else _t("replay_play")
	replay_close_button.disabled = _replay_transitioning


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
	_clear_hint_highlight()
	_hide_move_list()
	ai_move_pending = false
	input_locked = false
	_interstitial_shown_this_game = false
	_result_animation_played_this_game = false
	var current_settings := (
		ReversiEngine.normalize_settings(preferences.get("settings", {}))
		if _is_puzzle_active()
		else _current_settings()
	)
	var current_stats := ReversiEngine.normalize_stats(state.get("stats", {}))
	var board_size := ReversiEngine.normalize_board_size(
		int(current_settings.get("board_size", ReversiEngine.DEFAULT_BOARD_SIZE))
	)
	var rebuild_board := cell_buttons.size() != board_size
	_clear_active_puzzle()
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
	if analytics != null and !_is_local_game():
		analytics.on_game_start(difficulty, player_stone)
	call_deferred("_maybe_play_ai_turn")


static func cell_size_for_board(board_size: int) -> int:
	var normalized_size := ReversiEngine.normalize_board_size(board_size)
	var board_grid_target := (
		BOARD_TARGET_CONTENT_SIZE
		- BOARD_COORDINATE_GUTTER
		- BOARD_COORDINATE_GAP
	)
	return maxi(
		1,
		int(floor(
			float(board_grid_target - CELL_GAP * (normalized_size - 1))
			/ float(normalized_size)
		)),
	)


static func board_frame_size_for_board(board_size: int) -> int:
	var normalized_size := ReversiEngine.normalize_board_size(board_size)
	var cell_size := cell_size_for_board(normalized_size)
	return (
		cell_size * normalized_size
		+ CELL_GAP * (normalized_size - 1)
		+ BOARD_COORDINATE_GUTTER
		+ BOARD_COORDINATE_GAP
		+ BOARD_PADDING * 2
	)


func _sync_identity_labels() -> void:
	if player_info_label == null:
		return
	if _is_local_game():
		player_info_label.text = _t("black_player")
		ai_info_label.text = _t("white_player")
		player_stone_view.texture = _texture_for_stone(ReversiEngine.BLACK)
		ai_stone_view.texture = _texture_for_stone(ReversiEngine.WHITE)
		return
	player_info_label.text = "%s / %s" % [_t("you"), _piece_label(player_stone)]
	ai_info_label.text = "%s / %s" % [_t("ai"), _piece_label(ReversiEngine.opponent(player_stone))]
	player_stone_view.texture = _texture_for_stone(player_stone)
	ai_stone_view.texture = _texture_for_stone(ReversiEngine.opponent(player_stone))


func _on_undo_pressed(persist: bool = true) -> void:
	if !_can_undo():
		return
	_clear_hint_highlight()
	var result := ReversiEngine.undo_last_round(state)
	if !bool(result.get("ok", false)):
		return
	if persist:
		_save_state()
	_render()


func _can_undo() -> bool:
	if state.is_empty() or input_locked or ai_move_pending:
		return false
	if (
		!bool(state.get("game_over", false))
		and int(state.get("current_turn", ReversiEngine.NONE)) != player_stone
	):
		return false
	return ReversiEngine.can_undo_last_round(state)


func _can_show_hint() -> bool:
	return !state.is_empty() \
		and !input_locked \
		and !ai_move_pending \
		and !bool(state.get("game_over", false)) \
		and (
			_is_local_game()
			or int(state.get("current_turn", ReversiEngine.NONE)) == player_stone
		) \
		and !state.get("valid_moves", []).is_empty()


func _on_hint_pressed() -> void:
	_clear_hint_highlight()
	if !_can_show_hint():
		return
	var move := ReversiEngine.choose_ai_move(state)
	if move.is_empty() or !_is_valid_cell(
		state.get("valid_moves", []),
		int(move.get("x", -1)),
		int(move.get("y", -1)),
	):
		return
	_hinted_move = {
		"x": int(move["x"]),
		"y": int(move["y"]),
	}
	_render()
	_pulse_cell(int(move["x"]), int(move["y"]), _theme_color("accent"))


func _clear_hint_highlight() -> void:
	_hinted_move.clear()
	for row in cell_recommendation_views:
		for highlight in row:
			(highlight as PanelContainer).visible = false


func _on_cell_pressed(x: int, y: int) -> void:
	if input_locked:
		return
	if bool(state.get("game_over", false)):
		_update_result_overlay()
		return
	if !_is_local_game() and int(state.get("current_turn", ReversiEngine.NONE)) != player_stone:
		status_label.text = _t("status_ai_thinking")
		return
	_clear_hint_highlight()

	var before_board := ReversiEngine.clone_board(state["board"])
	var result := ReversiEngine.play_move(state, x, y)
	if !bool(result.get("ok", false)):
		_pulse_cell(x, y, _theme_color("danger"))
		return

	_evaluate_active_puzzle_goal()
	_save_state()
	await _render_with_animation(before_board, result)
	call_deferred("_maybe_play_ai_turn")


func _maybe_play_ai_turn() -> void:
	if input_locked or ai_move_pending:
		return
	if bool(state.get("game_over", false)):
		_update_result_overlay()
		return
	if _is_local_game():
		return
	var ai_stone: int = int(state.get("ai_stone", ReversiEngine.WHITE))
	if int(state.get("current_turn", ReversiEngine.NONE)) != ai_stone:
		return

	ai_move_pending = true
	input_locked = true
	status_label.text = _t("status_ai_thinking")
	var expected_game_seed: int = int(state.get("game_seed", -1))
	var expected_history_size: int = state.get("move_history", []).size()
	var target_delay: float = _sample_ai_think_delay()
	var think_started_msec: int = Time.get_ticks_msec()
	await get_tree().process_frame
	if !_ai_turn_is_current(ai_stone, expected_game_seed, expected_history_size):
		ai_move_pending = false
		input_locked = false
		_render()
		return

	var search_state: Dictionary = state.duplicate(true)
	var move: Dictionary = await _choose_ai_move_without_blocking(
		search_state,
		str(search_state.get("difficulty", difficulty)),
	)
	var remaining_delay: float = ai_think_remaining_delay(
		target_delay,
		Time.get_ticks_msec() - think_started_msec,
	)
	if remaining_delay > 0.0:
		await get_tree().create_timer(remaining_delay).timeout
	if !_ai_turn_is_current(ai_stone, expected_game_seed, expected_history_size):
		ai_move_pending = false
		input_locked = false
		_render()
		return
	if move.is_empty():
		ai_move_pending = false
		input_locked = false
		_render()
		return

	var before_board := ReversiEngine.clone_board(state["board"])
	var result := ReversiEngine.play_move(state, int(move["x"]), int(move["y"]))
	_evaluate_active_puzzle_goal()
	_save_state()
	ai_move_pending = false
	await _render_with_animation(before_board, result)
	# 플레이어가 착수할 곳이 없어 패스되면 엔진이 턴을 다시 AI 에게 넘긴다.
	# 이 경우 재호출하지 않으면 AI 차례에서 게임이 멈추므로 다시 트리거한다.
	call_deferred("_maybe_play_ai_turn")


static func ai_search_should_use_thread(
	difficulty_id: String,
	is_web: bool,
	threading_available: bool,
) -> bool:
	return difficulty_id == "HARD" and !is_web and threading_available


func _choose_ai_move_without_blocking(
	search_state: Dictionary,
	difficulty_id: String,
) -> Dictionary:
	if !ai_search_should_use_thread(difficulty_id, OS.has_feature("web"), true):
		_ai_sync_fallback_count += 1
		return ReversiEngine.choose_ai_move(search_state)

	var worker := Thread.new()
	var start_error := worker.start(
		Callable(self, "_choose_ai_move_from_snapshot").bind(search_state),
	)
	if start_error != OK:
		_ai_sync_fallback_count += 1
		return ReversiEngine.choose_ai_move(search_state)

	_active_ai_search_thread = worker
	_ai_worker_started_count += 1
	while worker.is_alive():
		await get_tree().process_frame
	var worker_result = worker.wait_to_finish()
	_active_ai_search_thread = null
	_ai_worker_completed_count += 1
	if typeof(worker_result) != TYPE_DICTIONARY:
		return {}
	_ai_worker_ran_off_main_thread = bool(worker_result.get("ran_off_main_thread", false))
	var move = worker_result.get("move", {})
	return move if typeof(move) == TYPE_DICTIONARY else {}


func _choose_ai_move_from_snapshot(search_state: Dictionary) -> Dictionary:
	return {
		"move": ReversiEngine.choose_ai_move(search_state),
		"ran_off_main_thread": !Thread.is_main_thread(),
	}


static func ai_think_delay(difficulty_id: String, jitter_unit: float) -> float:
	var base_delay := float(AI_THINK_DELAY_BASE.get(difficulty_id, AI_THINK_DELAY_BASE["MEDIUM"]))
	var centered_jitter := (clampf(jitter_unit, 0.0, 1.0) * 2.0 - 1.0) \
		* AI_THINK_DELAY_JITTER
	return base_delay + centered_jitter


static func ai_think_remaining_delay(target_delay: float, elapsed_msec: int) -> float:
	return maxf(0.0, target_delay - float(maxi(0, elapsed_msec)) / 1000.0)


func _sample_ai_think_delay() -> float:
	return ai_think_delay(str(state.get("difficulty", difficulty)), randf())


func _ai_turn_is_current(ai_stone: int, game_seed: int, history_size: int) -> bool:
	return !_is_local_game() \
		and !bool(state.get("game_over", false)) \
		and int(state.get("current_turn", ReversiEngine.NONE)) == ai_stone \
		and int(state.get("game_seed", -1)) == game_seed \
		and state.get("move_history", []).size() == history_size


func _render_with_animation(before_board: Array, result: Dictionary) -> void:
	input_locked = true
	_render()
	_prepare_placed_piece_transition(result)
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
		placed_view.modulate = Color(1, 1, 1, LEGAL_MOVE_GHOST_ALPHA)
		placed_view.scale = Vector2.ONE * LEGAL_MOVE_GHOST_SCALE
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


func _prepare_placed_piece_transition(result: Dictionary) -> void:
	if _reduce_motion_enabled() or !bool(result.get("ok", false)):
		return
	var placed_value = result.get("placed", {})
	if typeof(placed_value) != TYPE_DICTIONARY or (placed_value as Dictionary).is_empty():
		return
	var placed: Dictionary = placed_value
	var x := int(placed.get("x", -1))
	var y := int(placed.get("y", -1))
	if x < 0 or x >= cell_piece_views.size() or y < 0 or y >= cell_piece_views[x].size():
		return
	_prepare_piece_view(x, y)
	var view: TextureRect = cell_piece_views[x][y]
	view.texture = _texture_for_stone(int(placed.get("stone", ReversiEngine.NONE)))
	view.modulate = Color(1, 1, 1, LEGAL_MOVE_GHOST_ALPHA)
	view.scale = Vector2.ONE * LEGAL_MOVE_GHOST_SCALE


func _render() -> void:
	_sync_identity_labels()
	var counts := ReversiEngine.count_pieces(state.get("board", []))
	var black_score := int(counts["black"])
	var white_score := int(counts["white"])
	player_score_label.text = str(
		black_score if _is_local_game() or player_stone == ReversiEngine.BLACK else white_score
	)
	ai_score_label.text = str(
		white_score if _is_local_game() or player_stone == ReversiEngine.BLACK else black_score
	)
	var player_score := black_score if player_stone == ReversiEngine.BLACK else white_score
	var ai_score := white_score if player_stone == ReversiEngine.BLACK else black_score

	var current_turn := int(state.get("current_turn", ReversiEngine.NONE))
	turn_badge.text = _turn_text(current_turn)
	status_label.text = _status_text()
	move_count_label.text = _t("move_list_entry") % [
		state.get("move_history", []).size(),
		_last_move_text(),
	]
	footer_primary_label.text = (
		_local_advantage_text(black_score, white_score)
		if _is_local_game()
		else _advantage_text(player_score, ai_score)
	)
	footer_secondary_label.text = _t("focus_valid") % state.get("valid_moves", []).size()
	black_meter.size_flags_stretch_ratio = max(1.0, float(black_score))
	white_meter.size_flags_stretch_ratio = max(1.0, float(white_score))
	_update_meter_accessibility(black_score, white_score)
	_update_mode_buttons()
	_update_settings_choice_buttons()
	_update_turn_badge(current_turn)
	if undo_button != null:
		undo_button.disabled = !_can_undo()
	if hint_button != null:
		hint_button.disabled = !_can_show_hint()
	_update_replay_controls()

	var board: Array = state.get("board", [])
	var valid_moves: Array = state.get("valid_moves", [])
	var board_size := ReversiEngine.get_board_size(board)
	for x in range(board_size):
		for y in range(board_size):
			var piece := int(board[x][y])
			var is_valid := _is_valid_cell(valid_moves, x, y)
			var is_last := _is_last_move(x, y)
			_render_cell(x, y, piece, is_valid, is_last)

	if replay_active:
		result_overlay.visible = false
	elif bool(state.get("game_over", false)):
		_update_result_overlay()
	else:
		result_overlay.visible = false
	if move_list_overlay != null and move_list_overlay.visible:
		_render_move_list()


func _render_cell(x: int, y: int, piece: int, is_valid: bool, is_last: bool) -> void:
	var button: Button = cell_buttons[x][y]
	var piece_view: TextureRect = cell_piece_views[x][y]
	var ghost_view: TextureRect = cell_ghost_views[x][y]
	var hint_view: PanelContainer = cell_hint_views[x][y]
	var flip_count_label: Label = cell_flip_count_labels[x][y]
	var recommendation_view: PanelContainer = cell_recommendation_views[x][y]
	var base := _board_cell_color(x, y)
	var border_width := (5 if _high_contrast_enabled() else 3) if is_last else 0
	var border_color := _theme_color("accent") if is_last else Color.TRANSPARENT

	button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	button.disabled = false
	ghost_view.visible = false
	ghost_view.texture = null
	ghost_view.modulate = Color(1, 1, 1, LEGAL_MOVE_GHOST_ALPHA)
	ghost_view.scale = Vector2.ONE * LEGAL_MOVE_GHOST_SCALE
	ghost_view.pivot_offset = ghost_view.size * 0.5
	hint_view.visible = false
	hint_view.add_theme_stylebox_override("panel", _legal_move_hint_style())
	flip_count_label.visible = false
	flip_count_label.text = ""
	flip_count_label.add_theme_color_override("font_color", _theme_color("text_primary"))
	_apply_text_visibility(flip_count_label, 3, _theme_color("text_primary"))
	recommendation_view.visible = false
	var preview_stone := _legal_move_preview_stone()
	if piece == ReversiEngine.NONE and is_valid and preview_stone != ReversiEngine.NONE:
		piece_view.texture = null
		piece_view.modulate = Color.TRANSPARENT
		piece_view.scale = Vector2.ONE
		var show_flip_count := _show_flip_counts_enabled()
		if _show_moves_enabled() or show_flip_count:
			base = base.lightened(0.08)
			hint_view.visible = true
			button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if _show_moves_enabled():
			ghost_view.texture = _texture_for_stone(preview_stone)
			ghost_view.visible = true
		if show_flip_count:
			flip_count_label.text = str(ReversiEngine.count_flips(state["board"], preview_stone, x, y))
			flip_count_label.visible = true
	elif piece == ReversiEngine.BLACK or piece == ReversiEngine.WHITE:
		piece_view.texture = _texture_for_stone(piece)
		piece_view.modulate = Color.WHITE
		piece_view.scale = Vector2.ONE
	else:
		piece_view.texture = null
		piece_view.modulate = Color.TRANSPARENT
		piece_view.scale = Vector2.ONE
	recommendation_view.visible = piece == ReversiEngine.NONE \
		and is_valid \
		and _can_show_hint() \
		and _is_hinted_move(x, y)
	piece_view.rotation = 0.0

	button.add_theme_stylebox_override("normal", _make_style(base, border_width, border_color))
	button.add_theme_stylebox_override("hover", _make_style(base.lightened(0.07), max(border_width, 2), _theme_color("accent") if is_valid else border_color))
	button.add_theme_stylebox_override("pressed", _make_style(base.darkened(0.08), max(border_width, 2), Color(0, 0, 0, 0.32)))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _update_meter_accessibility(black_score: int, white_score: int) -> void:
	var enabled := _high_contrast_enabled()
	var black_color := _stone_theme_color("black_meter")
	var white_color := _stone_theme_color("white_meter")
	black_meter.color = black_color.darkened(0.55) if enabled else black_color
	white_meter.color = white_color.lightened(0.22) if enabled else white_color
	black_meter_label.visible = enabled
	white_meter_label.visible = enabled
	black_meter_label.text = "%s %d" % [_t("black"), black_score] if enabled else ""
	white_meter_label.text = "%s %d" % [_t("white"), white_score] if enabled else ""


func _board_cell_color(x: int, y: int) -> Color:
	var config: Dictionary = _theme_config()
	var surface: Color = config["board_surface"]
	if !_high_contrast_enabled():
		return surface
	return Color(config["board_dark"]) if (x + y) % 2 == 0 else Color(config["board_light"])


func _legal_move_hint_style() -> StyleBoxFlat:
	if _high_contrast_enabled():
		return _make_style(Color(1.0, 1.0, 1.0, 0.04), 3, _theme_color("hint_border"), 18)
	var fill := _theme_color("hint")
	fill.a = 0.08
	return _make_style(fill, 2, _theme_color("hint_border"), 14)


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
	player.bus = SFX_BUS
	add_child(player)
	player.play()
	player.finished.connect(func() -> void:
		if is_instance_valid(player):
			player.queue_free()
	)


static func looping_bgm_stream(source: AudioStream) -> AudioStream:
	var loop_stream := source.duplicate() as AudioStream
	if loop_stream is AudioStreamOggVorbis:
		(loop_stream as AudioStreamOggVorbis).loop = true
	return loop_stream


func _setup_bgm_player(display_name: String = DisplayServer.get_name()) -> bool:
	if bgm_player != null and is_instance_valid(bgm_player):
		return true
	if display_name == "headless":
		return false
	var player := AudioStreamPlayer.new()
	player.name = "BGMPlayer"
	player.add_to_group("persistent_services")
	player.stream = looping_bgm_stream(BGM_STREAM)
	player.volume_db = BGM_VOLUME_DB
	player.bus = MUSIC_BUS
	bgm_player = player
	add_child(player)
	_sync_music_playback()
	return true


func _sync_music_playback() -> bool:
	if bgm_player == null or !is_instance_valid(bgm_player):
		return false
	var enabled := bool(_current_settings().get("music", true))
	var is_playing := bool(bgm_player.get("playing"))
	if enabled and !is_playing:
		bgm_player.call("play")
	elif !enabled and is_playing:
		bgm_player.call("stop")
	return enabled


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
	black_button.visible = !_is_local_game()
	white_button.visible = !_is_local_game()
	black_button.button_pressed = player_stone == ReversiEngine.BLACK
	white_button.button_pressed = player_stone == ReversiEngine.WHITE
	_apply_segment_style(black_button, black_button.button_pressed)
	_apply_segment_style(white_button, white_button.button_pressed)


func _update_settings_choice_buttons() -> void:
	_update_choice_buttons(opponent_mode_buttons, _current_opponent_mode())
	_update_choice_buttons(variant_buttons, _current_variant())
	_update_choice_buttons(difficulty_buttons, difficulty)
	if difficulty_subtitle_label != null:
		difficulty_subtitle_label.text = _difficulty_description(difficulty)
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
	var border_width := 3 if _high_contrast_enabled() else 1
	var primary_turn := (
		current_turn == ReversiEngine.BLACK
		if _is_local_game()
		else current_turn == player_stone
	)
	if primary_turn:
		turn_badge.add_theme_stylebox_override("normal", _make_style(_theme_color("accent"), border_width, Color(1, 1, 1, 0.2), 8))
		turn_badge.add_theme_color_override("font_color", Color(0.06, 0.055, 0.035, 1.0))
		_apply_text_visibility(turn_badge, 1, Color(0.06, 0.055, 0.035, 1.0))
	elif current_turn == ReversiEngine.NONE:
		turn_badge.add_theme_stylebox_override("normal", _make_style(_theme_color("hud"), border_width, Color(1, 1, 1, 0.13), 8))
		turn_badge.add_theme_color_override("font_color", _theme_color("text_primary"))
		_apply_text_visibility(turn_badge, 1, _theme_color("text_primary"))
	else:
		turn_badge.add_theme_stylebox_override("normal", _make_style(_theme_color("success"), border_width, Color(1, 1, 1, 0.16), 8))
		turn_badge.add_theme_color_override("font_color", Color(0.02, 0.05, 0.03, 1.0))
		_apply_text_visibility(turn_badge, 1, Color(0.02, 0.05, 0.03, 1.0))


func _update_result_overlay(persist_stats: bool = true) -> void:
	var counts := ReversiEngine.count_pieces(state.get("board", []))
	var black_score := int(counts["black"])
	var white_score := int(counts["white"])
	if _is_puzzle_active():
		_update_puzzle_result_overlay(black_score, white_score)
		return
	if result_restart_button != null:
		result_restart_button.text = _t("restart")
	var winner := int(state.get("winner", ReversiEngine.NONE))
	var result_kind := ""
	if _is_local_game() and winner == ReversiEngine.BLACK:
		result_title_label.text = _t("result_black_wins")
		result_title_label.add_theme_color_override("font_color", _theme_color("accent"))
		_apply_text_visibility(result_title_label, 3, _theme_color("accent"))
	elif _is_local_game() and winner == ReversiEngine.WHITE:
		result_title_label.text = _t("result_white_wins")
		result_title_label.add_theme_color_override("font_color", _theme_color("success"))
		_apply_text_visibility(result_title_label, 3, _theme_color("success"))
	elif winner == player_stone:
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
		black_score if _is_local_game() or player_stone == ReversiEngine.BLACK else white_score,
		white_score if _is_local_game() or player_stone == ReversiEngine.BLACK else black_score,
	]
	result_detail_label.text = _t("result_detail") % [black_score, white_score]
	_update_result_highlights()
	if result_replay_button != null:
		result_replay_button.disabled = !replay_history_valid(state)
	_show_result_overlay(winner)
	# game_over 는 광고와 같은 1회 가드 안에서만 전송한다.
	# (오버레이는 게임 종료 후 입력·AI턴 진입마다 재호출되므로 밖에 두면 중복 집계된다.)
	if not _interstitial_shown_this_game:
		_interstitial_shown_this_game = true
		if !_is_local_game():
			ReversiEngine.record_game_result(state, result_kind)
		_request_haptic("game_over")
		if persist_stats:
			_save_state()
		if analytics != null and !_is_local_game():
			analytics.on_game_over(
				result_kind,
				black_score if player_stone == ReversiEngine.BLACK else white_score,
				white_score if player_stone == ReversiEngine.BLACK else black_score,
				difficulty,
				state.get("move_history", []).size(),
			)
		_request_interstitial_ad()
	result_stats_label.visible = !_is_local_game()
	result_stats_label.text = _current_difficulty_stats_text() if !_is_local_game() else ""


func _update_result_highlights() -> void:
	if result_highlights_panel == null:
		return
	result_highlights_panel.visible = false
	result_highlights_title_label.text = ""
	result_highlights_label.text = ""
	var board_value = state.get("board", [])
	if typeof(board_value) != TYPE_ARRAY:
		return
	var board_size := ReversiEngine.get_board_size(board_value as Array)
	var summary := ReversiEngine.summarize_move_history(
		state.get("move_history", []),
		board_size,
	)
	if summary.is_empty():
		return
	var max_flip_move: Dictionary = summary.get("max_flip_move", {})
	var coordinate := move_coordinate(
		int(max_flip_move.get("x", -1)),
		int(max_flip_move.get("y", -1)),
	)
	result_highlights_title_label.text = _t("result_highlights_title")
	result_highlights_label.text = "\n".join(PackedStringArray([
		_t("result_highlight_flip") % [
			_piece_label(int(max_flip_move.get("stone", ReversiEngine.NONE))),
			coordinate,
			int(summary.get("max_flip_count", 0)),
		],
		_t("result_highlight_corners") % [
			int(summary.get("corner_black", 0)),
			int(summary.get("corner_white", 0)),
		],
		_t("result_highlight_lead") % [
			_piece_label(int(summary.get("peak_lead_stone", ReversiEngine.NONE))),
			int(summary.get("peak_lead", 0)),
		],
	]))
	result_highlights_panel.visible = true


func _update_puzzle_result_overlay(black_score: int, white_score: int) -> void:
	var definition := _active_puzzle_definition()
	var winner := int(state.get("winner", ReversiEngine.NONE))
	if result_highlights_panel != null:
		result_highlights_panel.visible = false
	result_title_label.text = _t("puzzle_complete") if _puzzle_success else _t("puzzle_failed")
	var title_color := _theme_color("accent") if _puzzle_success else _theme_color("danger")
	result_title_label.add_theme_color_override("font_color", title_color)
	_apply_text_visibility(result_title_label, 3, title_color)
	result_score_label.text = "%d : %d" % [
		black_score if player_stone == ReversiEngine.BLACK else white_score,
		white_score if player_stone == ReversiEngine.BLACK else black_score,
	]
	result_detail_label.text = _t("result_detail") % [black_score, white_score]
	result_stats_label.visible = true
	result_stats_label.text = _t(str(definition.get("goal_key", "")))
	if result_replay_button != null:
		result_replay_button.disabled = true
	if result_restart_button != null:
		result_restart_button.text = _t("puzzle_standard_game")
	_show_result_overlay(winner)
	if !_interstitial_shown_this_game:
		_interstitial_shown_this_game = true
		_request_haptic("game_over")


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


func _result_share_text() -> String:
	return _t("result_share_text") % [
		_t("app_title"),
		result_title_label.text,
		result_detail_label.text,
	]


func _share_result() -> bool:
	var share_text := _result_share_text().strip_edges()
	if share_text.is_empty():
		return false
	if _share_result_probe.is_valid():
		_share_result_probe.call(share_text)
		return true
	if OS.has_feature("web"):
		var bridge: JavaScriptObject = JavaScriptBridge.get_interface("__aitBridge")
		if bridge != null and bridge.shareResult != null:
			bridge.shareResult(share_text)
			return true
		return false
	if DisplayServer.get_name() == "headless":
		return false
	DisplayServer.clipboard_set(share_text)
	return true


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
	if _is_local_game():
		return (
			_t("status_black_turn")
			if int(state.get("current_turn", ReversiEngine.NONE)) == ReversiEngine.BLACK
			else _t("status_white_turn")
		)
	if int(state.get("current_turn", ReversiEngine.NONE)) == player_stone:
		return _t("status_your_move")
	return _t("status_ai_turn")


func _turn_text(current_turn: int) -> String:
	if current_turn == ReversiEngine.NONE:
		return _t("turn_final")
	if _is_local_game():
		return _t("turn_black") if current_turn == ReversiEngine.BLACK else _t("turn_white")
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


func _is_hinted_move(x: int, y: int) -> bool:
	return !_hinted_move.is_empty() \
		and int(_hinted_move.get("x", -1)) == x \
		and int(_hinted_move.get("y", -1)) == y


static func move_coordinate(column: int, row: int) -> String:
	if column < 0 or column >= 26 or row < 0:
		return "--"
	return "%s%d" % ["ABCDEFGHIJKLMNOPQRSTUVWXYZ".substr(column, 1), row + 1]


func _last_move_text() -> String:
	var last_move: Dictionary = state.get("last_move", {})
	if last_move.is_empty():
		return "--"
	return move_coordinate(
		int(last_move.get("y", -1)),
		int(last_move.get("x", -1)),
	)


func _advantage_text(player_score: int, ai_score: int) -> String:
	var diff := player_score - ai_score
	if diff > 0:
		return _t("focus_player_leads") % diff
	if diff < 0:
		return _t("focus_ai_leads") % abs(diff)
	return _t("focus_even")


func _local_advantage_text(black_score: int, white_score: int) -> String:
	var diff := black_score - white_score
	if diff > 0:
		return _t("focus_black_leads") % diff
	if diff < 0:
		return _t("focus_white_leads") % abs(diff)
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


func _current_opponent_mode() -> String:
	return ReversiEngine.normalize_opponent_mode(
		str(_current_settings().get("opponent_mode", "ai"))
	)


func _current_variant() -> String:
	return ReversiEngine.normalize_variant(
		str(_current_settings().get("variant", ReversiEngine.VARIANT_STANDARD))
	)


func _is_local_game() -> bool:
	return _current_opponent_mode() == "local"


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


func _legal_move_preview_stone() -> int:
	if state.is_empty() or input_locked or bool(state.get("game_over", false)):
		return ReversiEngine.NONE
	var current_turn := int(state.get("current_turn", ReversiEngine.NONE))
	if current_turn != ReversiEngine.BLACK and current_turn != ReversiEngine.WHITE:
		return ReversiEngine.NONE
	if !_is_local_game() and current_turn != player_stone:
		return ReversiEngine.NONE
	return current_turn


func _show_flip_counts_enabled() -> bool:
	return bool(_current_settings().get("show_flip_counts", false))


func _high_contrast_enabled() -> bool:
	return bool(_current_settings().get("high_contrast", false))


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
	ReversiEngine._refresh_result(state)
	preferences["settings"] = preferred_settings.duplicate(true)


func _sync_preferences_from_state() -> void:
	preferences = ReversiEngine.normalize_preferences({
		"version": 1,
		"difficulty": difficulty,
		"how_to_play_seen": bool(preferences.get("how_to_play_seen", false)),
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


func _set_opponent_mode_from_choice(opponent_mode: String) -> void:
	if !OPPONENT_MODE_IDS.has(opponent_mode):
		return
	if opponent_mode == _current_opponent_mode():
		_update_settings_choice_buttons()
		return
	var keep_settings_open := settings_overlay != null and settings_overlay.visible
	var settings := _current_settings()
	settings["opponent_mode"] = opponent_mode
	state["settings"] = settings
	if analytics != null:
		analytics.on_settings_changed("opponent_mode", opponent_mode)
	_save_preferences()
	_start_new_game(player_stone)
	if keep_settings_open:
		_show_settings_menu()


func _set_variant_from_choice(variant: String) -> void:
	var normalized_variant := ReversiEngine.normalize_variant(variant)
	if normalized_variant != variant or normalized_variant == _current_variant():
		_update_settings_choice_buttons()
		return
	var keep_settings_open := settings_overlay != null and settings_overlay.visible
	var settings := _current_settings()
	settings["variant"] = normalized_variant
	state["settings"] = settings
	if analytics != null:
		analytics.on_settings_changed("variant", normalized_variant)
	_save_preferences()
	_start_new_game(player_stone)
	if keep_settings_open:
		_show_settings_menu()


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


func _difficulty_description(difficulty_id: String) -> String:
	match difficulty_id:
		"EASY":
			return _t("difficulty_easy_description")
		"HARD":
			return _t("difficulty_hard_description")
		_:
			return _t("difficulty_medium_description")


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
	var config: Dictionary

	match id:
		"arctic":
			config = {
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
			config = {
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
		"forest":
			config = {
				"bg": Color(0.018, 0.035, 0.024, 1.0),
				"hud": Color(0.055, 0.105, 0.070, 1.0),
				"hud_dark": Color(0.025, 0.060, 0.038, 1.0),
				"board_frame": Color(0.008, 0.014, 0.010, 1.0),
				"board_frame_border": Color(0.34, 0.45, 0.30, 0.72),
				"board_surface": Color(0.055, 0.31, 0.135, 1.0),
				"board_grid": Color(0.006, 0.055, 0.018, 0.96),
				"meter_bg": Color(0.012, 0.032, 0.020, 1.0),
				"text_primary": Color(0.96, 0.99, 0.94, 1.0),
				"text_muted": Color(0.76, 0.86, 0.73, 1.0),
				"accent": Color(1.0, 0.84, 0.24, 1.0),
				"danger": DANGER,
				"success": Color(0.42, 0.91, 0.52, 1.0),
				"hint": Color(0.80, 1.0, 0.72, 0.94),
				"hint_border": Color(0.96, 1.0, 0.90, 0.88),
			}
		"sakura":
			config = {
				"bg": Color(0.055, 0.027, 0.050, 1.0),
				"hud": Color(0.145, 0.066, 0.115, 1.0),
				"hud_dark": Color(0.085, 0.038, 0.070, 1.0),
				"board_frame": Color(0.050, 0.018, 0.038, 1.0),
				"board_frame_border": Color(0.92, 0.48, 0.64, 0.58),
				"board_surface": Color(0.46, 0.18, 0.27, 1.0),
				"board_grid": Color(0.12, 0.025, 0.070, 0.94),
				"meter_bg": Color(0.045, 0.020, 0.040, 1.0),
				"text_primary": Color(1.0, 0.96, 0.96, 1.0),
				"text_muted": Color(0.93, 0.76, 0.81, 1.0),
				"accent": Color(1.0, 0.78, 0.48, 1.0),
				"danger": DANGER,
				"success": Color(0.55, 0.92, 0.68, 1.0),
				"hint": Color(1.0, 0.90, 0.56, 0.94),
				"hint_border": Color(1.0, 0.97, 0.86, 0.82),
			}
		_:
			config = {
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
	config["board_dark"] = Color(config["board_surface"]).darkened(0.48)
	config["board_light"] = Color(config["board_surface"]).lightened(0.42)
	config.merge(board_depth_palette(config["board_surface"], config["text_muted"]))
	return config


static func board_depth_palette(surface: Color, muted: Color) -> Dictionary:
	var highlight := surface.lightened(0.18)
	highlight.a = 0.48
	var shadow := surface.darkened(0.34)
	shadow.a = 0.55
	var guide := muted
	guide.a = 0.44
	return {
		"board_highlight": highlight,
		"board_shadow": shadow,
		"board_guide": guide,
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
		"sakura":
			return {
				"black_texture": SAKURA_BLACK_TEXTURE,
				"white_texture": SAKURA_WHITE_TEXTURE,
				"black_meter": Color(0.16, 0.055, 0.12, 1.0),
				"white_meter": Color(1.0, 0.88, 0.90, 1.0),
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
	if _is_puzzle_active():
		return
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
