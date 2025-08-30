extends "res://scripts/cards/card_pack_base.gd"
# 碎木头卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("碎木头", "破碎的木材，可以用作燃料或建造材料")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/碎木头.png")
	
	# 设置卡牌数据
	set_card_data("碎木头", "破碎的木材，可以用作燃料或建造材料")
	
	# 设置点击特效
	on_click = wood_scraps_click_effect

# 碎木头卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func wood_scraps_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 碎木头卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 碎木头的特效逻辑
	var wood_amount = randi() % 4 + 2  # 生成2-5的随机木材数量
	GlobalUtil.log("碎木头：获得 " + str(wood_amount) + " 单位木材，可用于制作或燃烧", GlobalUtil.LogLevel.INFO)