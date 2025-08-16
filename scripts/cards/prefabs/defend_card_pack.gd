extends "res://scripts/cards/card_pack_base.gd"
# 防御卡包类

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("防御卡包", "包含基础防御卡牌的卡包")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/defend.jpg")
	
	# 设置卡牌数据
	set_card_data("防御", "获得5点护甲")
	
	# 设置点击特效：防御效果
	on_click = defend_click_effect

# 防御卡牌的点击特效：显示防御效果
# 参数: card_instance - 触发点击的卡牌实例
func defend_click_effect(card_instance):
	var armor_value = 5  # 防御值
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 防御卡牌特效触发！获得护甲: " + str(armor_value), GlobalUtil.LogLevel.INFO)