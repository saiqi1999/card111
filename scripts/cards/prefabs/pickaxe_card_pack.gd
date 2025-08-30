extends "res://scripts/cards/card_pack_base.gd"
# 十字镐卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("十字镐", "用于挖掘矿物和土壤的工具")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/十字镐.png")
	
	# 设置卡牌数据
	set_card_data("十字镐", "用于挖掘矿物和土壤的工具")
	
	# 设置点击特效
	on_click = pickaxe_click_effect

# 十字镐卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func pickaxe_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 十字镐卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 十字镐的特效逻辑
	var mining_power = randi() % 5 + 3  # 生成3-7的随机挖掘力
	GlobalUtil.log("十字镐：挖掘力 " + str(mining_power) + "，可以挖掘石头和土壤", GlobalUtil.LogLevel.INFO)