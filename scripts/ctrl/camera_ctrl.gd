extends Camera2D
class_name CameraCtrl

# 相机控制器类
# 提供可拖拽和缩放的2D相机功能，服务于root节点

# 预加载工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")
const AreaUtil = preload("res://scripts/utils/area_util.gd")

# 拖拽相关变量
var is_dragging: bool = false
var drag_start_position: Vector2 = Vector2.ZERO
var camera_start_position: Vector2 = Vector2.ZERO

# 缩放相关变量
var current_zoom: Vector2 = Vector2.ONE

func _ready():
	# 设置相机为当前活动相机
	enabled = true
	
	# 初始化缩放
	current_zoom = Vector2.ONE
	zoom = current_zoom
	
	# 设置相机位置为屏幕中心
	position = GlobalConstants.SCREEN_CENTER
	
	GlobalUtil.log("相机控制器初始化完成，位置: " + str(position) + ", 缩放: " + str(zoom), GlobalUtil.LogLevel.DEBUG)

func _input(event):
	# 处理鼠标左键拖拽
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 检查鼠标位置是否有卡牌，如果有卡牌则不进行相机拖拽
				if not is_mouse_over_card():
					# 开始拖拽
					start_dragging(event.position)
			else:
				# 结束拖拽
				stop_dragging()
				
		# 处理滚轮缩放
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()
			
	# 处理鼠标移动（拖拽时）
	elif event is InputEventMouseMotion and is_dragging:
		update_camera_position(event.position)

# 开始拖拽
func start_dragging(mouse_pos: Vector2):
	is_dragging = true
	drag_start_position = mouse_pos
	camera_start_position = position
	GlobalUtil.log("开始拖拽相机，鼠标位置: " + str(mouse_pos), GlobalUtil.LogLevel.DEBUG)

# 停止拖拽
func stop_dragging():
	is_dragging = false
	GlobalUtil.log("停止拖拽相机", GlobalUtil.LogLevel.DEBUG)

# 更新相机位置（拖拽时）
func update_camera_position(current_mouse_pos: Vector2):
	if not is_dragging:
		return
		
	# 计算鼠标移动的偏移量
	var mouse_delta = current_mouse_pos - drag_start_position
	
	# 根据当前缩放调整移动速度（缩放越大，移动越慢）
	var adjusted_delta = mouse_delta * GlobalConstants.CAMERA_DRAG_SPEED / current_zoom.x
	
	# 计算新位置（注意方向相反，因为相机移动与视野移动方向相反）
	var new_position = camera_start_position - adjusted_delta
	
	# 使用AreaUtil限制相机位置在允许范围内
	position = AreaUtil.clamp_camera_position(new_position)

# 放大
func zoom_in():
	var new_zoom = current_zoom + Vector2(GlobalConstants.CAMERA_ZOOM_SPEED, GlobalConstants.CAMERA_ZOOM_SPEED)
	
	# 限制最大缩放
	if new_zoom.x <= GlobalConstants.CAMERA_ZOOM_MAX:
		current_zoom = new_zoom
		zoom = current_zoom
		GlobalUtil.log("相机放大，当前缩放: " + str(current_zoom), GlobalUtil.LogLevel.DEBUG)

# 缩小
func zoom_out():
	var new_zoom = current_zoom - Vector2(GlobalConstants.CAMERA_ZOOM_SPEED, GlobalConstants.CAMERA_ZOOM_SPEED)
	
	# 限制最小缩放
	if new_zoom.x >= GlobalConstants.CAMERA_ZOOM_MIN:
		current_zoom = new_zoom
		zoom = current_zoom
		GlobalUtil.log("相机缩小，当前缩放: " + str(current_zoom), GlobalUtil.LogLevel.DEBUG)

# 重置相机位置和缩放
func reset_camera():
	position = GlobalConstants.SCREEN_CENTER
	current_zoom = Vector2.ONE
	zoom = current_zoom
	GlobalUtil.log("重置相机位置和缩放", GlobalUtil.LogLevel.INFO)

# 检查鼠标位置是否有卡牌
func is_mouse_over_card() -> bool:
	# 获取全局鼠标位置
	var mouse_pos = get_global_mouse_position()
	
	# 检查是否有卡牌在鼠标位置
	for card in CardUtil.all_cards:
		if card == null or not is_instance_valid(card):
			continue
			
		# 检查鼠标是否在卡牌范围内
		var card_rect = Rect2(
			card.global_position - Vector2(CardUtil.CARD_WIDTH/2, CardUtil.CARD_HEIGHT/2),
			Vector2(CardUtil.CARD_WIDTH, CardUtil.CARD_HEIGHT)
		)
		
		if card_rect.has_point(mouse_pos):
			GlobalUtil.log("检测到鼠标位置有卡牌，不进行相机拖拽", GlobalUtil.LogLevel.DEBUG)
			return true
	
	return false

# 设置相机位置
func set_camera_position(new_position: Vector2):
	position = new_position
	GlobalUtil.log("设置相机位置: " + str(new_position), GlobalUtil.LogLevel.DEBUG)

# 设置相机缩放
func set_camera_zoom(new_zoom: float):
	# 限制缩放范围
	new_zoom = clamp(new_zoom, GlobalConstants.CAMERA_ZOOM_MIN, GlobalConstants.CAMERA_ZOOM_MAX)
	current_zoom = Vector2(new_zoom, new_zoom)
	zoom = current_zoom
	GlobalUtil.log("设置相机缩放: " + str(new_zoom), GlobalUtil.LogLevel.DEBUG)

# 获取当前缩放值
func get_camera_zoom() -> float:
	return current_zoom.x

# 获取相机信息（用于调试）
func get_camera_info() -> Dictionary:
	return {
		"position": position,
		"zoom": current_zoom,
		"is_dragging": is_dragging,
		"is_current": enabled
	}
