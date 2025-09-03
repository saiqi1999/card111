extends "res://scripts/cards/card_pack_base.gd"
# 土堆卡包
# 导入卡牌工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")
# 合成计数器
var recipe_count: int = 0

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("土堆", "一堆松软的土壤")
	
	# 设置卡牌类型标识符
	card_type = "dirt_pile"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/土堆.png")
	
	# 设置卡牌数据
	set_card_data("土堆", "一堆松软的土壤")
	
	# 设置点击特效
	on_click = dirt_pile_click_effect
	
	# 设置合成完成后的回调
	after_recipe_done = dirt_pile_after_recipe_done

# 合成完成后的回调方法
func dirt_pile_after_recipe_done(card_instance, crafting_cards: Array):
	recipe_count += 1
	GlobalUtil.log("土堆卡包参与合成，当前计数: " + str(recipe_count), GlobalUtil.LogLevel.INFO)
	
	# 3次合成后回收自己
	if recipe_count >= 3:
		GlobalUtil.log("土堆卡包达到3次合成，开始回收", GlobalUtil.LogLevel.INFO)
		# 通过卡牌实例访问 CardUtil 的静态方法
		CardUtil.remove(card_instance)

# 土堆卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func dirt_pile_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 土堆卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 土堆的特效逻辑
	var soil_quality = randi() % 3 + 1  # 生成1-3的随机土壤质量
	GlobalUtil.log("土堆：土壤质量 " + str(soil_quality) + "，适合种植植物", GlobalUtil.LogLevel.INFO)
