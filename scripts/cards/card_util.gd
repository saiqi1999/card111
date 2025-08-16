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

# 拖拽相关变量
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
# 存储当前活动的Tween引用，用于在拖拽时停止动画
var active_tween: Tween = null

# 节点引用
@onready var sprite = $Sprite2D
@onready var label = $Label
@onready var desc_label = $Description

# 初始化函数
func _ready():
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 调用 _ready() 函数")
	# 更新卡牌显示
	update_display()
	
	# 确保卡牌背景大小正确
	var background = $CardBackground
	if background:
		background.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
		background.position = Vector2(-CARD_WIDTH/2, -CARD_HEIGHT/2)
	
	# 添加点击区域
	setup_input_detection()

# 设置卡牌数据
func set_card_data(p_name: String, p_description: String, p_image: Texture2D = null):
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 调用 set_card_data() 函数，卡牌名称: ", p_name)
	card_name = p_name
	description = p_description
	card_image = p_image
	
	# 如果已经准备好了，立即更新显示
	if is_inside_tree():
		update_display()

# 更新卡牌显示
func update_display():
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 调用 update_display() 函数")
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
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 调用 adjust_sprite_size() 函数")
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
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 调用 load_from_card_pack() 函数")
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
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 调用 load_from_card_type() 函数，类型: ", type_name)
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

# 移动卡牌到指定位置
static func move_card(card_instance: Node2D, target_position: Vector2, duration: float = 1.0):
	# 停止之前的Tween动画（如果存在）
	if card_instance.has_method("get") and card_instance.get("active_tween") != null:
		var old_tween = card_instance.get("active_tween")
		if old_tween.is_valid():
			old_tween.kill()
	
	# 创建Tween动画
	var tween = card_instance.create_tween()
	tween.set_trans(Tween.TRANS_QUART)
	
	# 保存Tween引用到卡牌实例（如果卡牌有active_tween属性）
	if card_instance.has_method("set"):
		card_instance.set("active_tween", tween)
	
	# 设置卡牌移动动画
	tween.tween_property(card_instance, "position", target_position, duration)
	
	# 动画完成后清除引用
	tween.finished.connect(func(): 
		if card_instance.has_method("set"):
			card_instance.set("active_tween", null)
	)
	
	# 返回Tween实例，以便调用者可以进一步操作
	return tween

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
	
	# 调用move_card方法移动卡牌
	move_card(card_instance, target_position, 1.0)
	
	# 返回移动的距离向量
	return Vector2(random_x, random_y)

# 设置输入检测
func setup_input_detection():
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 调用 setup_input_detection() 函数")
	
	# 关键修复：设置所有Control节点的mouse_filter为IGNORE，避免阻挡输入事件
	var card_background = get_node("CardBackground")
	if card_background and card_background is Control:
		card_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 设置CardBackground mouse_filter为IGNORE")
	
	# 设置Label节点的mouse_filter
	var label = get_node("Label")
	if label and label is Control:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 设置Label mouse_filter为IGNORE")
	
	# 设置Description节点的mouse_filter
	var description = get_node("Description")
	if description and description is Control:
		description.mouse_filter = Control.MOUSE_FILTER_IGNORE
		print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 设置Description mouse_filter为IGNORE")
	
	# 创建一个Area2D节点用于检测点击
	var click_area = Area2D.new()
	click_area.name = "ClickArea"
	
	# 关键设置：启用输入检测
	click_area.input_pickable = true
	click_area.monitoring = true
	click_area.monitorable = true
	# 设置碰撞层，这是输入检测的关键要求
	click_area.collision_layer = 1
	click_area.collision_mask = 0  # 不需要检测碰撞，只需要输入
	
	add_child(click_area)
	
	# 将Area2D移动到最上层，确保点击检测优先级
	move_child(click_area, get_child_count() - 1)
	
	# 创建碰撞形状
	var collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape"
	collision_shape.position = Vector2(0, 0) # 确保碰撞形状位于卡牌中心
	click_area.add_child(collision_shape)
	
	# 创建矩形形状
	var shape = RectangleShape2D.new()
	shape.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	collision_shape.shape = shape
	
	# 打印shape的绝对坐标范围
	var global_pos = global_position
	var shape_left = global_pos.x - CARD_WIDTH / 2
	var shape_right = global_pos.x + CARD_WIDTH / 2
	var shape_top = global_pos.y - CARD_HEIGHT / 2
	var shape_bottom = global_pos.y + CARD_HEIGHT / 2
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " Shape绝对坐标范围:")
	print("  左边界:", shape_left, " 右边界:", shape_right)
	print("  上边界:", shape_top, " 下边界:", shape_bottom)
	print("  中心点:", global_pos)
	
	# 连接输入事件
	click_area.input_event.connect(_on_card_input_event)
	# 连接鼠标进入和离开事件用于调试
	click_area.mouse_entered.connect(_on_mouse_entered)
	click_area.mouse_exited.connect(_on_mouse_exited)
	
	# 添加调试信息
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " Area2D设置完成:")
	print("  - input_pickable:", click_area.input_pickable)
	print("  - collision_layer:", click_area.collision_layer)
	print("  - collision_mask:", click_area.collision_mask)

# 处理卡牌输入事件
func _on_card_input_event(_viewport, event, _shape_idx):
	# 处理鼠标按钮事件
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 检测到鼠标左键点击")
			# 打印卡牌信息
			print_card_info()
			
			# 停止当前活动的Tween动画，避免与拖拽冲突
			if active_tween != null and active_tween.is_valid():
				active_tween.kill()
				active_tween = null
				print("[DEBUG] 停止了正在进行的Tween动画")
			
			# 开始拖拽
			is_dragging = true
			drag_offset = global_position - get_global_mouse_position()
			modulate.a = 0.8  # 拖拽时半透明效果
		else:
			# 鼠标释放，结束拖拽
			is_dragging = false
			modulate.a = 1.0  # 恢复透明度
			print("[DEBUG] 卡牌拖拽结束，最终位置:", global_position)
	
	# 处理鼠标移动事件（用于拖拽）
	elif event is InputEventMouseMotion and is_dragging:
		# 更新卡牌位置跟随鼠标
		global_position = get_global_mouse_position() + drag_offset

# 鼠标进入事件（调试用）
func _on_mouse_entered():
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 鼠标进入卡牌区域")

# 鼠标离开事件（调试用）
func _on_mouse_exited():
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 鼠标离开卡牌区域")

# 打印卡牌信息
func print_card_info():
	print("[DEBUG] 卡牌实例ID:", get_instance_id(), " 调用 print_card_info() 函数")
	print("===== 卡牌信息 =====")
	print("名称: ", card_name)
	print("描述: ", description)
	if card_pack:
		print("卡包: ", card_pack.pack_name)
	print("===================")
