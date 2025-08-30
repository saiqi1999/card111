extends "res://scripts/cards/card_pack_base.gd"
# 镰刀卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("镰刀", "弯曲的收割工具，用于收割作物")
	
	# 设置卡牌类型标识符
	card_type = "sickle"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/镰刀.png")
	
	# 设置卡牌数据
	set_card_data("镰刀", "弯曲的收割工具，用于收割作物")
	
	# 设置点击特效
	on_click = sickle_click_effect

# 镰刀卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func sickle_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 镰刀卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 镰刀的特效逻辑
	var harvest_efficiency = randi() % 4 + 2  # 生成2-5的随机收割效率
	GlobalUtil.log("镰刀：收割效率 " + str(harvest_efficiency) + "，可以快速收割作物", GlobalUtil.LogLevel.INFO)