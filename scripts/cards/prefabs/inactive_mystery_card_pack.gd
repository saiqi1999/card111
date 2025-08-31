extends "res://scripts/cards/card_pack_base.gd"
# 未激活的奥秘卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("未激活的奥秘", "沉睡中的神秘力量，需要特定条件才能激活")
	
	# 设置卡牌类型标识符
	card_type = "inactive_mystery"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/未激活的奥秘.png")
	
	# 设置卡牌数据
	set_card_data("未激活的奥秘", "沉睡中的神秘力量，需要特定条件才能激活")
	
	# 设置点击特效
	on_click = inactive_mystery_click_effect

# 未激活的奥秘卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func inactive_mystery_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 未激活的奥秘卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 未激活的奥秘的特效逻辑
	GlobalUtil.log("未激活的奥秘：神秘的力量在沉睡中，等待着被唤醒的时刻", GlobalUtil.LogLevel.INFO)