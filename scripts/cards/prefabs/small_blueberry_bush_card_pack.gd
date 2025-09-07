extends "res://scripts/cards/card_pack_base.gd"
# 小蓝莓丛卡包
# 导入卡牌工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")
# 收割计数器
var harvest_count: int = 0
# 耐久度（小蓝莓丛3次耐久）
var durability: int = 3

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("小蓝莓丛", "幼小的蓝莓丛，可以采集少量蓝莓")
	
	# 设置卡牌类型标识符
	card_type = "small_blueberry_bush"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/小蓝莓丛.png")
	
	# 设置卡牌数据
	set_card_data("小蓝莓丛", "幼小的蓝莓丛，可以采集少量蓝莓")
	
	# 设置点击特效
	on_click = small_blueberry_bush_click_effect

	# 设置合成完成后的回调
	after_recipe_done = small_blueberry_bush_after_recipe_done

# 小蓝莓丛卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func small_blueberry_bush_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 小蓝莓丛卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 小蓝莓丛的特效逻辑
	var berry_yield = randi() % 3 + 1  # 生成1-3的随机蓝莓产量
	GlobalUtil.log("小蓝莓丛：采集到 " + str(berry_yield) + " 个蓝莓", GlobalUtil.LogLevel.INFO)

# 合成完成后的回调方法（镰刀收割）
func small_blueberry_bush_after_recipe_done(card_instance, crafting_cards: Array):
	harvest_count += 1
	durability -= 1
	
	# 获取根节点
	var root_node = card_instance.get_tree().current_scene
	
	# 每次收割必定产出1个蓝莓
	var blueberry = CardUtil.create_card_from_pool(root_node, "blueberry", card_instance.global_position)
	if blueberry:
		# 使用pop_card_in_range进行生成后处理
		StackUtil.pop_card_in_range(blueberry, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
		GlobalUtil.log("小蓝莓丛收割：生成蓝莓，使用pop_card_in_range处理", GlobalUtil.LogLevel.INFO)
	
	# 第一次收割必定产出小魔法气息，之后50%几率产出
	var should_generate_magic = (harvest_count == 1) or (randf() < 0.5)
	if should_generate_magic:
		var magic_aura = CardUtil.create_card_from_pool(root_node, "small_magic_aura", card_instance.global_position)
		if magic_aura:
			# 使用pop_card_in_range进行生成后处理
			StackUtil.pop_card_in_range(magic_aura, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
			GlobalUtil.log("小蓝莓丛收割：生成小魔法气息，使用pop_card_in_range处理", GlobalUtil.LogLevel.INFO)
	
	GlobalUtil.log("小蓝莓丛收割完成，收割次数: " + str(harvest_count) + "，剩余耐久度: " + str(durability), GlobalUtil.LogLevel.INFO)
	
	# 检查耐久度，如果耐久度为0则销毁卡牌
	if durability <= 0:
		GlobalUtil.log("小蓝莓丛耐久度耗尽，开始回收", GlobalUtil.LogLevel.INFO)
		CardUtil.remove(card_instance)
