extends "res://scripts/cards/card_pack_base.gd"
# 石堆卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("石堆", "普通的石头堆积，可以用来建造或制作工具")
	
	# 设置卡牌类型标识符
	card_type = "stone_pile"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/石堆.png")
	
	# 设置卡牌数据
	set_card_data("石堆", "普通的石头堆积，可以用来建造或制作工具")
	
	# 设置点击特效
	on_click = stone_pile_click_effect

# 石堆卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func stone_pile_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 石堆卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 石堆的特效逻辑
	GlobalUtil.log("石堆：坚硬的石头堆，是建造和制作的基础材料", GlobalUtil.LogLevel.INFO)