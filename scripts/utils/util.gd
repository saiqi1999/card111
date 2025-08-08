extends Node

# 全局工具类，提供通用功能
class_name GlobalUtil

# 显示调试信息
func debug_log(message: String) -> void:
	print("[DEBUG] " + message)

# 获取当前时间戳
func get_timestamp() -> int:
	return Time.get_unix_time_from_system()

# 生成随机整数（包含min和max）
func random_int(min_value: int, max_value: int) -> int:
	return randi() % (max_value - min_value + 1) + min_value

# 计算两点之间的距离
func calculate_distance(point1: Vector2, point2: Vector2) -> float:
	return point1.distance_to(point2)

# 格式化时间（秒转为分:秒格式）
func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var remaining_seconds = seconds % 60
	return "%d:%02d" % [minutes, remaining_seconds]