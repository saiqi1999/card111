extends "res://scripts/cards/card_pack_base.gd"
# 小魔法气息卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("小魔法气息", "微弱的魔法能量，可以提供基础魔法支持")
	
	# 设置卡牌类型标识符
	card_type = "small_magic_aura"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/魔法气息小.png")
	
	# 设置卡牌数据
	set_card_data("小魔法气息", "微弱的魔法能量，可以提供基础魔法支持")
	
	# 设置点击特效
	on_click = small_magic_aura_click_effect

# 小魔法气息卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func small_magic_aura_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 小魔法气息卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 小魔法气息的特效逻辑
	var magic_power = randi() % 3 + 1  # 生成1-3的随机魔法力量
	GlobalUtil.log("小魔法气息：魔法力量 " + str(magic_power) + "，微弱的魔法能量闪烁", GlobalUtil.LogLevel.INFO)