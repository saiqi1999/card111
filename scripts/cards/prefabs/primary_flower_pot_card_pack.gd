extends "res://scripts/cards/card_pack_base.gd"
# 初级花盆卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("初级花盆", "用于种植植物的基础花盆")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/初级花盆.png")
	
	# 设置卡牌数据
	set_card_data("初级花盆", "用于种植植物的基础花盆")
	
	# 设置点击特效
	on_click = primary_flower_pot_click_effect

# 初级花盆卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func primary_flower_pot_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 初级花盆卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 初级花盆的特效逻辑
	GlobalUtil.log("初级花盆：可以种植小型植物", GlobalUtil.LogLevel.INFO)