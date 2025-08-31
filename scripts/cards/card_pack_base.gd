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

# 初始化完成后的回调方法
# 子类可以重写此方法来实现特定的初始化后逻辑
# card_instance: 当前卡牌实例
func after_init(card_instance):
	pass

# 合成完成后的回调方法
# 子类可以重写此方法来实现特定的合成后逻辑
# card_instance: 当前卡牌实例
# crafting_cards: 参与合成的卡牌列表
func after_recipe_done(card_instance, crafting_cards: Array):
	pass
