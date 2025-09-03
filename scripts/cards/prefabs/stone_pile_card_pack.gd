extends "res://scripts/cards/card_pack_base.gd"
# 石堆卡包
# 导入卡牌工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")
# 合成计数器
var recipe_count: int = 0

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("石堆", "普通的石头堆积，可以用来建造或制作工具")
	
	# 设置卡牌类型标识符
	card_type = "stone_pile"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/石堆.png")
	
	# 设置卡牌数据
	set_card_data("石堆", "普通的石头堆积，可以用来建造或制作工具")
	
	# 设置点击特效
	on_click = stone_pile_click_effect
	
	# 设置合成完成后的回调
	after_recipe_done = stone_pile_after_recipe_done

# 石堆卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func stone_pile_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 石堆卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 石堆的特效逻辑
	var stone_amount = randi() % 4 + 2  # 生成2-5的随机石头数量
	GlobalUtil.log("石堆：获得 " + str(stone_amount) + " 单位石头，可用于制作或建造", GlobalUtil.LogLevel.INFO)

# 合成完成后的回调方法
func stone_pile_after_recipe_done(card_instance, crafting_cards: Array):
	recipe_count += 1
	GlobalUtil.log("石堆卡包参与合成，当前计数: " + str(recipe_count), GlobalUtil.LogLevel.INFO)
	
	# 随机生成资源，30%概率生成燧石，70%概率生成石头
	var root_node = card_instance.get_tree().current_scene
	var random_value = randf()
	var card_type = "flint" if random_value < 0.3 else "stone"
	var card = CardUtil.create_card_from_pool(root_node, card_type, card_instance.global_position)
	if card:
		# 对生成的卡牌进行随机移动
		var move_distance = CardUtil.random_move_card(card)
		GlobalUtil.log("石堆合成成功，生成" + ("燧石" if card_type == "flint" else "石头") + "，随机移动距离: " + str(move_distance), GlobalUtil.LogLevel.INFO)
	
	# 3次合成后回收自己
	if recipe_count >= 3:
		GlobalUtil.log("石堆卡包达到3次合成，开始回收", GlobalUtil.LogLevel.INFO)
		# 通过卡牌实例访问 CardUtil 的静态方法
		CardUtil.remove(card_instance)