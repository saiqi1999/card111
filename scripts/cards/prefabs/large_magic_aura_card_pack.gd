extends "res://scripts/cards/card_pack_base.gd"
# 大魔法气息卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("大魔法气息", "强大的魔法能量，可以增强法术效果")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/魔法气息大.png")
	
	# 设置卡牌数据
	set_card_data("大魔法气息", "强大的魔法能量，可以增强法术效果")
	
	# 设置点击特效
	on_click = large_magic_aura_click_effect

# 大魔法气息卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func large_magic_aura_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 大魔法气息卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 大魔法气息的特效逻辑
	var magic_power = randi() % 8 + 5  # 生成5-12的随机魔法力量
	GlobalUtil.log("大魔法气息：魔法力量 " + str(magic_power) + "，强大的魔法能量涌动", GlobalUtil.LogLevel.INFO)