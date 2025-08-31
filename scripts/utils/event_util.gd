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
