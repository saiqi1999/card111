extends Control
class_name CtrlUtil

# 控制器工具类（Control节点实现）
# 用于管理和显示控制器

# 引用控制器基类
const CtrlBase = preload("res://scripts/ctrl/ctrl_base.gd")
const Ctrl400x300Pack = preload("res://scripts/ctrl/prefabs/ctrl_400_300.gd")

# 控制器实例的静态管理
static var current_ctrl: CtrlUtil = null

# 当前控制器实例引用
var ctrl_instance: CtrlBase = null

# 召唤此控制器的卡牌引用
var summoning_card: Node2D = null

func _ready():
	# 设置为全屏布局，作为控制器的父节点
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# 设置CtrlUtil的可见性和层级
	visible = true
	z_index = GlobalConstants.CTRL_Z_INDEX + 1  # 比控制器实例稍高一点
	modulate = Color.WHITE
	
	# 移除已存在的控制器（确保场上只能存在一个控制器）
	if current_ctrl != null and current_ctrl != self:
		GlobalUtil.log("移除已存在的控制器，实例ID: " + str(current_ctrl.get_instance_id()), GlobalUtil.LogLevel.INFO)
		current_ctrl.queue_free()
	
	# 记录当前控制器实例
	current_ctrl = self
	GlobalUtil.log("控制器工具类创建，实例ID: " + str(get_instance_id()) + ", 可见性: " + str(visible) + ", z_index: " + str(z_index), GlobalUtil.LogLevel.INFO)

# 从控制器包加载数据
func load_from_ctrl_pack(pack):
	# 移除旧的控制器实例
	if ctrl_instance != null:
		ctrl_instance.queue_free()
	
	# 创建新的控制器实例
	ctrl_instance = pack
	add_child(ctrl_instance)
	
	GlobalUtil.log("从控制器包加载数据: " + pack.ctrl_name, GlobalUtil.LogLevel.DEBUG)

# 通过类型字符串加载控制器
func load_from_ctrl_type(type: String):
	var pack = get_ctrl_pack_by_type(type)
	if pack != null:
		load_from_ctrl_pack(pack)
	else:
		GlobalUtil.log("未找到控制器类型: " + type, GlobalUtil.LogLevel.ERROR)

# 设置控制器标题和描述
func set_ctrl_title_and_description(title: String, desc: String):
	if ctrl_instance != null:
		ctrl_instance.set_ctrl_data(title, desc)
		if ctrl_instance.title_label:
			ctrl_instance.title_label.text = title
		if ctrl_instance.description_label:
			ctrl_instance.description_label.text = desc
		GlobalUtil.log("设置控制器标题: " + title + ", 描述: " + desc, GlobalUtil.LogLevel.DEBUG)

# 静态方法：检查是否有控制器存在
static func has_ctrl() -> bool:
	return current_ctrl != null

# 静态方法：通过类型获取控制器包实例
static func get_ctrl_pack_by_type(type: String):
	match type:
		"400x300":
			return Ctrl400x300Pack.new()
		_:
			GlobalUtil.log("未知的控制器类型: " + type, GlobalUtil.LogLevel.ERROR)
			return null

# 静态方法：移除当前控制器
static func remove_current_ctrl():
	if current_ctrl != null:
		GlobalUtil.log("移除当前控制器，实例ID: " + str(current_ctrl.get_instance_id()), GlobalUtil.LogLevel.INFO)
		current_ctrl.queue_free()
		current_ctrl = null

# 静态方法：获取当前控制器
static func get_current_ctrl() -> CtrlUtil:
	return current_ctrl

# 检查指定位置是否有卡牌（简化实现）
func _check_card_at_position(pos: Vector2) -> bool:
	# 这里可以实现具体的卡牌检测逻辑
	# 暂时返回false，表示没有卡牌
	return false

# 处理控制器点击事件
func _on_ctrl_clicked():
	if ctrl_instance != null and ctrl_instance.on_click.is_valid():
		ctrl_instance.on_click.call(ctrl_instance)
		GlobalUtil.log("控制器被点击: " + ctrl_instance.ctrl_name, GlobalUtil.LogLevel.INFO)
