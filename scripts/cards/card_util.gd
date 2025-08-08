extends Node2D

# 卡牌工具组件
# 用于显示卡牌的视觉表现和提供卡牌相关工具函数

# 卡牌固定尺寸
const CARD_WIDTH: float = 200.0  # 卡牌宽度
const CARD_HEIGHT: float = 300.0  # 卡牌高度

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
	
	# 确保卡牌背景大小正确
	var background = $CardBackground
	if background:
		background.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
		background.position = Vector2(-CARD_WIDTH/2, -CARD_HEIGHT/2)

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
		
		# 调整图片大小以适应卡牌固定尺寸
		adjust_sprite_size()

# 调整精灵大小以适应卡牌固定尺寸
func adjust_sprite_size():
	if sprite.texture == null:
		return
		
	# 计算图片原始尺寸
	var texture_size = sprite.texture.get_size()
	
	# 计算缩放比例，使图片适应卡牌尺寸但保持宽高比
	var scale_x = CARD_WIDTH / texture_size.x
	var scale_y = (CARD_HEIGHT * 0.6) / texture_size.y  # 使图片占据卡牌高度的60%
	
	# 使用较小的缩放比例以确保图片完全适应卡牌
	var scale_factor = min(scale_x, scale_y)
	
	# 应用缩放
	sprite.scale = Vector2(scale_factor, scale_factor)
	
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

# 随机移动卡牌到非中心区域
static func random_move_card(card_instance: Node2D):
	# 生成随机的x坐标（-200到200范围内，但不在-50到50范围内）
	var random_x: float = 0.0
	if randf() < 0.5:
		# 生成-200到-50的随机数
		random_x = randf_range(-200, -50)
	else:
		# 生成50到200的随机数
		random_x = randf_range(50, 200)
	
	# 生成随机的y坐标（-200到200范围内，但不在-50到50范围内）
	var random_y: float = 0.0
	if randf() < 0.5:
		# 生成-200到-50的随机数
		random_y = randf_range(-200, -50)
	else:
		# 生成50到200的随机数
		random_y = randf_range(50, 200)
	
	# 计算目标位置（相对当前位置）
	var target_position = card_instance.position + Vector2(random_x, random_y)
	
	# 创建Tween动画
	var tween = card_instance.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	
	# 设置卡牌移动动画
	tween.tween_property(card_instance, "position", target_position, 1.0)
	
	# 返回移动的距离向量
	return Vector2(random_x, random_y)