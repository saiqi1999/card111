# 全局常量类
# 用于存储游戏中的全局常量配置
extends Resource
class_name GlobalConstants

# 卡牌池相关常量
const CARD_POOL_SIZE: int = 5  # 卡牌池大小
const CARD_POOL_HIDDEN_POSITION: Vector2 = Vector2(-1000, -1000)  # 卡牌池隐藏位置

# 日志系统相关常量
const DEFAULT_LOG_ENABLED: bool = true  # 默认日志开启状态
const LOG_PREFIX: String = "[CardGame]"  # 日志前缀

# 卡牌相关常量
const CARD_WIDTH: float = 200.0  # 卡牌宽度
const CARD_HEIGHT: float = 300.0  # 卡牌高度
const CARD_DRAG_ALPHA: float = 0.5  # 拖拽时的透明度
const CARD_NORMAL_ALPHA: float = 1.0  # 卡牌正常透明度

# 动画相关常量
const DEFAULT_MOVE_DURATION: float = 0.65  # 默认移动动画时长
const SLIDE_DURATION: float = 2.0  # 滑动动画时长

# 随机移动相关常量
const RANDOM_MOVE_RANGE: int = 300  # 随机移动范围
const CENTER_AVOID_RANGE: int = 150  # 中心避让范围

# 屏幕相关常量
const SCREEN_CENTER: Vector2 = Vector2(960, 540)  # 屏幕中心位置
const SCREEN_LEFT_OUTSIDE: Vector2 = Vector2(-200, 540)  # 屏幕左侧外部位置

# 重叠测试相关常量
const OVERLAP_TEST_COUNT: int = 5  # 重叠测试卡牌数量
const OVERLAP_OFFSET: Vector2 = Vector2(20, 15)  # 重叠偏移量

# 拖拽相关常量
const DRAG_THRESHOLD: float = 10.0  # 拖动距离阈值（像素）

# 容器相关常量
const CONTAINER_WIDTH: float = 400.0  # 容器宽度（翻倍）
const CONTAINER_HEIGHT: float = 300.0  # 容器高度（翻倍）

# 获取所有常量的字典表示（用于调试）
static func get_all_constants() -> Dictionary:
	return {
		"CARD_POOL_SIZE": CARD_POOL_SIZE,
		"CARD_POOL_HIDDEN_POSITION": CARD_POOL_HIDDEN_POSITION,
		"DEFAULT_LOG_ENABLED": DEFAULT_LOG_ENABLED,
		"LOG_PREFIX": LOG_PREFIX,
		"CARD_WIDTH": CARD_WIDTH,
		"CARD_HEIGHT": CARD_HEIGHT,
		"CARD_DRAG_ALPHA": CARD_DRAG_ALPHA,
		"CARD_NORMAL_ALPHA": CARD_NORMAL_ALPHA,
		"DEFAULT_MOVE_DURATION": DEFAULT_MOVE_DURATION,
		"SLIDE_DURATION": SLIDE_DURATION,
		"RANDOM_MOVE_RANGE": RANDOM_MOVE_RANGE,
		"CENTER_AVOID_RANGE": CENTER_AVOID_RANGE,
		"SCREEN_CENTER": SCREEN_CENTER,
		"SCREEN_LEFT_OUTSIDE": SCREEN_LEFT_OUTSIDE,
		"OVERLAP_TEST_COUNT": OVERLAP_TEST_COUNT,
		"OVERLAP_OFFSET": OVERLAP_OFFSET,
		"DRAG_THRESHOLD": DRAG_THRESHOLD,
		"CONTAINER_WIDTH": CONTAINER_WIDTH,
		"CONTAINER_HEIGHT": CONTAINER_HEIGHT
	}

# 打印所有常量（用于调试）
static func print_all_constants():
	var constants = get_all_constants()
	print("=== 全局常量列表 ===")
	for key in constants.keys():
		print(key + ": " + str(constants[key]))
