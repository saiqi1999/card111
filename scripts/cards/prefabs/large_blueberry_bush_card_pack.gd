extends "res://scripts/cards/card_pack_base.gd"
# 大蓝莓丛卡包
# 导入卡牌工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")
# 收割计数器
var harvest_count: int = 0
# 耐久度（大蓝莓丛5次耐久）
var durability: int = 5

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("大蓝莓丛", "成熟的蓝莓丛，可以采集大量蓝莓")
	
	# 设置卡牌类型标识符
	card_type = "large_blueberry_bush"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/大蓝莓丛.png")
	
	# 设置卡牌数据
	set_card_data("大蓝莓丛", "成熟的蓝莓丛，可以采集大量蓝莓")
	
	# 设置点击特效
	on_click = large_blueberry_bush_click_effect
	
	# 设置合成完成后的回调
	after_recipe_done = large_blueberry_bush_after_recipe_done

# 大蓝莓丛卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func large_blueberry_bush_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 大蓝莓丛卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 大蓝莓丛的特效逻辑
	var berry_yield = randi() % 8 + 5  # 生成5-12的随机蓝莓产量
	GlobalUtil.log("大蓝莓丛：采集到 " + str(berry_yield) + " 个蓝莓", GlobalUtil.LogLevel.INFO)

# 合成完成后的回调方法（镰刀收割）
func large_blueberry_bush_after_recipe_done(card_instance, crafting_cards: Array):
	harvest_count += 1
	durability -= 1
	
	# 获取根节点
	var root_node = card_instance.get_tree().current_scene
	
	# 每次收割必定产出1个蓝莓
	var blueberry = CardUtil.create_card_from_pool(root_node, "blueberry", card_instance.global_position)
	if blueberry:
		var move_distance = CardUtil.random_move_card(blueberry)
		GlobalUtil.log("大蓝莓丛收割：生成蓝莓，随机移动距离: " + str(move_distance), GlobalUtil.LogLevel.INFO)
	
	# 第一次收割必定产出小魔法气息，之后50%几率产出
	var should_generate_magic = (harvest_count == 1) or (randf() < 0.5)
	if should_generate_magic:
		var magic_aura = CardUtil.create_card_from_pool(root_node, "small_magic_aura", card_instance.global_position)
		if magic_aura:
			var move_distance = CardUtil.random_move_card(magic_aura)
			GlobalUtil.log("大蓝莓丛收割：生成小魔法气息，随机移动距离: " + str(move_distance), GlobalUtil.LogLevel.INFO)
	
	GlobalUtil.log("大蓝莓丛收割完成，收割次数: " + str(harvest_count) + "，剩余耐久度: " + str(durability), GlobalUtil.LogLevel.INFO)
	
	# 检查耐久度，如果耐久度为0则销毁卡牌
	if durability <= 0:
		GlobalUtil.log("大蓝莓丛耐久度耗尽，开始回收", GlobalUtil.LogLevel.INFO)
		CardUtil.remove(card_instance)