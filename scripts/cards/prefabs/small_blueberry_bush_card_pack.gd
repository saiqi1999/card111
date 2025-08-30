extends "res://scripts/cards/card_pack_base.gd"
# 小蓝莓丛卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("小蓝莓丛", "幼小的蓝莓丛，可以采集少量蓝莓")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/小蓝莓丛.png")
	
	# 设置卡牌数据
	set_card_data("小蓝莓丛", "幼小的蓝莓丛，可以采集少量蓝莓")
	
	# 设置点击特效
	on_click = small_blueberry_bush_click_effect

# 小蓝莓丛卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func small_blueberry_bush_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 小蓝莓丛卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 小蓝莓丛的特效逻辑
	var berry_yield = randi() % 3 + 1  # 生成1-3的随机蓝莓产量
	GlobalUtil.log("小蓝莓丛：采集到 " + str(berry_yield) + " 个蓝莓", GlobalUtil.LogLevel.INFO)