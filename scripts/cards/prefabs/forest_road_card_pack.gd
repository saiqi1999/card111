extends "res://scripts/cards/card_pack_base.gd"
# 森林道路卡包

# 引入必要的工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")
const EventUtil = preload("res://scripts/utils/event_util.gd")
const GlobalUtil = preload("res://scripts/utils/util.gd")
const GlobalConstants = preload("res://scripts/utils/global_constants.gd")

# 点击计数器
var click_count = 0

# 注释：已生成位置记录现在由CardUtil全局管理

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

# 注释：位置生成相关方法已移动到CardUtil中，现在使用CardUtil的静态方法

# 生成第五次点击的额外资源
func generate_fifth_click_extras(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	
	# 位置生成现在直接基于all_cards，无需手动清空位置记录
	
	# 生成木堆和石堆，使用pop_card_in_range进行生成后处理
	var extra_resources = ["wood_scraps", "stone_pile"]
	for type in extra_resources:
		var resource = CardUtil.create_card_from_pool(card_instance.get_tree().root, type, card_position)
		if resource:
			# 使用pop_card_in_range进行生成后处理，设置较远的距离范围
			StackUtil.pop_card_in_range(resource, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_FAR, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_FAR)
			GlobalUtil.log("森林道路：第五次点击生成了一张" + type + "卡牌，使用pop_card_in_range处理", GlobalUtil.LogLevel.INFO)
		else:
			GlobalUtil.log("森林道路：" + type + "卡牌生成失败", GlobalUtil.LogLevel.WARNING)
	
	# 在目前area右侧正中间位置生成奇怪石堆
	# 获取当前区域的右侧中间位置
	if AreaUtil:
		# 获取当前区域边界
		var current_bounds = AreaUtil.get_current_bounds()
		# 计算右侧正中间位置
		var right_center_pos = Vector2(current_bounds.position.x + current_bounds.size.x, current_bounds.position.y + current_bounds.size.y / 2)
		
		# 生成奇怪石堆
		var strange_stone = CardUtil.create_card_from_pool(card_instance.get_tree().root, "strange_stone_pile", card_position)
		if strange_stone:
			CardUtil.goto_card(strange_stone, right_center_pos)
			# 给奇怪石堆添加事件标签
			strange_stone.add_tag("event_1")
			GlobalUtil.log("森林道路：在右侧正中间生成了奇怪石堆，使用goto_card移动到位置: " + str(right_center_pos), GlobalUtil.LogLevel.INFO)
			GlobalUtil.log("森林道路：给奇怪石堆添加了event_1标签", GlobalUtil.LogLevel.INFO)
		else:
			GlobalUtil.log("森林道路：奇怪石堆生成失败", GlobalUtil.LogLevel.WARNING)
	else:
		GlobalUtil.log("森林道路：无法获取AreaUtil单例", GlobalUtil.LogLevel.WARNING)

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
			# 第一次点击生成木屋，在较近的位置
			var house = CardUtil.create_card_from_pool(card_instance.get_tree().root, "old_wooden_house", card_position)
			if house:
				# 使用pop_card_in_range进行生成后处理
				StackUtil.pop_card_in_range(house, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
				GlobalUtil.log("森林道路：第一次点击生成了一座木屋，使用pop_card_in_range处理", GlobalUtil.LogLevel.INFO)
			else:
				GlobalUtil.log("森林道路：木屋生成失败", GlobalUtil.LogLevel.WARNING)
		2:
			# 第二次点击生成燧石，在较近的位置
			var flint = CardUtil.create_card_from_pool(card_instance.get_tree().root, "flint", card_position)
			if flint:
				# 使用pop_card_in_range进行生成后处理
				StackUtil.pop_card_in_range(flint, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
				GlobalUtil.log("森林道路：第二次点击生成了燧石，使用pop_card_in_range处理", GlobalUtil.LogLevel.INFO)
			else:
				GlobalUtil.log("森林道路：燧石生成失败", GlobalUtil.LogLevel.WARNING)
		3:
			# 第三次点击生成燧石，在较近的位置
			var flint2 = CardUtil.create_card_from_pool(card_instance.get_tree().root, "flint", card_position)
			if flint2:
				# 使用pop_card_in_range进行生成后处理
				StackUtil.pop_card_in_range(flint2, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
				GlobalUtil.log("森林道路：第三次点击生成了燧石，使用pop_card_in_range处理", GlobalUtil.LogLevel.INFO)
			else:
				GlobalUtil.log("森林道路：燧石生成失败", GlobalUtil.LogLevel.WARNING)
		4:
			# 第四次点击生成木板，在较近的位置
			var wood = CardUtil.create_card_from_pool(card_instance.get_tree().root, "wood", card_position)
			if wood:
				# 使用pop_card_in_range进行生成后处理
				StackUtil.pop_card_in_range(wood, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
				GlobalUtil.log("森林道路：第四次点击生成了木板，使用pop_card_in_range处理", GlobalUtil.LogLevel.INFO)
			else:
				GlobalUtil.log("森林道路：木板生成失败", GlobalUtil.LogLevel.WARNING)
		5:
			# 第五次点击生成向导之书，在较近的位置
			var book = CardUtil.create_card_from_pool(card_instance.get_tree().root, "guide_book", card_position)
			if book:
				# 使用pop_card_in_range进行生成后处理
				StackUtil.pop_card_in_range(book, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
				GlobalUtil.log("森林道路：第五次点击生成了向导之书，使用pop_card_in_range处理", GlobalUtil.LogLevel.INFO)
			else:
				GlobalUtil.log("森林道路：向导之书生成失败", GlobalUtil.LogLevel.WARNING)
			
			# 第五次点击额外生成木堆、石堆和奇怪石堆
			generate_fifth_click_extras(card_instance)
			
			# 启动定时器
			var event_util = card_instance.get_node("/root/EventUtil")
			if event_util:
				event_util.start_timer()
				GlobalUtil.log("森林道路：启动定时器", GlobalUtil.LogLevel.INFO)
			else:
				GlobalUtil.log("森林道路：无法获取EventUtil单例", GlobalUtil.LogLevel.WARNING)
			
			# 移除自身
			card_instance.queue_free()
			GlobalUtil.log("森林道路：第五次点击完成，移除自身", GlobalUtil.LogLevel.INFO)
