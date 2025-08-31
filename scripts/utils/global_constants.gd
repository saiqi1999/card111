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
const RANDOM_MOVE_RANGE: int = 500  # 随机移动范围
const CENTER_AVOID_RANGE: int = 350  # 中心避让范围

# 屏幕相关常量
const SCREEN_CENTER: Vector2 = Vector2(960, 540)  # 屏幕中心位置
const SCREEN_LEFT_OUTSIDE: Vector2 = Vector2(-200, 540)  # 屏幕左侧外部位置

# 重叠测试相关常量
const OVERLAP_TEST_COUNT: int = 5  # 重叠测试卡牌数量
const OVERLAP_OFFSET: Vector2 = Vector2(20, 15)  # 重叠偏移量

# 拖拽相关常量
const DRAG_THRESHOLD: float = 10.0  # 拖动距离阈值（像素）

# 卡牌堆叠相关常量
const CARD_STACK_OFFSET_RATIO: float = 0.06  # 堆叠偏移比例（相对于卡牌长度）
const CARD_STACK_OFFSET: float = CARD_HEIGHT * CARD_STACK_OFFSET_RATIO  # 堆叠偏移量（18像素）
const CARD_STACK_DETECTION_RANGE: float = 0.8 * CARD_WIDTH  # 堆叠检测范围（像素）

# 控制器相关常量
const CTRL_UNIT: float = 100.0  # 控制器基础单位
const CTRL_WIDTH_RATIO: float = 4.0  # 控制器宽度比例
const CTRL_HEIGHT_RATIO: float = 3.0  # 控制器高度比例
const CTRL_WIDTH: float = CTRL_UNIT * CTRL_WIDTH_RATIO  # 控制器宽度（400）
const CTRL_HEIGHT: float = CTRL_UNIT * CTRL_HEIGHT_RATIO  # 控制器高度（300）

# 配方合成相关常量
const DEFAULT_CRAFT_TIME: float = 5.0  # 默认合成时间（秒）
const RECIPE_CHECK_INTERVAL: float = 0.1  # 合成进度检查间隔（秒）

# 小控制器UI布局常量
const CTRL_MARGIN: float = 100.0  # 控制器边缘距离
const CTRL_SIZE_RATIO: float = 1.0 / 3.0  # 控制器占屏幕的比例（三分之一）

# UI布局相关常量
const UI_UNIT: float = 20.0  # UI基础单位
const UI_BUTTON_WIDTH: float = UI_UNIT * 6.0  # 按钮宽度（120）
const UI_BUTTON_HEIGHT: float = UI_UNIT * 2.0  # 按钮高度（40）
const UI_CARD_SLOT_WIDTH: float = UI_UNIT * 4.0  # 卡槽宽度（80）
const UI_CARD_SLOT_HEIGHT: float = UI_UNIT * 6.0  # 卡槽高度（120）
const UI_SPACING_SMALL: float = UI_UNIT * 0.5  # 小间距（10）
const UI_SPACING_MEDIUM: float = UI_UNIT * 1.0  # 中间距（20）
const UI_SPACING_LARGE: float = UI_UNIT * 2.0  # 大间距（40）
const UI_TITLE_FONT_SIZE: int = 24  # 标题字体大小
const UI_NORMAL_FONT_SIZE: int = 16  # 普通字体大小

# 控制器层级常量
const CTRL_Z_INDEX: int = 1000  # 控制器基础z_index
const CTRL_UI_Z_INDEX: int = 1020  # 控制器UI元素z_index
const CTRL_TITLE_Z_INDEX: int = 1015  # 控制器标题z_index

# 相机相关常量
const CAMERA_ZOOM_MIN: float = 0.5  # 相机最小缩放
const CAMERA_ZOOM_MAX: float = 3.0  # 相机最大缩放
const CAMERA_ZOOM_SPEED: float = 0.1  # 相机缩放速度
const CAMERA_DRAG_SPEED: float = 1.0  # 相机拖拽速度

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
		"CARD_STACK_OFFSET_RATIO": CARD_STACK_OFFSET_RATIO,
		"CARD_STACK_OFFSET": CARD_STACK_OFFSET,
		"CARD_STACK_DETECTION_RANGE": CARD_STACK_DETECTION_RANGE,
		"CTRL_UNIT": CTRL_UNIT,
		"CTRL_WIDTH_RATIO": CTRL_WIDTH_RATIO,
		"CTRL_HEIGHT_RATIO": CTRL_HEIGHT_RATIO,
		"CTRL_WIDTH": CTRL_WIDTH,
		"CTRL_HEIGHT": CTRL_HEIGHT,
		"CTRL_MARGIN": CTRL_MARGIN,
		"CTRL_SIZE_RATIO": CTRL_SIZE_RATIO,
		"UI_UNIT": UI_UNIT,
		"UI_BUTTON_WIDTH": UI_BUTTON_WIDTH,
		"UI_BUTTON_HEIGHT": UI_BUTTON_HEIGHT,
		"UI_CARD_SLOT_WIDTH": UI_CARD_SLOT_WIDTH,
		"UI_CARD_SLOT_HEIGHT": UI_CARD_SLOT_HEIGHT,
		"UI_SPACING_SMALL": UI_SPACING_SMALL,
		"UI_SPACING_MEDIUM": UI_SPACING_MEDIUM,
		"UI_SPACING_LARGE": UI_SPACING_LARGE,
		"UI_TITLE_FONT_SIZE": UI_TITLE_FONT_SIZE,
		"UI_NORMAL_FONT_SIZE": UI_NORMAL_FONT_SIZE,
		"CTRL_Z_INDEX": CTRL_Z_INDEX,
		"CTRL_UI_Z_INDEX": CTRL_UI_Z_INDEX,
		"CTRL_TITLE_Z_INDEX": CTRL_TITLE_Z_INDEX
	}

# 打印所有常量（用于调试）
static func print_all_constants():
	var constants = get_all_constants()
	print("=== 全局常量列表 ===")
	for key in constants.keys():
		print(key + ": " + str(constants[key]))
