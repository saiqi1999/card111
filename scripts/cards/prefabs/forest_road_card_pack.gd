extends "res://scripts/cards/card_pack_base.gd"
# 森林道路卡包

# 引入必要的工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")
const EventUtil = preload("res://scripts/utils/event_util.gd")
const GlobalUtil = preload("res://scripts/utils/util.gd")
const GlobalConstants = preload("res://scripts/utils/global_constants.gd")

# 点击计数器
var click_count = 0

# 已生成卡牌的位置记录
var generated_positions = []

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("森林道路", "穿越森林的小径，可以快速移动")
	
	# 设置卡牌类型标识符
	card_type = "forest_road"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/森林道路.png")
	
	# 设置卡牌数据
	set_card_data("森林道路", "穿越森林的小径，可以快速移动")
	
	# 设置点击特效
	on_click = forest_road_click_effect

# 检查位置是否与已生成的卡牌位置重叠
func is_position_overlapping(pos: Vector2) -> bool:
	for existing_pos in generated_positions:
		if pos.distance_to(existing_pos) < 400: # 设置最小间距为100像素
			return true
	return false

# 生成一个随机位置
func generate_random_position(base_position: Vector2, min_distance: float, max_distance: float) -> Vector2:
	var angle = randf() * 2 * PI
	var distance = randf_range(min_distance, max_distance)
	return base_position + Vector2(cos(angle) * distance, sin(angle) * distance)

# 获取一个有效的随机位置
func get_valid_position(base_position: Vector2, min_distance: float, max_distance: float) -> Vector2:
	var attempts = 0
	while attempts < 23: # 最多尝试23次
		var pos = generate_random_position(base_position, min_distance, max_distance)
		if not is_position_overlapping(pos):
			generated_positions.append(pos)
			return pos
		attempts += 1
	
	# 如果23次都没找到合适的位置，返回最后一次生成的位置
	var final_pos = generate_random_position(base_position, min_distance, max_distance)
	generated_positions.append(final_pos)
	return final_pos

# 生成初始资源
func generate_initial_resources(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	
	# 清空已生成位置的记录
	generated_positions.clear()
	
	# 定义要生成的资源及其数量
	var resources_to_generate = {
		"flint": 3,
		"wood": 1,
		"wood_scraps": 1,
		"stone_pile": 1,
		"strange_stone_pile": 1
	}
	
	# 生成初始资源卡牌，在较远的位置
	for type in resources_to_generate:
		for i in range(resources_to_generate[type]):
			var card_pos = get_valid_position(card_position, 600, 1000) # 设置较远的距离范围
			var resource = CardUtil.create_card_from_pool(card_instance.get_tree().root, type, card_position)
			if resource:
				CardUtil.move_card(resource, card_pos)
				GlobalUtil.log("森林道路：生成了一张" + type + "卡牌，位置: " + str(card_pos), GlobalUtil.LogLevel.INFO)
				
				# 打印当前生成的卡牌类型
				GlobalUtil.log("森林道路：正在生成卡牌类型: " + type, GlobalUtil.LogLevel.DEBUG)
				
				# 特别检查strange_stone_pile的fixed状态
				if type == "strange_stone_pile":
					# 等待一帧确保装饰器管理器初始化完成
					# await card_instance.get_tree().process_frame
					# 给奇怪石堆添加事件标签（使用卡牌实例的add_tag方法）
					resource.add_tag("event_1")
					GlobalUtil.log("森林道路：给奇怪石堆添加了event_1标签", GlobalUtil.LogLevel.INFO)
					
					# 打印调试信息
					GlobalUtil.log("奇怪石堆fixed状态: " + str(resource.has_tag("fixed")), GlobalUtil.LogLevel.DEBUG)
					GlobalUtil.log("奇怪石堆所有标签: " + str(resource.get_tags()), GlobalUtil.LogLevel.DEBUG)
					GlobalUtil.log("奇怪石堆装饰器标签: " + str(resource.get_all_decorator_tags()), GlobalUtil.LogLevel.DEBUG)
			else:
				GlobalUtil.log("森林道路：" + type + "卡牌生成失败", GlobalUtil.LogLevel.WARNING)

# 森林道路卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func forest_road_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 森林道路卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 增加点击计数
	click_count += 1
	
	# 根据点击次数生成不同的卡牌
	match click_count:
		1:
			# 第一次点击生成旧木屋，在较近的位置
			var house_pos = get_valid_position(card_position, 200, 400)
			var house = CardUtil.create_card_from_pool(card_instance.get_tree().root, "old_wooden_house", card_position)
			CardUtil.move_card(house, house_pos)
			GlobalUtil.log("森林道路：生成了一座旧木屋，位置: " + str(house_pos), GlobalUtil.LogLevel.INFO)
		2:
			# 第二次点击生成向导之书，在较近的位置
			var book_pos = get_valid_position(card_position, 200, 400)
			var book = CardUtil.create_card_from_pool(card_instance.get_tree().root, "guide_book", card_position)
			CardUtil.move_card(book, book_pos)
			GlobalUtil.log("森林道路：生成了一本向导之书，位置: " + str(book_pos), GlobalUtil.LogLevel.INFO)
		3:
			# 第三次点击生成资源并启动定时器
			var event_util = card_instance.get_node("/root/EventUtil")
			if event_util:
				# 生成初始资源
				generate_initial_resources(card_instance)
				# 启动定时器
				event_util.start_timer()
				# 移除自身
				card_instance.queue_free()
				GlobalUtil.log("森林道路：生成初始资源并启动定时器，移除自身", GlobalUtil.LogLevel.INFO)
			else:
				GlobalUtil.log("森林道路：无法获取EventUtil单例", GlobalUtil.LogLevel.WARNING)