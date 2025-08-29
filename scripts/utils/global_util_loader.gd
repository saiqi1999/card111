extends Node

# 全局工具加载器，负责初始化和管理全局工具实例

# 预加载全局工具类和常量类
const GlobalUtilClass = preload("res://scripts/utils/util.gd")
const GlobalConstantsClass = preload("res://scripts/utils/global_constants.gd")

# 全局工具实例
var global_util: GlobalUtilClass

func _ready() -> void:
	# 创建全局工具实例
	global_util = GlobalUtilClass.new()
	
	# 将全局常量类注册为单例
	Engine.register_singleton("GlobalConstants", GlobalConstantsClass)
	
	# 将全局工具实例添加为自动加载单例
	Engine.register_singleton("GlobalUtil", global_util)
	
	# 使用全局常量初始化日志状态
	GlobalUtil.set_log_enabled(GlobalConstantsClass.DEFAULT_LOG_ENABLED)
	
	# 输出调试信息
	GlobalUtil.log("全局工具已加载", GlobalUtil.LogLevel.INFO)
	
	# 初始化屏幕分辨率
	GlobalUtil.update_screen_size_from_viewport(get_viewport())
	
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
	
	# 移除全局常量单例
	if Engine.has_singleton("GlobalConstants"):
		Engine.unregister_singleton("GlobalConstants")
