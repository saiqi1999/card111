extends "res://scripts/cards/card_pack_base.gd"
# Want Slime卡包类

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("Want Slime卡包", "包含召唤史莱姆的卡牌")
	
	# 设置卡牌类型标识符
	card_type = "want_slime"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/wantSlime.jpg")
	
	# 设置卡牌数据
	set_card_data("Want Slime", "召唤一只可爱的史莱姆")
	
	# 设置点击特效：召唤史莱姆效果
	on_click = want_slime_click_effect

# Want Slime卡牌的点击特效：召唤史莱姆
# 参数: card_instance - 触发点击的卡牌实例
func want_slime_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 卡牌位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 生成史莱姆数据
	var slime_hp = randi() % 10 + 5  # 生成5-14的随机生命值
	var slime_attack = randi() % 3 + 1  # 生成1-3的随机攻击力
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " Want Slime卡牌特效触发！召唤史莱姆 - 生命值: " + str(slime_hp) + ", 攻击力: " + str(slime_attack), GlobalUtil.LogLevel.INFO)
