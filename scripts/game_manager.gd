# res://scripts/game_manager.gd
extends Node

# 游戏状态枚举
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

# 当前游戏状态
var current_state: GameState = GameState.MENU

# 游戏数据
var player_data = {
	"health": 100,
	"max_health": 100,
	"gold": 0,
	"deck": []
}

func _ready() -> void:
	print("Game Manager initialized")

# 改变游戏状态
func change_state(new_state: GameState) -> void:
	current_state = new_state
	print("Game state changed to: ", new_state)
	
	# 根据不同状态执行相应操作
	match new_state:
		GameState.MENU:
			_on_enter_menu_state()
		GameState.PLAYING:
			_on_enter_playing_state()
		GameState.PAUSED:
			_on_enter_paused_state()
		GameState.GAME_OVER:
			_on_enter_game_over_state()

# 各状态进入时的处理函数
func _on_enter_menu_state() -> void:
	pass

func _on_enter_playing_state() -> void:
	pass

func _on_enter_paused_state() -> void:
	pass

func _on_enter_game_over_state() -> void:
	pass

# 保存游戏数据
func save_game() -> void:
	# 这里实现保存游戏数据的逻辑
	pass

# 加载游戏数据
func load_game() -> void:
	# 这里实现加载游戏数据的逻辑
	pass