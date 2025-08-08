extends Resource
class_name CardPackBase

# 卡包的基本属性
var pack_name: String = "基础卡包"
var description: String = "基础卡包描述"
var cards_count: int = 0
var cards: Array = []

# 卡包图片资源
@export var pack_image: Texture2D = preload("res://assets/images/card_template.png")

# 初始化函数
func _init(p_name: String = "基础卡包", p_description: String = "基础卡包描述"):
	pack_name = p_name
	description = p_description

# 添加卡牌到卡包
func add_card(card):
	cards.append(card)
	cards_count += 1

# 从卡包移除卡牌
func remove_card(card):
	var index = cards.find(card)
	if index != -1:
		cards.remove_at(index)
		cards_count -= 1
		return true
	return false

# 获取卡包中的所有卡牌
func get_all_cards() -> Array:
	return cards

# 获取卡包中的随机卡牌
func get_random_card():
	if cards_count > 0:
		var random_index = randi() % cards_count
		return cards[random_index]
	return null
