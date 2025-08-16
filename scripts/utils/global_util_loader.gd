extends Node

# 全局工具加载器，负责初始化和管理全局工具实例

# 预加载全局工具类
const GlobalUtilClass = preload("res://scripts/utils/util.gd")

# 全局工具实例
var global_util: GlobalUtilClass

func _ready() -> void:
	# 创建全局工具实例
	global_util = GlobalUtilClass.new()
	
	# 将全局工具实例添加为自动加载单例
	Engine.register_singleton("GlobalUtil", global_util)
	
	# 输出调试信息
	GlobalUtil.log("全局工具已加载", GlobalUtil.LogLevel.INFO)
	
	# 测试全局工具方法
	var current_time = global_util.get_timestamp()
	GlobalUtil.log("当前时间戳: " + str(current_time), GlobalUtil.LogLevel.DEBUG)
	
	var random_number = global_util.random_int(1, 100)
	GlobalUtil.log("随机数(1-100): " + str(random_number), GlobalUtil.LogLevel.DEBUG)

# 当场景树退出时清理资源
func _exit_tree() -> void:
	# 移除全局工具单例
	if Engine.has_singleton("GlobalUtil"):
		GlobalUtil.log("全局工具已卸载", GlobalUtil.LogLevel.INFO)
		Engine.unregister_singleton("GlobalUtil")