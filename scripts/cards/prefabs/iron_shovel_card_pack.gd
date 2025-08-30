extends "res://scripts/cards/card_pack_base.gd"
# 铁铲卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("铁铲", "坚固的铁制铲子，用于挖掘土壤")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/铁铲.png")
	
	# 设置卡牌数据
	set_card_data("铁铲", "坚固的铁制铲子，用于挖掘土壤")
	
	# 设置点击特效
	on_click = iron_shovel_click_effect

# 铁铲卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func iron_shovel_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 铁铲卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 铁铲的特效逻辑
	var digging_power = randi() % 5 + 3  # 生成3-7的随机挖掘力
	GlobalUtil.log("铁铲：挖掘力 " + str(digging_power) + "，可以高效挖掘土壤", GlobalUtil.LogLevel.INFO)