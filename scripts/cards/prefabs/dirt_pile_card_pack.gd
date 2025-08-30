extends "res://scripts/cards/card_pack_base.gd"
# 土堆卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("土堆", "可以用于种植或建造的土壤")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/土堆.png")
	
	# 设置卡牌数据
	set_card_data("土堆", "可以用于种植或建造的土壤")
	
	# 设置点击特效
	on_click = dirt_pile_click_effect

# 土堆卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func dirt_pile_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 土堆卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 土堆的特效逻辑
	var soil_quality = randi() % 3 + 1  # 生成1-3的随机土壤质量
	GlobalUtil.log("土堆：土壤质量 " + str(soil_quality) + "，适合种植植物", GlobalUtil.LogLevel.INFO)