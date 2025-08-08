extends Node2D

# 卡牌工具组件
# 用于显示卡牌的视觉表现和提供卡牌相关工具函数

# 卡牌属性
var card_name: String = "未命名卡牌"
var description: String = "无描述"
var card_image: Texture2D = null

# 卡包引用
var card_pack: CardPackBase = null

# 节点引用
@onready var sprite = $Sprite2D
@onready var label = $Label
@onready var desc_label = $Description

# 初始化函数
func _ready():
	# 更新卡牌显示
	update_display()

# 设置卡牌数据
func set_card_data(p_name: String, p_description: String, p_image: Texture2D = null):
	card_name = p_name
	description = p_description
	card_image = p_image
	
	# 如果已经准备好了，立即更新显示
	if is_inside_tree():
		update_display()

# 更新卡牌显示
func update_display():
	# 更新文本
	label.text = card_name
	desc_label.text = description
	
	# 更新图像
	if card_image != null:
		sprite.texture = card_image
	
# 从卡包加载卡牌
func load_from_card_pack(p_card_pack):
	if p_card_pack is CardPackBase:
		# 保存卡包引用
		card_pack = p_card_pack
		
		# 从卡包获取数据
		var card_data = card_pack.get_card_data()
		
		# 设置卡牌数据
		set_card_data(card_data.name, card_data.description, card_data.image)
		return true
	return false

# 通过卡包类型字符串加载卡牌
func load_from_card_type(type_name: String):
	# 通过类型字符串获取卡包实例
	var pack = get_card_pack_by_type(type_name)
	
	# 加载卡包数据
	return load_from_card_pack(pack)

# 通过类型字符串获取卡包实例
static func get_card_pack_by_type(type_name: String) -> CardPackBase:
	# 根据类型字符串创建对应的卡包实例
	var pack: CardPackBase = null
	
	match type_name.to_lower():
		"strike":
			# 创建打击卡包实例
			pack = load("res://scripts/cards/strike_card_pack.gd").new()
		_:
			# 默认创建基础卡包
			pack = CardPackBase.new()
	
	return pack