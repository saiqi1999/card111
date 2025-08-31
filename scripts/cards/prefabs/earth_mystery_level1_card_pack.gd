extends "res://scripts/cards/card_pack_base.gd"
# 地元素奥秘1级卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("地元素奥秘1级", "进阶的地元素魔法知识，掌握更强的大地之力")
	
	# 设置卡牌类型标识符
	card_type = "earth_mystery_level1"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/地元素奥秘1级.png")
	
	# 设置卡牌数据
	set_card_data("地元素奥秘1级", "进阶的地元素魔法知识，掌握更强的大地之力")
	
	# 设置点击特效
	on_click = earth_mystery_level1_click_effect

# 地元素奥秘1级卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func earth_mystery_level1_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 地元素奥秘1级卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 地元素奥秘1级的特效逻辑
	GlobalUtil.log("地元素奥秘1级：深入理解大地奥秘，释放强大的地元素魔法", GlobalUtil.LogLevel.INFO)