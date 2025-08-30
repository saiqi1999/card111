extends "res://scripts/cards/card_pack_base.gd"
# 旧木屋卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("旧木屋", "破旧的木制房屋，可以提供基础庇护")
	
	# 设置卡牌类型标识符
	card_type = "old_wooden_house"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/旧木屋.png")
	
	# 设置卡牌数据
	set_card_data("旧木屋", "破旧的木制房屋，可以提供基础庇护")
	
	# 设置点击特效
	on_click = old_wooden_house_click_effect

# 旧木屋卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func old_wooden_house_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 旧木屋卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 旧木屋的特效逻辑
	var shelter_value = randi() % 5 + 3  # 生成3-7的随机庇护值
	GlobalUtil.log("旧木屋：提供庇护值 " + str(shelter_value) + "，可以休息和存储物品", GlobalUtil.LogLevel.INFO)