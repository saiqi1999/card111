extends Resource
class_name ContainerBase

# 容器基类（抽象类）
# 定义容器的基本属性和方法，类似于CardPackBase

# 容器基本属性
var container_name: String = "基础容器"
var description: String = "基础容器描述"

# 容器尺寸（子类需要重写）
var container_width: float = 400.0
var container_height: float = 300.0

# 容器背景纹理（子类需要设置，默认透明）
@export var container_texture: Texture2D = null

# 容器点击效果（可选）
var on_click: Callable = Callable()

# 初始化函数
func _init(p_name: String = "基础容器", p_description: String = "基础容器描述"):
	container_name = p_name
	description = p_description
	GlobalUtil.log("创建容器基类: " + container_name, GlobalUtil.LogLevel.DEBUG)

# 设置容器数据
func set_container_data(p_name: String, p_description: String):
	container_name = p_name
	description = p_description

# 获取容器数据
func get_container_data() -> Dictionary:
	return {
		"name": container_name,
		"description": description,
		"width": container_width,
		"height": container_height,
		"texture": container_texture,
		"on_click": on_click
	}

# 获取容器尺寸
func get_container_size() -> Vector2:
	return Vector2(container_width, container_height)