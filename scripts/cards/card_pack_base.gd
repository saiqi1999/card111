extends Resource
class_name CardPackBase

# 卡包的基本属性
var pack_name: String = "基础卡包"
var description: String = "基础卡包描述"

# 卡牌属性
var card_name: String = "未命名卡牌"
var card_description: String = "无描述"
var on_click: Callable = Callable()  # 卡牌点击时的个性化效果

# 卡包图片资源
@export var pack_image: Texture2D = preload("res://assets/images/card_template.png")

# 初始化函数
func _init(p_name: String = "基础卡包", p_description: String = "基础卡包描述"):
	pack_name = p_name
	description = p_description



# 设置卡牌数据
func set_card_data(p_name: String, p_description: String):
	card_name = p_name
	card_description = p_description



# 获取卡牌数据
func get_card_data() -> Dictionary:
	return {
		"name": card_name,
		"description": card_description,
		"image": pack_image,
		"on_click": on_click
	}
