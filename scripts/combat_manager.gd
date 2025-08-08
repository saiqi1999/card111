# res://scripts/combat_manager.gd
extends Node

# UI引用
@export var hand_container: Node

func _ready() -> void:
	# 初始化战斗管理器
	print("Combat Manager initialized")
	
	# 初始化一张打击卡牌到手牌中
	add_strike_card()

# 点击卡牌方法
func click_card(card) -> void:
	# 调用卡牌的on_card_click方法
	if card.has_method("on_card_click"):
		card.on_card_click()
	
	# 打印一行字
	print("Card clicked: " + card.card_name)

# 添加一张打击卡牌到手牌中
func add_strike_card() -> void:
	# 检查手牌容器是否存在
	if not hand_container:
		print("Error: Hand container not found")
		return
	
	# 加载打击卡牌场景
	var strike_scene = load("res://scenes/cards/strike.tscn")
	if not strike_scene:
		# 尝试加载通用卡牌场景并设置脚本
		var card_scene = load("res://scenes/card.tscn")
		if card_scene:
			var card_instance = card_scene.instantiate()
			card_instance.set_script(load("res://scripts/cards/strike.gd"))
			
			# 添加到手牌容器
			hand_container.add_child(card_instance)
			print("Added Strike card to hand using generic card scene")
			
			# 连接卡牌点击信号
			card_instance.card_clicked.connect(click_card)
		else:
			print("Error: Could not load card scene")
	else:
		# 实例化打击卡牌
		var strike_instance = strike_scene.instantiate()
		
		# 添加到手牌容器
		hand_container.add_child(strike_instance)
		print("Added Strike card to hand")
		
		# 连接卡牌点击信号
		strike_instance.card_clicked.connect(click_card)