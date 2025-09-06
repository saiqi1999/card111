extends CanvasLayer

# 简化的UI控制器（Autoload单例）
# 提供简单的信息显示功能，使用CanvasLayer确保UI固定在屏幕位置

# 控制器基本属性
var ctrl_name: String = "信息面板"
var description: String = "显示卡牌信息"

# UI元素引用
var control_node: Control
var background_panel: Panel
var title_label: Label
var description_label: Label

# 显示控制器
func show_ctrl():
	control_node.visible = true
	GlobalUtil.log("显示信息面板", GlobalUtil.LogLevel.DEBUG)

# 隐藏控制器
func hide_ctrl():
	control_node.visible = false
	GlobalUtil.log("隐藏信息面板", GlobalUtil.LogLevel.DEBUG)

# 初始化
func _ready():
	# 创建主Control节点
	control_node = Control.new()
	add_child(control_node)
	
	# 计算窗口大小的1/3作为控制器尺寸
	var viewport_size = get_viewport().get_visible_rect().size
	var ctrl_width = viewport_size.x / 3.0
	var ctrl_height = viewport_size.y / 3.0
	
	# 设置Control节点的基本属性
	control_node.visible = false
	control_node.custom_minimum_size = Vector2(ctrl_width, ctrl_height)
	
	# 设置左下角锚点和位置
	control_node.anchor_left = 0.0
	control_node.anchor_top = 1.0
	control_node.anchor_right = 0.0
	control_node.anchor_bottom = 1.0
	control_node.offset_left = 20
	control_node.offset_top = -(ctrl_height + 20)
	control_node.offset_right = ctrl_width + 20
	control_node.offset_bottom = -20
	
	# 创建UI元素
	setup_ui()
	
	GlobalUtil.log("信息面板初始化完成", GlobalUtil.LogLevel.DEBUG)

# 创建UI元素
func setup_ui():
	# 创建背景面板
	background_panel = Panel.new()
	background_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	control_node.add_child(background_panel)
	
	# 设置背景样式
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.3, 0.9)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color.WHITE
	background_panel.add_theme_stylebox_override("panel", style)
	
	# 创建标题标签
	title_label = Label.new()
	title_label.text = ctrl_name
	title_label.position = Vector2(10, 10)
	title_label.size = Vector2(380, 40)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 18)
	control_node.add_child(title_label)
	
	# 创建描述标签
	description_label = Label.new()
	description_label.text = description
	description_label.position = Vector2(10, 60)
	description_label.size = Vector2(380, 230)
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 14)
	control_node.add_child(description_label)

# 设置标题和描述
func set_ctrl_title_and_description(title: String, desc: String):
	ctrl_name = title
	description = desc
	if title_label:
		title_label.text = title
	if description_label:
		description_label.text = desc
	GlobalUtil.log("设置信息面板内容: " + title, GlobalUtil.LogLevel.DEBUG)
