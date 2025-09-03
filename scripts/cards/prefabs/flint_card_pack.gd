extends "res://scripts/cards/card_pack_base.gd"
# 燧石卡包
# 导入卡牌工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("燧石", "坚硬的燧石，可以用来生火或制作工具")
	
	# 设置卡牌类型标识符
	card_type = "flint"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/燧石.png")
	
	# 设置卡牌数据
	set_card_data("燧石", "坚硬的燧石，可以用来生火或制作工具")
	
	# 设置点击特效
	on_click = flint_click_effect
	
	# 设置合成完成后的回调
	after_recipe_done = flint_after_recipe_done

# 燧石卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func flint_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 燧石卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 燧石的特效逻辑
	GlobalUtil.log("燧石：坚硬的石头，敲击时能产生火花，是生火的重要工具", GlobalUtil.LogLevel.INFO)

# 合成完成后的回调方法
func flint_after_recipe_done(card_instance, crafting_cards: Array):
	GlobalUtil.log("燧石卡包参与合成，开始回收", GlobalUtil.LogLevel.INFO)
	# 通过卡牌实例访问 CardUtil 的静态方法
	CardUtil.remove(card_instance)
