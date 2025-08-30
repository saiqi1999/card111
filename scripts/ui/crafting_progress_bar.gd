extends Control
class_name CraftingProgressBar

# 进度条相关变量
var progress_value: float = 0.0  # 当前进度值 (0.0 - 1.0)
var is_visible: bool = false  # 是否显示进度条
var target_width: float = 0.0  # 目标宽度（卡牌宽度）

# 进度条样式
var bar_height: float = 4.0  # 进度条高度
var bar_color: Color = Color.WHITE  # 进度条颜色
var background_color: Color = Color(0.3, 0.3, 0.3, 0.5)  # 背景颜色

# 初始化
func _ready():
	# 设置进度条的基本属性
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size = Vector2(0, bar_height)
	visible = false
	
	GlobalUtil.log("合成进度条初始化完成", GlobalUtil.LogLevel.DEBUG)

# 绘制进度条
func _draw():
	if not is_visible or target_width <= 0:
		return
	
	# 绘制背景
	var background_rect = Rect2(Vector2.ZERO, Vector2(target_width, bar_height))
	draw_rect(background_rect, background_color)
	
	# 绘制进度条
	var progress_width = target_width * progress_value
	if progress_width > 0:
		var progress_rect = Rect2(Vector2.ZERO, Vector2(progress_width, bar_height))
		draw_rect(progress_rect, bar_color)

# 显示进度条
func show_progress_bar(card_width: float):
	target_width = card_width
	is_visible = true
	visible = true
	size = Vector2(target_width, bar_height)
	queue_redraw()
	
	GlobalUtil.log("显示合成进度条，宽度: " + str(target_width), GlobalUtil.LogLevel.DEBUG)

# 隐藏进度条
func hide_progress_bar():
	is_visible = false
	visible = false
	progress_value = 0.0
	queue_redraw()
	
	GlobalUtil.log("隐藏合成进度条", GlobalUtil.LogLevel.DEBUG)

# 更新进度
func update_progress(new_progress: float):
	progress_value = clamp(new_progress, 0.0, 1.0)
	queue_redraw()
	
	# 当进度达到100%时，延迟隐藏进度条
	if progress_value >= 1.0:
		var timer = Timer.new()
		timer.wait_time = 0.2  # 延迟0.2秒后隐藏
		timer.one_shot = true
		timer.timeout.connect(_on_complete_delay_finished.bind(timer))
		add_child(timer)
		timer.start()

# 完成延迟后隐藏进度条
func _on_complete_delay_finished(timer: Timer):
	timer.queue_free()
	hide_progress_bar()

# 设置进度条位置（在堆叠下方）
func set_position_below_stack(stack_position: Vector2, stack_height: float):
	# 计算偏移：向左移动半个卡牌宽度，向上移动半个卡牌高度
	var card_width_half = GlobalConstants.CARD_WIDTH / 2.0
	var card_height_half = GlobalConstants.CARD_HEIGHT / 2.0
	
	var progress_bar_position = Vector2(
		stack_position.x - card_width_half,  # 向左移动半个卡牌宽度
		stack_position.y + stack_height + 5.0 - card_height_half  # 向上移动半个卡牌高度
	)
	position = progress_bar_position
	
	GlobalUtil.log("设置进度条位置: " + str(progress_bar_position), GlobalUtil.LogLevel.DEBUG)