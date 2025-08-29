extends Control
class_name CtrlBase

# 控制器基类（Control节点）
# 定义控制器的基本属性和方法，使用Control+anchor实现UI布局

# 控制器基本属性
var ctrl_name: String = "基础控制器"
var description: String = "基础控制器描述"

# 控制器背景纹理（子类需要设置，默认透明）
@export var ctrl_texture: Texture2D = null

# 控制器点击效果（可选）
var on_click: Callable = Callable()

# UI元素引用
var background_panel: Panel
var title_label: Label
var description_label: Label

# 初始化控制器
func _init(p_name: String = "基础控制器", p_description: String = "基础控制器描述"):
	ctrl_name = p_name
	description = p_description
	GlobalUtil.log("创建控制器基类: " + ctrl_name, GlobalUtil.LogLevel.DEBUG)

# Control节点准备就绪时调用
func _ready():
	# 设置控制器可见性和层级
	visible = true
	z_index = GlobalConstants.CTRL_Z_INDEX
	modulate = Color.WHITE  # 确保不透明
	
	# 设置控制器UI
	setup_ctrl_ui()
	
	# 设置控制器布局
	setup_ctrl_layout()
	
	# 更新背景纹理
	update_background_texture()
	
	# 输出详细的调试信息
	var screen_size = get_viewport().get_visible_rect().size
	GlobalUtil.log("控制器UI初始化完成: " + ctrl_name, GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("- 屏幕尺寸: " + str(screen_size), GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("- 控制器尺寸: " + str(size), GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("- 控制器位置: (" + str(position.x) + ", " + str(position.y) + ")", GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("- 控制器偏移: left=" + str(offset_left) + ", top=" + str(offset_top) + ", right=" + str(offset_right) + ", bottom=" + str(offset_bottom), GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("- 可见性: " + str(visible) + ", z_index: " + str(z_index) + ", modulate: " + str(modulate), GlobalUtil.LogLevel.DEBUG)

# 设置控制器UI元素
func setup_ctrl_ui():
	# 创建背景面板
	background_panel = Panel.new()
	background_panel.name = "BackgroundPanel"
	background_panel.visible = true
	background_panel.modulate = Color.WHITE
	add_child(background_panel)
	
	# 设置一个默认的背景颜色，确保面板可见
	var default_style = StyleBoxFlat.new()
	default_style.bg_color = Color(0.2, 0.2, 0.3, 0.8)  # 半透明深蓝色
	default_style.border_width_left = 2
	default_style.border_width_right = 2
	default_style.border_width_top = 2
	default_style.border_width_bottom = 2
	default_style.border_color = Color.WHITE
	background_panel.add_theme_stylebox_override("panel", default_style)
	
	# 创建标题标签
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = ctrl_name
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.modulate = Color.WHITE
	add_child(title_label)
	
	# 创建描述标签
	description_label = Label.new()
	description_label.name = "DescriptionLabel"
	description_label.text = description
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.modulate = Color.WHITE
	add_child(description_label)
	
	GlobalUtil.log("控制器UI元素创建完成", GlobalUtil.LogLevel.DEBUG)

# 设置控制器布局（子类可重写）
func setup_ctrl_layout():
	# 使用固定的控制器尺寸
	var ctrl_width = GlobalConstants.CTRL_WIDTH
	var ctrl_height = GlobalConstants.CTRL_HEIGHT
	
	# 设置控制器尺寸
	size = Vector2(ctrl_width, ctrl_height)
	
	# 设置控制器位置（居中显示）
	var screen_size = get_viewport().get_visible_rect().size
	var ctrl_position = Vector2(
		(screen_size.x - ctrl_width) / 2,
		(screen_size.y - ctrl_height) / 2
	)
	position = ctrl_position
	
	# 设置锚点和边距，确保控制器正确显示
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 0.0
	anchor_bottom = 0.0
	offset_left = ctrl_position.x
	offset_top = ctrl_position.y
	offset_right = ctrl_position.x + ctrl_width
	offset_bottom = ctrl_position.y + ctrl_height
	
	# 设置背景面板的尺寸和位置
	if background_panel:
		background_panel.size = Vector2(ctrl_width, ctrl_height)
		background_panel.position = Vector2.ZERO
		background_panel.z_index = GlobalConstants.CTRL_Z_INDEX
		background_panel.anchor_left = 0.0
		background_panel.anchor_top = 0.0
		background_panel.anchor_right = 1.0
		background_panel.anchor_bottom = 1.0
		background_panel.offset_left = 0
		background_panel.offset_top = 0
		background_panel.offset_right = 0
		background_panel.offset_bottom = 0
	
	# 设置标题标签的位置和尺寸
	if title_label:
		title_label.size = Vector2(ctrl_width, 50)
		title_label.position = Vector2(10, 10)
		title_label.z_index = GlobalConstants.CTRL_TITLE_Z_INDEX
		title_label.add_theme_font_size_override("font_size", 18)
	
	# 设置描述标签的位置和尺寸
	if description_label:
		description_label.size = Vector2(ctrl_width - 20, ctrl_height - 80)
		description_label.position = Vector2(10, 70)
		description_label.z_index = GlobalConstants.CTRL_TITLE_Z_INDEX
		description_label.add_theme_font_size_override("font_size", 14)
	
	GlobalUtil.log("控制器布局设置完成，尺寸: " + str(size) + ", 位置: " + str(position) + ", 锚点设置完成, 背景面板z_index: " + str(GlobalConstants.CTRL_Z_INDEX) + ", 标题z_index: " + str(GlobalConstants.CTRL_TITLE_Z_INDEX), GlobalUtil.LogLevel.DEBUG)

# 设置控制器数据
func set_ctrl_data(p_name: String, p_description: String):
	ctrl_name = p_name
	description = p_description

# 获取控制器数据
func get_ctrl_data() -> Dictionary:
	return {
		"name": ctrl_name,
		"description": description,
		"texture": ctrl_texture,
		"on_click": on_click
	}

# 获取控制器尺寸（基于当前Control节点的size）
func get_ctrl_size() -> Vector2:
	return size

# 更新背景纹理的方法
func update_background_texture():
	if background_panel and ctrl_texture:
		# 确保背景面板可见
		background_panel.visible = true
		background_panel.modulate = Color.WHITE
		
		# 创建并应用纹理样式，覆盖默认样式
		var style_box = StyleBoxTexture.new()
		style_box.texture = ctrl_texture
		# 在Godot 4中使用expand_margin属性
		style_box.expand_margin_left = 0
		style_box.expand_margin_right = 0
		style_box.expand_margin_top = 0
		style_box.expand_margin_bottom = 0
		# 设置纹理区域为整个纹理
		style_box.region_rect = Rect2(Vector2.ZERO, ctrl_texture.get_size())
		background_panel.add_theme_stylebox_override("panel", style_box)
		
		GlobalUtil.log("控制器背景纹理已更新: " + ctrl_name + ", 纹理尺寸: " + str(ctrl_texture.get_size()) + ", 背景面板可见性: " + str(background_panel.visible), GlobalUtil.LogLevel.DEBUG)
	elif background_panel:
		GlobalUtil.log("控制器使用默认背景样式: " + ctrl_name + ", ctrl_texture为空", GlobalUtil.LogLevel.DEBUG)
	else:
		GlobalUtil.log("无法更新背景纹理 - background_panel为空", GlobalUtil.LogLevel.WARNING)
