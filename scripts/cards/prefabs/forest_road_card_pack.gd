extends "res://scripts/cards/card_pack_base.gd"
# 森林道路卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("森林道路", "穿越森林的小径，可以快速移动")
	
	# 设置卡牌类型标识符
	card_type = "forest_road"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/森林道路.png")
	
	# 设置卡牌数据
	set_card_data("森林道路", "穿越森林的小径，可以快速移动")
	
	# 设置点击特效
	on_click = forest_road_click_effect

# 森林道路卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func forest_road_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 森林道路卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 森林道路的特效逻辑
	var movement_speed = randi() % 3 + 2  # 生成2-4的随机移动速度加成
	GlobalUtil.log("森林道路：移动速度提升 " + str(movement_speed) + "，可以快速穿越森林", GlobalUtil.LogLevel.INFO)