extends Node

# 游戏事件管理工具
# 负责处理游戏中的各种事件，包括游戏开始时的初始化事件

# 引入必要的工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")
const GlobalUtil = preload("res://scripts/utils/util.gd")
const GlobalConstants = preload("res://scripts/utils/global_constants.gd")

# 定时器
var event_timer: Timer = null

# 定时器间隔（2分钟）
const TIMER_INTERVAL = 120.0

# 天气卡牌类型
const WEATHER_CARDS = ["wind", "rain"]

# 在游戏开始时调用
func _ready():
	# 等待一帧以确保其他系统已经初始化
	await get_tree().create_timer(0.1).timeout
	
	# 在屏幕中央生成森林道路卡牌
	var target_position = GlobalConstants.SCREEN_CENTER
	
	# 确保卡牌池已初始化
	CardUtil.initialize_card_pool(get_tree().root)
	
	# 创建森林道路卡牌
	var card_instance = CardUtil.create_card_from_pool(get_tree().root, "forest_road", target_position)
	if card_instance:
		GlobalUtil.log("游戏开始：在屏幕中央生成了一张森林道路卡牌", GlobalUtil.LogLevel.INFO)
	else:
		GlobalUtil.log("游戏开始：森林道路卡牌生成失败", GlobalUtil.LogLevel.WARNING)

# 启动定时器
func start_timer():
	if event_timer == null:
		event_timer = Timer.new()
		event_timer.wait_time = TIMER_INTERVAL
		event_timer.one_shot = false
		event_timer.timeout.connect(_on_timer_timeout)
		add_child(event_timer)
		GlobalUtil.log("事件定时器已启动，间隔：" + str(TIMER_INTERVAL) + "秒", GlobalUtil.LogLevel.INFO)
		event_timer.start()

# 定时器超时回调
func _on_timer_timeout():
	GlobalUtil.log("事件定时器触发", GlobalUtil.LogLevel.INFO)
	
	# 30%概率生成天气卡牌
	if randf() <= 0.3:
		# 随机选择天气类型
		var weather_type = WEATHER_CARDS[randi() % WEATHER_CARDS.size()]
		
		# 随机生成位置（屏幕范围内）
		var random_x = randf_range(100, get_viewport().size.x - 100)
		var random_y = randf_range(100, get_viewport().size.y - 100)
		var random_position = Vector2(random_x, random_y)
		
		# 创建天气卡牌
		var card_instance = CardUtil.create_card_from_pool(get_tree().root, weather_type, random_position)
		if card_instance:
			GlobalUtil.log("生成天气卡牌：" + weather_type, GlobalUtil.LogLevel.INFO)
			
			# 随机移动卡牌
			await get_tree().create_timer(0.5).timeout
			var move_x = randf_range(-100, 100)
			var move_y = randf_range(-100, 100)
			var target_position = random_position + Vector2(move_x, move_y)
			CardUtil.move_card(card_instance, target_position)
			GlobalUtil.log("天气卡牌移动到：" + str(target_position), GlobalUtil.LogLevel.INFO)
		else:
			GlobalUtil.log("天气卡牌生成失败：" + weather_type, GlobalUtil.LogLevel.WARNING)

# 触发指定ID的事件
func trigger_event(event_id: int):
	GlobalUtil.log("触发事件ID: " + str(event_id), GlobalUtil.LogLevel.INFO)
	
	match event_id:
		1:
			# 事件1：移除右边(0,1)位置的遮罩层并在扩展区域生成卡牌
			var area_util = get_node("/root/AreaUtil")
			if area_util:
				area_util.set_fog_visible(1, 0, false)
				GlobalUtil.log("事件1执行：移除右边(1,0)位置的遮罩层", GlobalUtil.LogLevel.INFO)
				
				# 在扩展的地块内生成卡牌
				generate_cards_in_expanded_area()
			else:
				GlobalUtil.log("未找到AreaUtil节点，无法执行事件1", GlobalUtil.LogLevel.WARNING)
		_:
			GlobalUtil.log("未知事件ID: " + str(event_id), GlobalUtil.LogLevel.WARNING)

# 在扩展区域生成卡牌
func generate_cards_in_expanded_area():
	# 获取扩展区域的边界
	var area_util = get_node("/root/AreaUtil")
	if not area_util:
		GlobalUtil.log("未找到AreaUtil节点，无法生成扩展区域卡牌", GlobalUtil.LogLevel.WARNING)
		return
	
	# 获取当前区域边界
	var current_bounds = area_util.get_current_bounds()
	# 计算扩展区域（右侧区域）
	var expanded_area_min = Vector2(current_bounds.position.x + current_bounds.size.x * 0.5, current_bounds.position.y)
	var expanded_area_max = Vector2(current_bounds.position.x + current_bounds.size.x * 1, current_bounds.position.y + current_bounds.size.y)
	
	GlobalUtil.log("扩展区域范围: " + str(expanded_area_min) + " 到 " + str(expanded_area_max), GlobalUtil.LogLevel.INFO)
	
	# 定义要生成的卡牌类型和数量
	var cards_to_generate = [
		{"type": "large_blueberry_bush", "count": 1},
		{"type": "small_blueberry_bush", "count": 2},
		{"type": "stone_pile", "count": 2},
		{"type": "dirt_pile", "count": 1}
	]
	
	# 生成6个随机有效位置
	var valid_positions = []
	var max_attempts = 50  # 最大尝试次数
	var min_spacing = 500.0  # 卡牌之间的最小间距
	
	for i in range(6):
		var attempts = 0
		var valid_pos = Vector2.ZERO
		
		while attempts < max_attempts:
			# 在扩展区域内生成随机位置
			var random_x = randf_range(expanded_area_min.x, expanded_area_max.x)
			var random_y = randf_range(expanded_area_min.y, expanded_area_max.y)
			var test_pos = Vector2(random_x, random_y)
			
			# 使用CardUtil检查位置是否有效（不与现有卡牌重叠）
			if not CardUtil.is_position_overlapping(test_pos, min_spacing):
				# 检查与已选择位置的距离
				var too_close = false
				for existing_pos in valid_positions:
					if test_pos.distance_to(existing_pos) < min_spacing:
						too_close = true
						break
				
				if not too_close:
					valid_pos = test_pos
					break
			
			attempts += 1
		
		# 如果找不到完美位置，使用最后一次尝试的位置
		if valid_pos == Vector2.ZERO:
			valid_pos = Vector2(
				randf_range(expanded_area_min.x, expanded_area_max.x),
				randf_range(expanded_area_min.y, expanded_area_max.y)
			)
		
		valid_positions.append(valid_pos)
		GlobalUtil.log("生成有效位置 " + str(i + 1) + ": " + str(valid_pos), GlobalUtil.LogLevel.DEBUG)
	
	# 按照卡牌类型和数量分配位置并生成卡牌
	var position_index = 0
	for card_info in cards_to_generate:
		var card_type = card_info["type"]
		var count = card_info["count"]
		
		for i in range(count):
			if position_index >= valid_positions.size():
				GlobalUtil.log("位置不足，无法生成更多卡牌", GlobalUtil.LogLevel.WARNING)
				break
			
			var spawn_position = valid_positions[position_index]
			
			# 创建卡牌
			var card_instance = CardUtil.create_card_from_pool(get_tree().root, card_type, spawn_position)
			if card_instance:
				# 使用goto方法将卡牌移动到目标位置
				CardUtil.goto_card(card_instance, spawn_position)
				GlobalUtil.log("事件1：在扩展区域生成了 " + card_type + " 卡牌，位置: " + str(spawn_position), GlobalUtil.LogLevel.INFO)
			else:
				GlobalUtil.log("事件1：" + card_type + " 卡牌生成失败", GlobalUtil.LogLevel.WARNING)
			
			position_index += 1
	
	GlobalUtil.log("事件1：扩展区域卡牌生成完成，共生成 " + str(position_index) + " 张卡牌", GlobalUtil.LogLevel.INFO)
