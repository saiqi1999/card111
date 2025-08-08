extends "res://scripts/cards/card_pack_base.gd"
class_name StrikeCardPack

# 在子类中不应重新声明父类已有的变量

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("打击卡包", "包含基础打击卡牌的卡包")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/strike.png")
	
	# 这里可以添加特定于打击卡包的初始化逻辑
	# 例如预先添加一些打击卡牌
	# 注意：这里需要Card类已经实现
	# 如果Card类尚未实现，可以先注释掉这部分代码
	# var strike_card = Card.new("打击", "造成6点伤害", 1)
	# add_card(strike_card)
