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

# 设置小控制器布局
func setup_ctrl_layout():
	# 调用父类的默认布局（左下角，三分之一屏幕）
	super.setup_ctrl_layout()
	
	# 可以在这里添加小容器特有的布局调整
	GlobalUtil.log("小容器布局设置完成", GlobalUtil.LogLevel.DEBUG)

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