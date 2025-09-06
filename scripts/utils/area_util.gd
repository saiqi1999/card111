extends Node

# 区域管理工具类
# 用于管理相机和卡牌的移动范围，以及遮罩层

# 默认移动范围（使用全局常量）
static var camera_move_bounds: Rect2 = Rect2(
	GlobalConstants.CAMERA_MOVE_BOUNDS_MIN,
	GlobalConstants.CAMERA_MOVE_BOUNDS_SIZE
)

static var card_move_bounds: Rect2 = Rect2(
	GlobalConstants.CARD_MOVE_BOUNDS_MIN,
	GlobalConstants.CARD_MOVE_BOUNDS_SIZE
)

# 遮罩层字典，使用二维坐标作为键
var fog_layers: Dictionary = {}

func _ready():
	# 初始化遮罩层
	_init_fog_layers()
	GlobalUtil.log("区域管理工具初始化完成", GlobalUtil.LogLevel.DEBUG)

# 初始化遮罩层
func _init_fog_layers():
	# 创建 5x5 的遮罩层网格，范围从 (-2,-2) 到 (2,2)
	for grid_y in range(-2, 3):  # -2 到 2
		for grid_x in range(-2, 3):  # -2 到 2
			var layer = _create_fog_layer(grid_x, grid_y)
			# 设置初始可见性：只有 (0,0) 位置不可见，其他位置都可见
			layer.visible = !(grid_x == 0 && grid_y == 0)
	
	GlobalUtil.log("5x5遮罩层网格初始化完成", GlobalUtil.LogLevel.DEBUG)

# 创建单个遮罩层
func _create_fog_layer(grid_x: int, grid_y: int) -> ColorRect:
	var layer = ColorRect.new()
	layer.color = GlobalConstants.FOG_LAYER_COLOR
	layer.size = GlobalConstants.FOG_GRID_SIZE
	layer.position = GlobalConstants.get_fog_grid_position(grid_x, grid_y)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 忽略鼠标事件
	add_child(layer)
	
	# 将遮罩层添加到字典中
	var grid_key = Vector2i(grid_x, grid_y)
	fog_layers[grid_key] = layer
	
	return layer

# 设置指定坐标遮罩层的可见性
func set_fog_visible(grid_x: int, grid_y: int, visible: bool):
	var grid_key = Vector2i(grid_x, grid_y)
	if fog_layers.has(grid_key):
		fog_layers[grid_key].visible = visible
		GlobalUtil.log("设置遮罩层(%d,%d)可见性: %s" % [grid_x, grid_y, visible], GlobalUtil.LogLevel.DEBUG)
		
		# 当打开遮罩层（设置为不可见）时，扩展移动边界
		if not visible:
			_expand_bounds_for_fog_opening(grid_x, grid_y)

# 获取指定坐标的遮罩层
func get_fog_layer(grid_x: int, grid_y: int) -> ColorRect:
	var grid_key = Vector2i(grid_x, grid_y)
	if fog_layers.has(grid_key):
		return fog_layers[grid_key]
	return null

# 设置相机移动范围
static func set_camera_bounds(bounds: Rect2):
	camera_move_bounds = bounds
	GlobalUtil.log("设置相机移动范围: " + str(bounds), GlobalUtil.LogLevel.DEBUG)

# 获取相机移动范围
static func get_camera_bounds() -> Rect2:
	return camera_move_bounds

# 设置卡牌移动范围
static func set_card_bounds(bounds: Rect2):
	card_move_bounds = bounds
	GlobalUtil.log("设置卡牌移动范围: " + str(bounds), GlobalUtil.LogLevel.DEBUG)

# 获取卡牌移动范围
static func get_card_bounds() -> Rect2:
	return card_move_bounds

# 检查并限制相机位置在允许范围内
static func clamp_camera_position(position: Vector2) -> Vector2:
	return Vector2(
		clamp(position.x, camera_move_bounds.position.x, camera_move_bounds.end.x),
		clamp(position.y, camera_move_bounds.position.y, camera_move_bounds.end.y)
	)

# 检查并限制卡牌位置在允许范围内
static func clamp_card_position(position: Vector2) -> Vector2:
	return Vector2(
		clamp(position.x, card_move_bounds.position.x, card_move_bounds.end.x),
		clamp(position.y, card_move_bounds.position.y, card_move_bounds.end.y)
	)

# 重置移动范围为默认值
static func reset_bounds():
	camera_move_bounds = Rect2(
		GlobalConstants.CAMERA_MOVE_BOUNDS_MIN,
		GlobalConstants.CAMERA_MOVE_BOUNDS_SIZE
	)
	card_move_bounds = Rect2(
		GlobalConstants.CARD_MOVE_BOUNDS_MIN,
		GlobalConstants.CARD_MOVE_BOUNDS_SIZE
	)
	GlobalUtil.log("重置移动范围为默认值", GlobalUtil.LogLevel.DEBUG)

# 根据打开的遮罩层扩展移动边界
func _expand_bounds_for_fog_opening(grid_x: int, grid_y: int):
	# 计算新区域的边界
	var fog_position = GlobalConstants.get_fog_grid_position(grid_x, grid_y)
	var fog_size = GlobalConstants.FOG_GRID_SIZE
	
	# 扩展卡牌移动边界
	var new_card_min_x = min(card_move_bounds.position.x, fog_position.x)
	var new_card_min_y = min(card_move_bounds.position.y, fog_position.y)
	var new_card_max_x = max(card_move_bounds.end.x, fog_position.x + fog_size.x)
	var new_card_max_y = max(card_move_bounds.end.y, fog_position.y + fog_size.y)
	
	card_move_bounds = Rect2(
		Vector2(new_card_min_x, new_card_min_y + GlobalConstants.CARD_HEIGHT/2),
		Vector2(new_card_max_x - new_card_min_x - GlobalConstants.CARD_WIDTH/2, new_card_max_y - new_card_min_y - GlobalConstants.CARD_HEIGHT)
	)
	
	# 扩展相机移动边界
	var new_camera_min_x = min(camera_move_bounds.position.x, fog_position.x)
	var new_camera_min_y = min(camera_move_bounds.position.y, fog_position.y)
	var new_camera_max_x = max(camera_move_bounds.end.x, fog_position.x + fog_size.x)
	var new_camera_max_y = max(camera_move_bounds.end.y, fog_position.y + fog_size.y)
	
	camera_move_bounds = Rect2(
		Vector2(new_camera_min_x, new_camera_min_y),
		Vector2(new_camera_max_x - new_camera_min_x, new_camera_max_y - new_camera_min_y)
	)
	
	GlobalUtil.log("扩展移动边界 - 卡牌: %s, 相机: %s" % [card_move_bounds, camera_move_bounds], GlobalUtil.LogLevel.DEBUG)

# 获取当前区域边界（返回卡牌移动边界）
static func get_current_bounds() -> Rect2:
	return card_move_bounds

# 获取区域信息（用于调试）
static func get_area_info() -> Dictionary:
	return {
		"camera_bounds": camera_move_bounds,
		"card_bounds": card_move_bounds
	}
