extends "res://scripts/cards/card_pack_base.gd"
# 铁斧卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("铁斧", "锋利的铁制斧头，用于砍伐树木")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/铁斧.png")
	
	# 设置卡牌数据
	set_card_data("铁斧", "锋利的铁制斧头，用于砍伐树木")
	
	# 设置点击特效
	on_click = iron_axe_click_effect

# 铁斧卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func iron_axe_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 铁斧卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 铁斧的特效逻辑
	var chopping_power = randi() % 6 + 4  # 生成4-9的随机砍伐力
	GlobalUtil.log("铁斧：砍伐力 " + str(chopping_power) + "，可以高效砍伐树木", GlobalUtil.LogLevel.INFO)