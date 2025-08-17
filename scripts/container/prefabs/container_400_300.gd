extends ContainerBase
class_name Container400x300Pack

# 400x300尺寸的容器包

# 容器内容属性
var title_text: String = "标题"
var description_text: String = "描述"

func _init():
	# 调用父类初始化
	super._init("400x300容器", "标准尺寸的容器，适用于大部分场景")
	
	# 设置容器特有属性
	container_width = 400.0
	container_height = 300.0
	# 设置容器纹理
	container_texture = preload("res://assets/images/frame.jpg")
	on_click = container_400_300_click_effect
	
	GlobalUtil.log("创建400x300容器包实例", GlobalUtil.LogLevel.DEBUG)

# 设置容器标题和描述
func set_title_and_description(title: String, desc: String):
	title_text = title
	description_text = desc
	GlobalUtil.log("设置容器标题: " + title + ", 描述: " + desc, GlobalUtil.LogLevel.DEBUG)

# 400x300容器的特有点击效果
func container_400_300_click_effect(container_instance):
	GlobalUtil.log("400x300容器被点击，容器实例ID: " + str(container_instance.get_instance_id()), GlobalUtil.LogLevel.INFO)
	# 这里可以添加400x300容器特有的点击效果
	# 例如：播放特定音效、显示特定动画等