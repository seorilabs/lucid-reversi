extends RefCounted

## 리버시 게임 Analytics 어댑터.
## 이벤트를 GA4 Measurement Protocol 전송기(ga4_mp_sender.gd, Node)로 포워딩한다.
## 전송 방식은 플랫폼 네이티브 브리지가 아니라 REST(HTTPRequest)라 iOS/Web/AIT 공통으로 동작한다.
## 실제 전송 여부/조건(config 존재·릴리스 빌드·비-headless)은 전송기가 판단한다.
## 익명 카운터/식별자만 보낸다(PII 금지).

var _sender: Node


# main 이 생성/add_child 한 GA4 전송기 Node 를 주입한다.
func set_sender(node: Node) -> void:
	_sender = node


func log_event(event_name: String, params: Dictionary = {}) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if OS.is_debug_build():
		print("[analytics] %s %s" % [event_name, params])
	if is_instance_valid(_sender) and _sender.has_method("send"):
		_sender.send(event_name, params)


## ── 게임 이벤트 헬퍼 ─────────────────────────────────────────────

func on_game_start(difficulty: String, player_stone: int) -> void:
	log_event("game_start", {
		"difficulty": difficulty,
		"player_stone": player_stone,  # 1=black 2=white
	})


# result 는 main 이 판정해 전달한다("win"/"lose"/"draw"). 어댑터가 승패를 다시 계산하지 않는다.
func on_game_over(result: String, player_score: int, ai_score: int, difficulty: String, total_moves: int) -> void:
	log_event("game_over", {
		"result": result,
		"player_score": player_score,
		"ai_score": ai_score,
		"difficulty": difficulty,
		"total_moves": total_moves,
	})


func on_settings_changed(setting_key: String, new_value: String) -> void:
	log_event("settings_changed", {
		"setting_key": setting_key,
		"new_value": new_value,
	})
