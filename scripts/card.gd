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

# 调试选项
var print_position_updates: bool = false  # 是否在_process中持续打印位置更新
var print_position_on_ready: bool = true   # 是否在_ready中打印一次位置信息

func _ready() -> void:
	# 检查卡牌图片是否已设置
	if card_image:
		print("卡牌 '%s' 图片已预先设置，原始尺寸: 宽度 %d, 高度 %d" % 
			[card_name, card_image.get_width(), card_image.get_height()])
	else:
		# 如果没有设置图片，加载默认图片
		card_image = load("res://assets/images/card_template.png")
		print("卡牌 '%s' 使用默认图片，原始尺寸: 宽度 %d, 高度 %d" % 
			[card_name, card_image.get_width(), card_image.get_height()])
	
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
		
		# 获取背景引用
		var background = $CardUI/Background
		
		# 重新设置卡牌图片的位置和大小
		card_sprite.offset_left = -80
		card_sprite.offset_top = -120  # 向上移动，使图片在卡牌上半部分
		card_sprite.offset_right = 80
		card_sprite.offset_bottom = 0  # 确保图片显示完整
		
		# 设置图片的拉伸模式为保持纵横比并填充
		card_sprite.stretch_mode = 5
		
		# 打印卡牌图片信息
		var texture = card_sprite.texture
		if texture:
			# 资源路径打印由子类自己处理，避免重复
			if get_script() == load("res://scripts/card.gd"):
				print("卡牌 '%s' 图片已加载: %s" % [card_name, texture.resource_path if texture.resource_path else "内存中的图片"])
			
			# 始终打印位置信息，确保每张卡牌都能显示其位置
			print("卡牌 '%s' 图片位置: (%d, %d)" % [card_name, global_position.x, global_position.y])
			
			# 打印卡牌实际尺寸，而不是纹理原始尺寸
			# 重用之前获取的background引用
			print("卡牌 '%s' 图片大小: 宽度 %d, 高度 %d" % [card_name, background.size.x, background.size.y])
			
			# 获取卡牌实际显示尺寸
			var width = background.size.x
			var height = background.size.y
			
			# 计算卡牌图片区域的信息
			var img_width = card_sprite.offset_right - card_sprite.offset_left
			var img_height = card_sprite.offset_bottom - card_sprite.offset_top
			print("卡牌图片实际尺寸: 宽度 %d, 高度 %d" % [img_width, img_height])
			
			# 计算并打印卡牌四个顶点的坐标
			var top_left = global_position - Vector2(width/2, height/2)
			var top_right = global_position + Vector2(width/2, -height/2)
			var bottom_left = global_position + Vector2(-width/2, height/2)
			var bottom_right = global_position + Vector2(width/2, height/2)
			
			print("卡牌 '%s' 四个顶点坐标:" % card_name)
			print("左上角: (%d, %d)" % [top_left.x, top_left.y])
			print("右上角: (%d, %d)" % [top_right.x, top_right.y])
			print("左下角: (%d, %d)" % [bottom_left.x, bottom_left.y])
			print("右下角: (%d, %d)" % [bottom_right.x, bottom_right.y])
			
			# 打印更详细的尺寸信息用于调试
			print_detailed_size_info()
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
	
	# 实时打印卡牌位置（如果启用）
	if print_position_updates and card_sprite and card_sprite.texture:
		print("卡牌 '%s' 实时位置: (%d, %d)" % [card_name, global_position.x, global_position.y])
		
		# 获取卡牌实际显示尺寸
		var background = $CardUI/Background
		var width = background.size.x
		var height = background.size.y
		
		# 计算卡牌图片区域的信息
		var img_width = card_sprite.offset_right - card_sprite.offset_left
		var img_height = card_sprite.offset_bottom - card_sprite.offset_top
		
		# 打印卡牌实际尺寸
		print("卡牌 '%s' 实时图片大小: 宽度 %d, 高度 %d" % [card_name, width, height])
		print("卡牌图片实际尺寸: 宽度 %d, 高度 %d" % [img_width, img_height])
		
		# 计算并打印卡牌四个顶点的实时坐标
		var top_left = global_position - Vector2(width/2, height/2)
		var top_right = global_position + Vector2(width/2, -height/2)
		var bottom_left = global_position + Vector2(-width/2, height/2)
		var bottom_right = global_position + Vector2(width/2, height/2)
		
		print("卡牌 '%s' 实时四个顶点坐标:" % card_name)
		print("左上角: (%d, %d)" % [top_left.x, top_left.y])
		print("右上角: (%d, %d)" % [top_right.x, top_right.y])
		print("左下角: (%d, %d)" % [bottom_left.x, bottom_left.y])
		print("右下角: (%d, %d)" % [bottom_right.x, bottom_right.y])

# 检查是否可以打出卡牌
func _can_play_card() -> bool:
	# 这里实现检查逻辑，例如检查能量是否足够
	return is_playable

# 打出卡牌
func play_card() -> void:
	print("Playing card: ", card_name)
	card_played.emit(self)
	# 卡牌效果在这里实现

# 控制位置打印功能
func set_position_printing(on_ready: bool = true, continuous: bool = false) -> void:
	print_position_on_ready = on_ready
	print_position_updates = continuous
	
	# 如果开启了持续打印，立即打印一次当前位置
	if continuous and card_sprite and card_sprite.texture:
		print("卡牌 '%s' 当前位置: (%d, %d)" % [card_name, global_position.x, global_position.y])

# 打印当前位置（可由外部调用）
func print_current_position() -> void:
	if card_sprite and card_sprite.texture:
		print("卡牌 '%s' 当前位置: (%d, %d)" % [card_name, global_position.x, global_position.y])
		
		# 获取卡牌实际显示尺寸
		var background = $CardUI/Background
		var width = background.size.x
		var height = background.size.y
		
		# 计算卡牌图片区域的信息
		var img_width = card_sprite.offset_right - card_sprite.offset_left
		var img_height = card_sprite.offset_bottom - card_sprite.offset_top
		
		# 打印卡牌实际尺寸
		print("卡牌 '%s' 当前图片大小: 宽度 %d, 高度 %d" % [card_name, width, height])
		print("卡牌图片实际尺寸: 宽度 %d, 高度 %d" % [img_width, img_height])
		
		# 计算并打印卡牌四个顶点的坐标
		var top_left = global_position - Vector2(width/2, height/2)
		var top_right = global_position + Vector2(width/2, -height/2)
		var bottom_left = global_position + Vector2(-width/2, height/2)
		var bottom_right = global_position + Vector2(width/2, height/2)
		
		print("卡牌 '%s' 当前四个顶点坐标:" % card_name)
		print("左上角: (%d, %d)" % [top_left.x, top_left.y])
		print("右上角: (%d, %d)" % [top_right.x, top_right.y])
		print("左下角: (%d, %d)" % [bottom_left.x, bottom_left.y])
		print("右下角: (%d, %d)" % [bottom_right.x, bottom_right.y])
	_apply_card_effect()

# 应用卡牌效果
func _apply_card_effect() -> void:
	# 在子类中重写此方法以实现特定卡牌效果
	pass

# 打印卡牌的详细尺寸信息（用于调试）
func print_detailed_size_info() -> void:
	if not card_sprite or not card_sprite.texture:
		print("卡牌 '%s' 没有纹理" % card_name)
		return
	
	var texture = card_sprite.texture
	var background = $CardUI/Background
	
	print("========== 卡牌 '%s' 详细尺寸信息 ==========" % card_name)
	print("全局位置: (%d, %d)" % [global_position.x, global_position.y])
	print("纹理原始尺寸: 宽度 %d, 高度 %d" % [texture.get_width(), texture.get_height()])
	print("卡牌背景尺寸: 宽度 %d, 高度 %d" % [background.size.x, background.size.y])
	
	# 打印卡牌图片节点的位置和边界信息
	print("卡牌图片节点边界: 左=%d, 上=%d, 右=%d, 下=%d" % [
		card_sprite.offset_left, 
		card_sprite.offset_top, 
		card_sprite.offset_right, 
		card_sprite.offset_bottom
	])
	print("卡牌图片实际宽度: %d" % (card_sprite.offset_right - card_sprite.offset_left))
	print("卡牌图片实际高度: %d" % (card_sprite.offset_bottom - card_sprite.offset_top))
	print("卡牌图片拉伸模式: %d" % card_sprite.stretch_mode)
	print("卡牌UI节点位置: (%d, %d)" % [$CardUI.position.x, $CardUI.position.y])
	
	# 计算并打印卡牌四个顶点的坐标（使用背景尺寸）
	var width = background.size.x
	var height = background.size.y
	var top_left = global_position - Vector2(width/2, height/2)
	var top_right = global_position + Vector2(width/2, -height/2)
	var bottom_left = global_position + Vector2(-width/2, height/2)
	var bottom_right = global_position + Vector2(width/2, height/2)
	
	print("使用背景尺寸计算的四个顶点坐标:")
	print("左上角: (%d, %d)" % [top_left.x, top_left.y])
	print("右上角: (%d, %d)" % [top_right.x, top_right.y])
	print("左下角: (%d, %d)" % [bottom_left.x, bottom_left.y])
	print("右下角: (%d, %d)" % [bottom_right.x, bottom_right.y])
	
	# 计算卡牌图片区域的四个顶点坐标
	var img_width = card_sprite.offset_right - card_sprite.offset_left
	var img_height = card_sprite.offset_bottom - card_sprite.offset_top
	var img_center = global_position + Vector2(0, (card_sprite.offset_top + card_sprite.offset_bottom) / 2)
	var img_top_left = img_center + Vector2(card_sprite.offset_left, card_sprite.offset_top)
	var img_top_right = img_center + Vector2(card_sprite.offset_right, card_sprite.offset_top)
	var img_bottom_left = img_center + Vector2(card_sprite.offset_left, card_sprite.offset_bottom)
	var img_bottom_right = img_center + Vector2(card_sprite.offset_right, card_sprite.offset_bottom)
	
	print("卡牌图片区域的四个顶点坐标:")
	print("左上角: (%d, %d)" % [img_top_left.x, img_top_left.y])
	print("右上角: (%d, %d)" % [img_top_right.x, img_top_right.y])
	print("左下角: (%d, %d)" % [img_bottom_left.x, img_bottom_left.y])
	print("右下角: (%d, %d)" % [img_bottom_right.x, img_bottom_right.y])
	print("========== 详细尺寸信息结束 ==========")
