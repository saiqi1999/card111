extends "res://scripts/cards/card_pack_base.gd"
# 蓝莓卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("蓝莓", "新鲜的蓝莓，可以食用或制作药剂")
	
	# 设置卡牌类型标识符
	card_type = "blueberry"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/蓝莓.png")
	
	# 设置卡牌数据
	set_card_data("蓝莓", "新鲜的蓝莓，可以食用或制作药剂")
	
	# 设置点击特效
	on_click = blueberry_click_effect

# 蓝莓卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func blueberry_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 蓝莓卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 蓝莓的特效逻辑
	var health_restore = randi() % 3 + 2  # 生成2-4的随机生命恢复值
	GlobalUtil.log("蓝莓：恢复 " + str(health_restore) + " 点生命值，美味又营养", GlobalUtil.LogLevel.INFO)