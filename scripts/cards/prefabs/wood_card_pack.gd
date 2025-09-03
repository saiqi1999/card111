extends "res://scripts/cards/card_pack_base.gd"
# 木材卡包
# 导入卡牌工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("木材", "优质的木材，可以用来建造房屋或制作工具")
	
	# 设置卡牌类型标识符
	card_type = "wood"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/木材.png")
	
	# 设置卡牌数据
	set_card_data("木材", "优质的木材，可以用来建造房屋或制作工具")
	
	# 设置点击特效
	on_click = wood_click_effect
	
	# 设置合成完成后的回调
	after_recipe_done = wood_after_recipe_done

# 木材卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func wood_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 木材卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 木材的特效逻辑
	GlobalUtil.log("木材：坚实的木材，散发着自然的香气，是建造的重要材料", GlobalUtil.LogLevel.INFO)

# 合成完成后的回调方法
func wood_after_recipe_done(card_instance, crafting_cards: Array):
	GlobalUtil.log("木材卡包参与合成，开始回收", GlobalUtil.LogLevel.INFO)
	# 通过卡牌实例访问 CardUtil 的静态方法
	CardUtil.remove(card_instance)