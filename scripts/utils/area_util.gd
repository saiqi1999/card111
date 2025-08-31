extends Node

# 区域管理工具类
# 用于管理相机和卡牌的移动范围

# 默认移动范围（使用全局常量）
static var camera_move_bounds: Rect2 = Rect2(
	GlobalConstants.CAMERA_MOVE_BOUNDS_MIN,
	GlobalConstants.CAMERA_MOVE_BOUNDS_SIZE
)

static var card_move_bounds: Rect2 = Rect2(
	GlobalConstants.CARD_MOVE_BOUNDS_MIN,
	GlobalConstants.CARD_MOVE_BOUNDS_SIZE
)

func _ready():
	GlobalUtil.log("区域管理工具初始化完成", GlobalUtil.LogLevel.DEBUG)

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

# 获取区域信息（用于调试）
static func get_area_info() -> Dictionary:
	return {
		"camera_bounds": camera_move_bounds,
		"card_bounds": card_move_bounds
	}
