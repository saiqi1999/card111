# res://scripts/card.gd
extends Node2D

# 卡牌信号
signal card_played(card)
signal card_hovered(card)
signal card_clicked(card)

# 卡牌基本属性
@export var card_name: String = "Card"
@export var cost: int = 1
@export var description: String = "Card description"
@export var card_image: Texture2D

# 卡牌UI组件
@onready var name_label = $CardUI/NameLabel
@onready var cost_label = $CardUI/CostLabel
@onready var description_label = $CardUI/DescriptionLabel
@onready var card_sprite = $CardUI/CardImage

# 卡牌状态
var is_playable: bool = true
var is_being_dragged: bool = false
var original_position: Vector2

func _ready() -> void:
	# 初始化卡牌UI
	if name_label:
		name_label.text = card_name
	if cost_label:
		cost_label.text = str(cost)
	if description_label:
		description_label.text = description
	# 设置卡牌图片纹理
	if card_sprite and card_image:
		card_sprite.texture = card_image
	
	# 打印卡牌图片信息 - 无论是否有特定图片都打印
	if card_sprite:
		var texture = card_sprite.texture
		if texture:
			print("卡牌 '%s' 图片已加载: %s" % [card_name, texture.resource_path if texture.resource_path else "内存中的图片"])
			print("卡牌 '%s' 图片位置: (%d, %d)" % [card_name, global_position.x, global_position.y])
			print("卡牌 '%s' 图片大小: 宽度 %d, 高度 %d" % [card_name, texture.get_width(), texture.get_height()])
			
			# 计算并打印卡牌四个顶点的坐标
			var width = card_sprite.size.x
			var height = card_sprite.size.y
			var top_left = global_position + card_sprite.position - Vector2(width/2, height/2)
			var top_right = global_position + card_sprite.position + Vector2(width/2, -height/2)
			var bottom_left = global_position + card_sprite.position + Vector2(-width/2, height/2)
			var bottom_right = global_position + card_sprite.position + Vector2(width/2, height/2)
			
			print("卡牌 '%s' 四个顶点坐标:" % card_name)
			print("左上角: (%d, %d)" % [top_left.x, top_left.y])
			print("右上角: (%d, %d)" % [top_right.x, top_right.y])
			print("左下角: (%d, %d)" % [bottom_left.x, bottom_left.y])
			print("右下角: (%d, %d)" % [bottom_right.x, bottom_right.y])
		else:
			print("卡牌 '%s' 没有纹理" % card_name)
	
	# 连接输入事件
	set_process_input(true)
	# 使用Area2D节点处理输入事件
	var area = $Area2D
	if area:
		area.input_event.connect(_on_input_event)

# 处理卡牌输入事件
func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 卡牌被点击
				card_clicked.emit(self)
				if is_playable:
					# 开始拖动
					is_being_dragged = true
					original_position = global_position
			else:
				# 释放点击，可能是打出卡牌
				if is_being_dragged:
					is_being_dragged = false
					# 检查是否可以打出卡牌
					if _can_play_card():
						play_card()
					else:
						# 返回原位置
						global_position = original_position
	elif event is InputEventMouseMotion:
		if is_being_dragged:
			# 跟随鼠标移动
			global_position = get_global_mouse_position()
		else:
			# 鼠标悬停
			card_hovered.emit(self)

func _process(delta: float) -> void:
	# 处理拖动逻辑
	if is_being_dragged:
		global_position = get_global_mouse_position()

# 检查是否可以打出卡牌
func _can_play_card() -> bool:
	# 这里实现检查逻辑，例如检查能量是否足够
	return is_playable

# 打出卡牌
func play_card() -> void:
	print("Playing card: ", card_name)
	card_played.emit(self)
	# 卡牌效果在这里实现
	_apply_card_effect()

# 应用卡牌效果
func _apply_card_effect() -> void:
	# 在子类中重写此方法以实现特定卡牌效果
	pass
