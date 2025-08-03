# res://scripts/main.gd
extends Node2D

# 节点引用
@onready var game_manager = $GameManager
@onready var card_manager = $CardManager
@onready var hand_container = $HandArea/HandContainer
@onready var player_manager = $PlayerManager
@onready var ui = $UI2
@onready var health_label = $UI2/PlayerInfo/Panel/HealthLabel
@onready var energy_label = $UI2/PlayerInfo/Panel/EnergyLabel
@onready var end_turn_button = $UI2/EndTurnButton

func _ready() -> void:
	print("Main scene initialized")
	
	# 初始化游戏
	if game_manager:
		# 启动游戏，设置为PLAYING状态
		game_manager.change_state(game_manager.GameState.PLAYING)
		print("Game started")
		
	# 设置卡牌管理器
	card_manager.hand_container = hand_container
	
	# 设置玩家管理器
	player_manager.health_label = health_label
	player_manager.energy_label = energy_label
	
	# 连接结束回合按钮信号
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	
	# 初始化测试牌库
	initialize_test_deck()

func _process(delta: float) -> void:
	# 游戏主循环
	if game_manager and game_manager.current_state == game_manager.GameState.PLAYING:
		# 游戏运行中的逻辑
		pass

# 初始化测试牌库
func initialize_test_deck() -> void:
	# 创建测试卡牌数据
	var test_cards = [
		{"name": "攻击", "cost": 1, "description": "造成6点伤害", "script": "res://scripts/cards/strike.gd"},
		{"name": "防御", "cost": 1, "description": "获得5点护甲"},
		{"name": "抽牌", "cost": 0, "description": "抽2张牌"},
		{"name": "强力打击", "cost": 2, "description": "造成10点伤害"},
		{"name": "治疗", "cost": 1, "description": "恢复4点生命"},
		{"name": "火球术", "cost": 2, "description": "对所有敌人造成4点伤害"},
		{"name": "闪电链", "cost": 3, "description": "造成7点伤害，并对相邻敌人造成3点伤害"},
		{"name": "冰冻", "cost": 2, "description": "冻结一个敌人1回合"},
		{"name": "毒药", "cost": 1, "description": "施加3层中毒"},
		{"name": "能量药水", "cost": 0, "description": "获得1点能量"}
	]
	
	# 初始化牌库
	card_manager.initialize_deck(test_cards)
	
	# 抽初始手牌
	card_manager.draw_starting_hand()
	
	# 初始化玩家状态
	player_manager.set_max_health(80)
	player_manager.set_health(80)
	player_manager.set_max_energy(3)
	player_manager.set_energy(3)
	
	# 开始第一个回合
	start_player_turn()

# 玩家回合开始
func start_player_turn() -> void:
	# 恢复能量
	player_manager.restore_energy(player_manager.max_energy)
	
	# 处理回合开始效果
	player_manager.on_turn_start()
	
	# 抽牌
	card_manager.draw_cards(5)

# 玩家回合结束
func end_player_turn() -> void:
	# 处理回合结束效果
	player_manager.on_turn_end()
	
	# 弃掉所有手牌
	card_manager.discard_hand()
	
	# 开始新回合
	start_player_turn()

# 结束回合按钮回调
func _on_end_turn_button_pressed() -> void:
	end_player_turn()
