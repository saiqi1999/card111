extends "res://scripts/cards/card_pack_base.gd"
# 刮风卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("刮风", "呼啸的风声，带来清新的空气")
	
	# 设置卡牌类型标识符
	card_type = "wind"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/刮风.png")
	
	# 设置卡牌数据
	set_card_data("刮风", "呼啸的风声，带来清新的空气")
	
	# 设置点击特效
	on_click = wind_click_effect

# 刮风卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func wind_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 刮风卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 刮风的特效逻辑
	GlobalUtil.log("刮风：清风徐来，驱散周围的阴霾", GlobalUtil.LogLevel.INFO)