extends "res://scripts/cards/card_pack_base.gd"
# 气元素奥秘0级卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("气元素奥秘0级", "初级的气元素魔法知识，蕴含着风的力量")
	
	# 设置卡牌类型标识符
	card_type = "air_mystery_0"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/气元素奥秘0级.png")
	
	# 设置卡牌数据
	set_card_data("气元素奥秘0级", "初级的气元素魔法知识，蕴含着风的力量")
	
	# 设置点击特效
	on_click = air_mystery_level0_click_effect

# 气元素奥秘0级卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func air_mystery_level0_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 气元素奥秘0级卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 气元素奥秘0级的特效逻辑
	GlobalUtil.log("气元素奥秘0级：感受风的流动，获得初级气元素魔法力量", GlobalUtil.LogLevel.INFO)