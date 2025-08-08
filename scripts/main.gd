# res://scripts/main.gd
extends Node2D

# 节点引用
@onready var game_manager = $GameManager
@onready var combat_manager = $CombatManager
@onready var hand_container = $HandArea/HandContainer
@onready var ui = $UI2
@onready var health_label = $UI2/PlayerInfo/Panel/HealthLabel
@onready var energy_label = $UI2/PlayerInfo/Panel/EnergyLabel
@onready var end_turn_button = $UI2/EndTurnButton
@onready var background = $background

func _ready() -> void:
	print("Main scene initialized")
	
	# 初始化游戏
	if game_manager:
		# 启动游戏，设置为PLAYING状态
		game_manager.change_state(game_manager.GameState.PLAYING)
		print("Game started")
	
	# 打印背景图片信息
	if background and background.texture:
		print("背景图片已加载: %s" % background.texture.resource_path)
		print("背景图片位置: (%d, %d)" % [background.position.x, background.position.y])
		print("背景图片大小: 宽度 %d, 高度 %d" % [background.texture.get_width() * background.scale.x, background.texture.get_height() * background.scale.y])
		
		# 计算并打印背景四个顶点的坐标
		var width = background.texture.get_width() * background.scale.x
		var height = background.texture.get_height() * background.scale.y
		var top_left = Vector2(background.position.x - width/2, background.position.y - height/2)
		var top_right = Vector2(background.position.x + width/2, background.position.y - height/2)
		var bottom_left = Vector2(background.position.x - width/2, background.position.y + height/2)
		var bottom_right = Vector2(background.position.x + width/2, background.position.y + height/2)
		
		print("背景四个顶点坐标:")
		print("左上角: (%d, %d)" % [top_left.x, top_left.y])
		print("右上角: (%d, %d)" % [top_right.x, top_right.y])
		print("左下角: (%d, %d)" % [bottom_left.x, bottom_left.y])
		print("右下角: (%d, %d)" % [bottom_right.x, bottom_right.y])
		
	# 设置战斗管理器
	combat_manager.hand_container = hand_container
	combat_manager.health_label = health_label
	combat_manager.energy_label = energy_label
	
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
	# 初始化玩家状态
	combat_manager.set_max_health(80)
	combat_manager.set_health(80)
	combat_manager.set_max_energy(3)
	combat_manager.set_energy(3)
	
	# 开始第一个回合
	start_player_turn()

# 玩家回合开始
func start_player_turn() -> void:
	# 恢复能量
	combat_manager.restore_energy(combat_manager.max_energy)
	
	# 处理回合开始效果
	combat_manager.on_turn_start()
	
	# 抽牌
	combat_manager.draw_card()

# 玩家回合结束
func end_player_turn() -> void:
	# 处理回合结束效果
	combat_manager.on_turn_end()
	
	# 开始新回合
	start_player_turn()

# 结束回合按钮回调
func _on_end_turn_button_pressed() -> void:
	end_player_turn()
