extends "res://scripts/ctrl/ctrl_base.gd"
class_name Ctrl400x300Pack

# 400x300小控制器包
# 继承自CtrlBase，提供小控制器的特定功能

# 初始化小控制器
func _init():
	# 调用父类初始化
	super._init("小容器", "标准尺寸的容器，位于左下角")
	
	# 设置容器纹理
	ctrl_texture = preload("res://assets/images/frame.jpg")
	on_click = ctrl_400_300_click_effect
	
	GlobalUtil.log("创建小容器实例", GlobalUtil.LogLevel.DEBUG)

# 设置小控制器布局（覆盖父类方法，固定在左下角，根据屏幕分辨率缩放）
func setup_ctrl_layout():
	# 获取屏幕尺寸
	var screen_size = GlobalUtil.get_screen_size()
	if screen_size == Vector2.ZERO:
		screen_size = get_viewport().get_visible_rect().size
	
	# 计算控制器尺寸为屏幕的四分之一
	var ctrl_width = screen_size.x / 4.0
	var ctrl_height = screen_size.y / 4.0
	
	# 设置控制器尺寸
	size = Vector2(ctrl_width, ctrl_height)
	
	# 计算左下角位置（距离边缘100px）
	var ctrl_position = Vector2(
		100.0,  # 距离左边缘100px
		screen_size.y - ctrl_height - 100.0  # 距离底边缘100px
	)
	
	# 设置位置
	position = ctrl_position
	
	# 设置锚点为左上角（使用绝对位置）
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 0.0
	anchor_bottom = 0.0
	
	# 设置偏移量
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
	
	GlobalUtil.log("小容器布局设置完成（左下角定位，屏幕四分之一缩放），尺寸: " + str(size) + ", 位置: " + str(position) + ", 屏幕尺寸: " + str(screen_size), GlobalUtil.LogLevel.DEBUG)

# 设置小控制器标题和描述
func set_title_and_description(title: String, desc: String):
	ctrl_name = title
	description = desc
	if title_label:
		title_label.text = title
	if description_label:
		description_label.text = desc
	GlobalUtil.log("设置容器标题: " + title + ", 描述: " + desc, GlobalUtil.LogLevel.DEBUG)

# 小控制器点击效果
func ctrl_400_300_click_effect(ctrl_instance):
	GlobalUtil.log("400x300控制器被点击，控制器实例ID: " + str(ctrl_instance.get_instance_id()), GlobalUtil.LogLevel.INFO)
	# 这里可以添加400x300容器特有的点击效果
	# 例如：播放特定音效、显示特定动画等
