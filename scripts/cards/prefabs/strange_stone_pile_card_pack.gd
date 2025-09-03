extends "res://scripts/cards/card_pack_base.gd"
# 奇怪石堆卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("奇怪石堆", "散发着神秘气息的石头堆，似乎蕴含着未知的力量")
	
	# 设置卡牌类型标识符
	card_type = "strange_stone_pile"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/奇怪石堆.png")
	
	# 设置卡牌数据
	set_card_data("奇怪石堆", "散发着神秘气息的石头堆，似乎蕴含着未知的力量")
	
	# 添加fixed标签，防止拖动
	add_tag("fixed")
	
	# 设置点击特效
	on_click = strange_stone_pile_click_effect

# 奇怪石堆卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func strange_stone_pile_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 奇怪石堆卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 奇怪石堆的特效逻辑
	GlobalUtil.log("奇怪石堆：神秘的石堆散发出诡异的光芒，似乎隐藏着秘密", GlobalUtil.LogLevel.INFO)