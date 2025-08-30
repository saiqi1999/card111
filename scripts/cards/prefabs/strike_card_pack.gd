extends "res://scripts/cards/card_pack_base.gd"
# 由于全局已存在同名类，这里移除class_name声明

# 在子类中不应重新声明父类已有的变量

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("打击卡包", "包含基础打击卡牌的卡包")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/strike.png")
	
	# 设置卡牌数据
	set_card_data("打击", "造成6点伤害")
	
	# 设置点击特效：打印随机数
	on_click = strike_click_effect

# 打击卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func strike_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 打击卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 打击卡牌的特效逻辑
	var attack_damage = randi() % 10 + 6  # 生成6-15的随机伤害
	GlobalUtil.log("打击：造成 " + str(attack_damage) + " 点伤害", GlobalUtil.LogLevel.INFO)
