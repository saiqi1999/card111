extends Resource
class_name CardPackBase

# 卡包的基本属性
var pack_name: String = "基础卡包"
var description: String = "基础卡包描述"

# 卡牌属性
var card_name: String = "未命名卡牌"
var card_description: String = "无描述"
var card_type: String = ""  # 卡牌类型标识符，对应文件名
var on_click: Callable = Callable()  # 卡牌点击时的个性化效果
var after_init: Callable = Callable()  # 初始化完成后的回调
var after_recipe_done: Callable = Callable()  # 合成完成后的回调
var tags: Array[String] = []  # 卡牌标签数组，用于标记卡牌的特殊属性

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



# 标签管理方法
# 添加标签
func add_tag(tag: String):
	if not has_tag(tag):
		tags.append(tag)

# 移除标签
func remove_tag(tag: String):
	if has_tag(tag):
		tags.erase(tag)

# 检查是否有指定标签
func has_tag(tag: String) -> bool:
	return tag in tags

# 获取所有标签
func get_tags() -> Array[String]:
	return tags.duplicate()

# 清空所有标签
func clear_tags():
	tags.clear()
