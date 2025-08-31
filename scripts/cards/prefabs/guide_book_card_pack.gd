extends "res://scripts/cards/card_pack_base.gd"
# 向导之书卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("向导之书", "记录着古老智慧的神秘书籍")
	
	# 设置卡牌类型标识符
	card_type = "guide_book"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/向导之书.png")
	
	# 设置卡牌数据
	set_card_data("向导之书", "记录着古老智慧的神秘书籍")
	
	# 设置点击特效
	on_click = guide_book_click_effect

# 向导之书卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func guide_book_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 向导之书卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 向导之书的特效逻辑
	GlobalUtil.log("向导之书：翻开书页，获得古老的智慧和指引", GlobalUtil.LogLevel.INFO)