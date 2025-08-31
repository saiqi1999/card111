extends "res://scripts/cards/card_pack_base.gd"
# 下雨卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("下雨", "天空中降下的雨水，滋润大地万物")
	
	# 设置卡牌类型标识符
	card_type = "rain"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/下雨.png")
	
	# 设置卡牌数据
	set_card_data("下雨", "天空中降下的雨水，滋润大地万物")
	
	# 设置点击特效
	on_click = rain_click_effect

# 下雨卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func rain_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 下雨卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 下雨的特效逻辑
	GlobalUtil.log("下雨：天空降下甘露，为周围的植物提供水分", GlobalUtil.LogLevel.INFO)