extends Node2D

# 卡牌工具组件
# 用于显示卡牌的视觉表现和提供卡牌相关工具函数

# 卡牌固定尺寸（使用全局常量）
const CARD_WIDTH: float = GlobalConstants.CARD_WIDTH  # 卡牌宽度
const CARD_HEIGHT: float = GlobalConstants.CARD_HEIGHT  # 卡牌高度

# 卡牌属性
var card_name: String = "未命名卡牌"
var description: String = "无描述"
var card_image: Texture2D = null
var on_click: Callable = Callable()  # 卡牌点击时的个性化效果

# 卡包引用
var card_pack: CardPackBase = null

# 卡牌拖拽相关变量
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
# 存储当前活动的Tween引用，用于在拖拽时停止动画
var active_tween: Tween = null
# 鼠标按下时的位置，用于判断是否为拖动
var mouse_press_position: Vector2 = Vector2.ZERO
# 连带拖拽的卡牌列表（当拖拽堆叠中间或底层卡牌时）
var dragging_cards: Array[Node2D] = []
# 标记是否已经调用了bring_to_front()，避免重复调用
var has_brought_to_front: bool = false

# 卡牌层级管理
static var card_layer_counter: int = 0  # 全局层级计数器
var card_layer: int = 0  # 当前卡牌的层级
static var all_cards: Array[Node2D] = []  # 所有卡牌实例的引用

# 卡牌堆叠系统
static var card_stacks: Dictionary = {}  # 卡牌堆叠状态管理 {stack_id: [card1, card2, ...]}
static var card_to_stack: Dictionary = {}  # 卡牌到堆叠的映射 {card_instance_id: stack_id}
static var stack_id_counter: int = 0  # 堆叠ID计数器
var stack_id: int = -1  # 当前卡牌所属的堆叠ID，-1表示不在任何堆叠中

# 卡牌池系统（使用全局常量）
static var card_pool: Array[Node2D] = []  # 预加载的卡牌池
static var pool_size: int = GlobalConstants.CARD_POOL_SIZE  # 卡牌池大小
static var is_pool_initialized: bool = false  # 卡牌池是否已初始化
static var hidden_position: Vector2 = GlobalConstants.CARD_POOL_HIDDEN_POSITION  # 隐藏位置

# 节点引用
@onready var sprite = $Sprite2D
@onready var label = $Label
@onready var desc_label = $Description

# 注册卡牌到全局管理器
func register_card():
	# 分配层级
	card_layer = card_layer_counter
	card_layer_counter += 1
	
	# 设置z_index
	z_index = card_layer
	
	# 添加到全局卡牌列表
	all_cards.append(self)
	
	GlobalUtil.log("卡牌注册，层级:" + str(card_layer) + " z_index:" + str(z_index), GlobalUtil.LogLevel.DEBUG)

# 注销卡牌（在卡牌被删除时调用）
func unregister_card():
	if self in all_cards:
		all_cards.erase(self)
		GlobalUtil.log("卡牌注销，层级:" + str(card_layer), GlobalUtil.LogLevel.DEBUG)

# 将卡牌移动到最上层
func bring_to_front():
	# 更新层级为当前最高层级
	card_layer = card_layer_counter
	card_layer_counter += 1
	
	# 更新z_index
	z_index = card_layer
	
	GlobalUtil.log("卡牌移动到最上层，新层级:" + str(card_layer), GlobalUtil.LogLevel.DEBUG)

# 检查当前卡牌是否是点击位置的最上层卡牌
func is_top_card_at_position(mouse_pos: Vector2) -> bool:
	# 获取在鼠标位置的所有卡牌
	var cards_at_position: Array[Node2D] = []
	
	for card in all_cards:
		if card == null or not is_instance_valid(card):
			continue
			
		# 检查鼠标是否在卡牌范围内
		var card_rect = Rect2(
			card.global_position - Vector2(CARD_WIDTH/2, CARD_HEIGHT/2),
			Vector2(CARD_WIDTH, CARD_HEIGHT)
		)
		
		if card_rect.has_point(mouse_pos):
			cards_at_position.append(card)
	
	# 如果没有其他卡牌在此位置，返回true
	if cards_at_position.size() <= 1:
		return true
	
	# 找到最高层级的卡牌
	var top_card = null
	var highest_layer = -1
	
	for card in cards_at_position:
		if card.has_method("get") and card.get("card_layer") != null:
			var layer = card.get("card_layer")
			if layer > highest_layer:
				highest_layer = layer
				top_card = card
	
	# 返回当前卡牌是否是最上层的
	return top_card == self

# 清理无效的卡牌引用
static func cleanup_invalid_cards():
	var valid_cards: Array[Node2D] = []
	for card in all_cards:
		if card != null and is_instance_valid(card):
			valid_cards.append(card)
	all_cards = valid_cards
	
	# 清理堆叠系统中的无效引用
	cleanup_invalid_stacks()
	
	GlobalUtil.log("清理无效卡牌引用，当前有效卡牌数量: " + str(all_cards.size()), GlobalUtil.LogLevel.DEBUG)

# 获取所有卡牌的调试信息（静态函数）
static func get_all_cards_debug_info() -> String:
	cleanup_invalid_cards()
	
	var info = "=== 所有卡牌信息 ===\n"
	info += "卡牌总数: " + str(all_cards.size()) + "\n"
	
	for i in range(all_cards.size()):
		var card = all_cards[i]
		if card != null and is_instance_valid(card):
			info += "卡牌 " + str(i) + ": 层级=" + str(card.get("card_layer")) + ", z_index=" + str(card.z_index) + "\n"
	
	info += "==================\n"
	return info

# 初始化函数
func _ready():
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 调用 _ready() 函数", GlobalUtil.LogLevel.DEBUG)
	
	# 注册卡牌到全局管理器
	register_card()
	
	# 更新卡牌显示
	update_display()
	
	# 确保卡牌背景大小正确
	var background = $CardBackground
	if background:
		background.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
		background.position = Vector2(-CARD_WIDTH/2, -CARD_HEIGHT/2)
	
	# 添加点击区域
	setup_input_detection()

# 当节点退出场景树时调用
func _exit_tree():
	# 从堆叠系统中移除
	remove_from_current_stack()
	# 注销卡牌
	unregister_card()

# 设置卡牌数据
func set_card_data(p_name: String, p_description: String, p_image: Texture2D = null, p_on_click: Callable = Callable()):
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 调用 set_card_data() 函数，卡牌名称: " + p_name, GlobalUtil.LogLevel.DEBUG)
	card_name = p_name
	description = p_description
	card_image = p_image
	on_click = p_on_click
	
	# 如果已经准备好了，立即更新显示
	if is_inside_tree():
		update_display()

# 更新卡牌显示
func update_display():
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 调用 update_display() 函数", GlobalUtil.LogLevel.DEBUG)
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
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 调用 adjust_sprite_size() 函数", GlobalUtil.LogLevel.DEBUG)
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
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 调用 load_from_card_pack() 函数", GlobalUtil.LogLevel.DEBUG)
	if p_card_pack is CardPackBase:
		# 保存卡包引用
		card_pack = p_card_pack
		
		# 从卡包获取数据
		var card_data = card_pack.get_card_data()
		
		# 设置卡牌数据，包括点击效果
		set_card_data(card_data.name, card_data.description, card_data.image, card_data.on_click)
		return true
	return false

# 通过卡包类型字符串加载卡牌
func load_from_card_type(type_name: String):
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 调用 load_from_card_type() 函数，类型: " + type_name, GlobalUtil.LogLevel.DEBUG)
	# 通过类型字符串获取卡包实例
	var pack = get_card_pack_by_type(type_name)
	
	# 加载卡包数据
	return load_from_card_pack(pack)

# 通过类型字符串获取卡包实例
static func get_card_pack_by_type(type_name: String) -> CardPackBase:
	# 根据类型字符串动态加载对应的卡包实例
	var pack: CardPackBase = null
	
	# 构建卡包文件路径
	var pack_path = "res://scripts/cards/prefabs/" + type_name.to_lower() + "_card_pack.gd"
	
	# 检查文件是否存在
	if ResourceLoader.exists(pack_path):
		# 尝试加载并创建卡包实例
		var pack_script = load(pack_path)
		if pack_script != null:
			pack = pack_script.new()
			GlobalUtil.log("成功加载卡包类型: " + type_name + ", 路径: " + pack_path, GlobalUtil.LogLevel.INFO)
		else:
			# 加载失败时的错误处理
			GlobalUtil.log("加载卡包失败: " + type_name + ", 路径: " + pack_path + ", 使用默认卡包", GlobalUtil.LogLevel.ERROR)
			pack = CardPackBase.new()
	else:
		# 文件不存在时的处理
		GlobalUtil.log("卡包文件不存在: " + pack_path + ", 使用默认卡包", GlobalUtil.LogLevel.WARNING)
		pack = CardPackBase.new()
	
	return pack

# 使用卡牌池创建卡牌（推荐使用）
static func create_card_from_pool(root_node: Node, type_name: String, target_position: Vector2) -> Node2D:
	# 从卡牌池获取卡牌
	var card = get_card_from_pool(root_node)
	
	# 加载卡牌数据
	card.load_from_card_type(type_name)
	
	# 瞬移到目标位置
	goto_card(card, target_position)
	
	GlobalUtil.log("使用卡牌池创建卡牌: " + type_name + " 位置: " + str(target_position), GlobalUtil.LogLevel.DEBUG)
	return card

# 移动卡牌到指定位置
static func move_card(card_instance: Node2D, target_position: Vector2, duration: float = GlobalConstants.DEFAULT_MOVE_DURATION):
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
	# 生成随机的x坐标（使用全局常量定义的范围，但不在中心避让范围内）
	var random_x: float = 0.0
	if randf() < 0.5:
		# 生成负方向的随机数
		random_x = randf_range(-GlobalConstants.RANDOM_MOVE_RANGE, -GlobalConstants.CENTER_AVOID_RANGE)
	else:
		# 生成正方向的随机数
		random_x = randf_range(GlobalConstants.CENTER_AVOID_RANGE, GlobalConstants.RANDOM_MOVE_RANGE)
	
	# 生成随机的y坐标（使用全局常量定义的范围，但不在中心避让范围内）
	var random_y: float = 0.0
	if randf() < 0.5:
		# 生成负方向的随机数
		random_y = randf_range(-GlobalConstants.RANDOM_MOVE_RANGE, -GlobalConstants.CENTER_AVOID_RANGE)
	else:
		# 生成正方向的随机数
		random_y = randf_range(GlobalConstants.CENTER_AVOID_RANGE, GlobalConstants.RANDOM_MOVE_RANGE)
	
	# 计算目标位置（相对当前位置）
	var target_position = card_instance.position + Vector2(random_x, random_y)
	
	# 调用move_card方法移动卡牌
	move_card(card_instance, target_position, GlobalConstants.DEFAULT_MOVE_DURATION)
	
	# 返回移动的距离向量
	return Vector2(random_x, random_y)

# 设置输入检测
func setup_input_detection():
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 调用 setup_input_detection() 函数", GlobalUtil.LogLevel.DEBUG)
	
	# 关键修复：设置所有Control节点的mouse_filter为IGNORE，避免阻挡输入事件
	var card_background = get_node("CardBackground")
	if card_background and card_background is Control:
		card_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 设置CardBackground mouse_filter为IGNORE", GlobalUtil.LogLevel.DEBUG)
	
	# 设置Label节点的mouse_filter
	var label_node = get_node("Label")
	if label_node and label_node is Control:
		label_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 设置Label mouse_filter为IGNORE", GlobalUtil.LogLevel.DEBUG)
	
	# 设置Description节点的mouse_filter
	var description_node = get_node("Description")
	if description_node and description_node is Control:
		description_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 设置Description mouse_filter为IGNORE", GlobalUtil.LogLevel.DEBUG)
	
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
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " Shape绝对坐标范围:", GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("  左边界:" + str(shape_left) + " 右边界:" + str(shape_right), GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("  上边界:" + str(shape_top) + " 下边界:" + str(shape_bottom), GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("  中心点:" + str(global_pos), GlobalUtil.LogLevel.DEBUG)
	
	# 连接输入事件
	click_area.input_event.connect(_on_card_input_event)
	# 连接鼠标进入和离开事件用于调试
	click_area.mouse_entered.connect(_on_mouse_entered)
	click_area.mouse_exited.connect(_on_mouse_exited)
	
	# 添加调试信息
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " Area2D设置完成:", GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("  - input_pickable:" + str(click_area.input_pickable), GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("  - collision_layer:" + str(click_area.collision_layer), GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("  - collision_mask:" + str(click_area.collision_mask), GlobalUtil.LogLevel.DEBUG)

# 处理卡牌输入事件
func _on_card_input_event(_viewport, event, _shape_idx):
	# 处理鼠标按钮事件
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 检测到鼠标左键按下", GlobalUtil.LogLevel.DEBUG)
			
			# 检查当前卡牌是否是点击位置的最上层卡牌
			var mouse_pos = get_global_mouse_position()
			if not is_top_card_at_position(mouse_pos):
				GlobalUtil.log("卡牌不是最上层，忽略点击事件", GlobalUtil.LogLevel.DEBUG)
				return
			
			# 记录鼠标按下时的位置
			mouse_press_position = get_global_mouse_position()
			
			# 停止当前活动的Tween动画，避免与拖拽冲突
			if active_tween != null and active_tween.is_valid():
				active_tween.kill()
				active_tween = null
				GlobalUtil.log("停止了正在进行的Tween动画", GlobalUtil.LogLevel.DEBUG)
			
			# 开始拖拽
			is_dragging = true
			has_brought_to_front = false  # 重置bring_to_front标志
			drag_offset = global_position - get_global_mouse_position()
			modulate.a = GlobalConstants.CARD_DRAG_ALPHA  # 拖拽时半透明效果
			
			# 获取需要连带拖拽的卡牌（当前卡牌上方的所有卡牌）
			dragging_cards = get_cards_above()
			
			# 为连带拖拽的卡牌设置半透明效果和记录相对位置
			for card in dragging_cards:
				if card != null and is_instance_valid(card):
					card.modulate.a = GlobalConstants.CARD_DRAG_ALPHA
					# 记录相对于主拖拽卡牌的偏移量
					card.drag_offset = card.global_position - global_position
			
			GlobalUtil.log("开始拖拽卡牌，偏移量:" + str(drag_offset) + "，连带卡牌数量:" + str(dragging_cards.size()), GlobalUtil.LogLevel.DEBUG)


# 全局输入处理，用于处理拖拽时的鼠标释放事件
func _input(event):
	# 只有在拖拽状态下才处理全局输入
	if not is_dragging:
		return
		
	# 处理鼠标释放事件
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		# 计算拖动距离
		var mouse_release_position = get_global_mouse_position()
		var drag_distance = mouse_press_position.distance_to(mouse_release_position)
		
		GlobalUtil.log("鼠标抬起，拖动距离:" + str(drag_distance), GlobalUtil.LogLevel.DEBUG)
		
		# 如果拖动距离小于阈值，认为是点击而不是拖动
		if drag_distance < GlobalConstants.DRAG_THRESHOLD:
			# 触发卡牌的个性化点击效果
			if on_click.is_valid():
				GlobalUtil.log("触发卡牌点击效果", GlobalUtil.LogLevel.DEBUG)
				on_click.call(self)
			
			# 打印卡牌信息
			print_card_info()
		else:
			GlobalUtil.log("检测到拖动行为，不触发点击效果", GlobalUtil.LogLevel.DEBUG)
			# 检查是否可以堆叠到其他卡牌上
			check_and_stack_card()
		
		# 结束拖拽
		is_dragging = false
		modulate.a = GlobalConstants.CARD_NORMAL_ALPHA  # 恢复透明度
		
		# 恢复连带拖拽卡牌的透明度
		for card in dragging_cards:
			if card != null and is_instance_valid(card):
				card.modulate.a = GlobalConstants.CARD_NORMAL_ALPHA
		
		GlobalUtil.log("卡牌拖拽结束，最终位置:" + str(global_position) + "，连带卡牌数量:" + str(dragging_cards.size()), GlobalUtil.LogLevel.DEBUG)

# 每帧更新，用于处理拖拽时的位置跟随
func _process(_delta):
	# 如果正在拖拽，更新卡牌位置跟随鼠标
	if is_dragging:
		# 检查是否已经移动了足够的距离，如果是则将卡牌组移到最前面
		if not has_brought_to_front:
			var current_mouse_pos = get_global_mouse_position()
			var drag_distance = mouse_press_position.distance_to(current_mouse_pos)
			if drag_distance >= GlobalConstants.DRAG_THRESHOLD:
				# 确认是拖动行为，将主卡牌移到最前面
				bring_to_front()
				
				# 将所有连带拖拽的卡牌依次移到最前面
				for card in dragging_cards:
					if card != null and is_instance_valid(card):
						card.bring_to_front()
				
				has_brought_to_front = true
				GlobalUtil.log("检测到拖动行为，将卡牌组移到最前面，主卡牌+连带卡牌数量:" + str(1 + dragging_cards.size()), GlobalUtil.LogLevel.DEBUG)
		
		global_position = get_global_mouse_position() + drag_offset
		
		# 更新连带拖拽卡牌的位置
		for card in dragging_cards:
			if card != null and is_instance_valid(card):
				card.global_position = global_position + card.drag_offset

# 鼠标进入事件（调试用）
func _on_mouse_entered():
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 鼠标进入卡牌区域", GlobalUtil.LogLevel.DEBUG)

# 鼠标离开事件（调试用）
func _on_mouse_exited():
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 鼠标离开卡牌区域", GlobalUtil.LogLevel.DEBUG)

# 打印卡牌信息
func print_card_info():
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 调用 print_card_info() 函数", GlobalUtil.LogLevel.DEBUG)
	GlobalUtil.log("===== 卡牌信息 =====", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("名称: " + card_name, GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("描述: " + description, GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("层级: " + str(card_layer), GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("z_index: " + str(z_index), GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("位置: " + str(global_position), GlobalUtil.LogLevel.INFO)
	if card_pack:
		GlobalUtil.log("卡包: " + card_pack.pack_name, GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("===================", GlobalUtil.LogLevel.INFO)
	
	# 打印所有卡牌的调试信息
	GlobalUtil.log(get_all_cards_debug_info(), GlobalUtil.LogLevel.INFO)

# ==================== 卡牌池管理系统 ====================

# 初始化卡牌池
static func initialize_card_pool(root_node: Node):
	if is_pool_initialized:
		return
	
	GlobalUtil.log("开始初始化卡牌池，大小: " + str(pool_size), GlobalUtil.LogLevel.INFO)
	
	# 加载卡牌场景
	var card_scene = preload("res://scenes/card.tscn")
	
	# 创建预加载的卡牌
	for i in range(pool_size):
		var card_instance = card_scene.instantiate()
		
		# 设置隐藏位置
		card_instance.position = hidden_position
		
		# 添加到场景树但隐藏
		root_node.add_child(card_instance)
		
		# 添加到卡牌池
		card_pool.append(card_instance)
		
		GlobalUtil.log("预加载卡牌 #" + str(i + 1) + " 完成", GlobalUtil.LogLevel.DEBUG)
	
	is_pool_initialized = true
	GlobalUtil.log("卡牌池初始化完成，共预加载 " + str(card_pool.size()) + " 张卡牌", GlobalUtil.LogLevel.INFO)

# 从卡牌池获取一张卡牌
static func get_card_from_pool(root_node: Node) -> Node2D:
	# 确保卡牌池已初始化
	if not is_pool_initialized:
		initialize_card_pool(root_node)
	
	# 如果池中有可用卡牌，直接返回
	if card_pool.size() > 0:
		var card = card_pool.pop_front()
		GlobalUtil.log("从卡牌池获取卡牌，剩余: " + str(card_pool.size()), GlobalUtil.LogLevel.DEBUG)
		return card
	
	# 如果池为空，创建新卡牌
	GlobalUtil.log("卡牌池为空，创建新卡牌", GlobalUtil.LogLevel.DEBUG)
	var card_scene = preload("res://scenes/card.tscn")
	var card_instance = card_scene.instantiate()
	card_instance.position = hidden_position
	root_node.add_child(card_instance)
	return card_instance

# 将卡牌返回到池中
static func return_card_to_pool(card: Node2D):
	if card == null or not is_instance_valid(card):
		return
	
	# 重置卡牌状态
	card.position = hidden_position
	card.card_name = "未命名卡牌"
	card.description = "无描述"
	card.card_image = null
	card.card_pack = null
	card.on_click = Callable()  # 重置点击效果
	card.is_dragging = false
	card.modulate.a = GlobalConstants.CARD_NORMAL_ALPHA
	
	# 停止所有动画
	if card.active_tween != null and card.active_tween.is_valid():
		card.active_tween.kill()
		card.active_tween = null
	
	# 更新显示
	if card.has_method("update_display"):
		card.update_display()
	
	# 返回到池中
	card_pool.append(card)
	GlobalUtil.log("卡牌已返回池中，池大小: " + str(card_pool.size()), GlobalUtil.LogLevel.DEBUG)

# 瞬移卡牌到目标位置
static func goto_card(card: Node2D, target_position: Vector2):
	if card == null or not is_instance_valid(card):
		GlobalUtil.log("goto_card: 无效的卡牌实例", GlobalUtil.LogLevel.ERROR)
		return
	
	# 停止当前动画
	if card.active_tween != null and card.active_tween.is_valid():
		card.active_tween.kill()
		card.active_tween = null
	
	# 瞬移到目标位置
	card.position = target_position
	
	# 将卡牌移到最上层
	if card.has_method("bring_to_front"):
		card.bring_to_front()
	
	GlobalUtil.log("卡牌瞬移到位置: " + str(target_position), GlobalUtil.LogLevel.DEBUG)

# 获取卡牌池状态信息
static func get_card_pool_info() -> String:
	var info = "=== 卡牌池状态 ===\n"
	info += "池大小: " + str(pool_size) + "\n"
	info += "已初始化: " + str(is_pool_initialized) + "\n"
	info += "可用卡牌: " + str(card_pool.size()) + "\n"
	info += "隐藏位置: " + str(hidden_position) + "\n"
	info += "================\n"
	return info

# ==================== 卡牌堆叠系统 ====================

# 检查并尝试将当前卡牌堆叠到其他卡牌上
func check_and_stack_card():
	var current_pos = global_position
	var target_card = find_stackable_card_at_position(current_pos)
	
	if target_card != null and target_card != self:
		GlobalUtil.log("找到可堆叠的目标卡牌: " + target_card.card_name, GlobalUtil.LogLevel.DEBUG)
		stack_card_group_on_target(target_card)
	else:
		GlobalUtil.log("未找到可堆叠的目标卡牌", GlobalUtil.LogLevel.DEBUG)
		# 如果没有找到目标卡牌，检查是否有连带拖拽的卡牌
		if dragging_cards.size() > 0:
			# 创建新的堆叠
			create_new_stack_with_cards()
		else:
			# 如果只是单张卡牌，移除原有堆叠关系
			remove_from_current_stack()
	
	# 清空连带拖拽卡牌列表
	dragging_cards.clear()

# 在指定位置查找可以堆叠的卡牌
func find_stackable_card_at_position(pos: Vector2) -> Node2D:
	var closest_card: Node2D = null
	var closest_distance: float = GlobalConstants.CARD_STACK_DETECTION_RANGE
	
	for card in all_cards:
		if card == null or not is_instance_valid(card) or card == self:
			continue
		
		# 排除连带拖拽的卡牌
		if card in dragging_cards:
			continue
		
		# 计算卡牌中心之间的距离
		var distance = pos.distance_to(card.global_position)
		
		# 如果在检测范围内且距离更近
		if distance < closest_distance:
			closest_distance = distance
			closest_card = card
	
	return closest_card

# 将当前卡牌堆叠到目标卡牌上
func stack_card_on_target(target_card: Node2D):
	var target_instance_id = target_card.get_instance_id()
	var current_instance_id = get_instance_id()
	
	# 移除当前卡牌的旧堆叠关系
	remove_from_current_stack()
	
	# 获取或创建目标卡牌的堆叠
	var target_stack_id = get_or_create_stack_for_card(target_card)
	
	# 将当前卡牌添加到堆叠中
	card_stacks[target_stack_id].append(self)
	card_to_stack[current_instance_id] = target_stack_id
	stack_id = target_stack_id
	
	# 更新堆叠中所有卡牌的位置
	update_stack_positions(target_stack_id)
	
	GlobalUtil.log("卡牌 " + card_name + " 已堆叠到 " + target_card.card_name + " 上，堆叠ID: " + str(target_stack_id), GlobalUtil.LogLevel.INFO)

# 将卡牌组（主卡牌和连带卡牌）堆叠到目标卡牌上
func stack_card_group_on_target(target_card: Node2D):
	# 获取或创建目标卡牌的堆叠
	var target_stack_id = get_or_create_stack_for_card(target_card)
	
	# 首先处理主卡牌
	remove_from_current_stack()
	
	# 确保目标堆叠仍然存在（可能在remove_from_current_stack中被删除）
	if not target_stack_id in card_stacks:
		# 重新创建目标堆叠
		target_stack_id = get_or_create_stack_for_card(target_card)
	
	card_stacks[target_stack_id].append(self)
	card_to_stack[get_instance_id()] = target_stack_id
	stack_id = target_stack_id
	
	# 然后处理连带拖拽的卡牌
	for card in dragging_cards:
		if card != null and is_instance_valid(card):
			# 移除连带卡牌的旧堆叠关系
			card.remove_from_current_stack()
			
			# 确保目标堆叠仍然存在
			if not target_stack_id in card_stacks:
				target_stack_id = get_or_create_stack_for_card(target_card)
			
			# 添加到目标堆叠
			card_stacks[target_stack_id].append(card)
			card_to_stack[card.get_instance_id()] = target_stack_id
			card.stack_id = target_stack_id
	
	# 更新堆叠中所有卡牌的位置
	update_stack_positions(target_stack_id)
	
	GlobalUtil.log("卡牌组已堆叠到 " + target_card.card_name + " 上，主卡牌: " + card_name + "，连带卡牌数: " + str(dragging_cards.size()), GlobalUtil.LogLevel.INFO)

# 创建新的堆叠包含主卡牌和连带卡牌
func create_new_stack_with_cards():
	# 移除主卡牌的旧堆叠关系
	remove_from_current_stack()
	
	# 创建新堆叠
	var new_stack_id = stack_id_counter
	stack_id_counter += 1
	
	# 初始化堆叠，主卡牌作为底牌
	card_stacks[new_stack_id] = [self]
	card_to_stack[get_instance_id()] = new_stack_id
	stack_id = new_stack_id
	
	# 添加连带拖拽的卡牌
	for card in dragging_cards:
		if card != null and is_instance_valid(card):
			# 移除连带卡牌的旧堆叠关系
			card.remove_from_current_stack()
			# 添加到新堆叠
			card_stacks[new_stack_id].append(card)
			card_to_stack[card.get_instance_id()] = new_stack_id
			card.stack_id = new_stack_id
	
	# 更新堆叠中所有卡牌的位置
	update_stack_positions(new_stack_id)
	
	GlobalUtil.log("创建新堆叠，ID: " + str(new_stack_id) + "，主卡牌: " + card_name + "，连带卡牌数: " + str(dragging_cards.size()), GlobalUtil.LogLevel.INFO)

# 获取或创建卡牌的堆叠ID
static func get_or_create_stack_for_card(card: Node2D) -> int:
	var card_instance_id = card.get_instance_id()
	
	# 如果卡牌已经在堆叠中，返回其堆叠ID
	if card_instance_id in card_to_stack:
		return card_to_stack[card_instance_id]
	
	# 创建新的堆叠
	var new_stack_id = stack_id_counter
	stack_id_counter += 1
	
	# 初始化堆叠
	card_stacks[new_stack_id] = [card]
	card_to_stack[card_instance_id] = new_stack_id
	card.stack_id = new_stack_id
	
	GlobalUtil.log("为卡牌 " + card.card_name + " 创建新堆叠，ID: " + str(new_stack_id), GlobalUtil.LogLevel.DEBUG)
	return new_stack_id

# 从当前堆叠中移除卡牌
func remove_from_current_stack():
	var current_instance_id = get_instance_id()
	
	# 如果不在任何堆叠中，直接返回
	if not current_instance_id in card_to_stack:
		return
	
	var old_stack_id = card_to_stack[current_instance_id]
	
	# 从堆叠中移除当前卡牌
	if old_stack_id in card_stacks:
		card_stacks[old_stack_id].erase(self)
		
		# 检查堆叠剩余卡牌数量
		var remaining_cards = card_stacks[old_stack_id]
		if remaining_cards.size() == 0:
			# 堆叠为空，删除堆叠
			card_stacks.erase(old_stack_id)
			GlobalUtil.log("删除空堆叠，ID: " + str(old_stack_id), GlobalUtil.LogLevel.DEBUG)
		elif remaining_cards.size() == 1:
			# 只剩一张卡牌，清除整个堆叠
			var last_card = remaining_cards[0]
			if last_card != null and is_instance_valid(last_card):
				# 移除最后一张卡牌的堆叠映射
				var last_card_id = last_card.get_instance_id()
				card_to_stack.erase(last_card_id)
				last_card.stack_id = -1
				GlobalUtil.log("卡牌 " + last_card.card_name + " 不再属于任何堆叠", GlobalUtil.LogLevel.DEBUG)
			
			# 删除堆叠
			card_stacks.erase(old_stack_id)
			GlobalUtil.log("堆叠只剩一张卡牌，清除堆叠，ID: " + str(old_stack_id), GlobalUtil.LogLevel.DEBUG)
		else:
			# 多张卡牌，更新剩余卡牌的位置
			update_stack_positions(old_stack_id)
	
	# 移除当前卡牌的映射关系
	card_to_stack.erase(current_instance_id)
	stack_id = -1
	
	GlobalUtil.log("卡牌 " + card_name + " 已从堆叠 " + str(old_stack_id) + " 中移除", GlobalUtil.LogLevel.DEBUG)

# 更新堆叠中所有卡牌的位置
static func update_stack_positions(stack_id: int):
	if not stack_id in card_stacks:
		return
	
	var stack = card_stacks[stack_id]
	if stack.size() == 0:
		return
	
	# 底部卡牌保持原位置
	var base_card = stack[0]
	var base_position = base_card.global_position
	
	# 更新堆叠中每张卡牌的位置和层级
	for i in range(stack.size()):
		var card = stack[i]
		if card == null or not is_instance_valid(card):
			continue
		
		# 计算位置偏移
		var offset_y = i * GlobalConstants.CARD_STACK_OFFSET
		card.global_position = base_position + Vector2(0, offset_y)
		
		# 更新层级，确保上层卡牌在前面
		card.bring_to_front()
		
		GlobalUtil.log("更新堆叠卡牌位置: " + card.card_name + " 位置: " + str(card.global_position), GlobalUtil.LogLevel.DEBUG)

# 获取堆叠系统调试信息
static func get_stack_debug_info() -> String:
	var info = "=== 卡牌堆叠状态 ===\n"
	info += "堆叠总数: " + str(card_stacks.size()) + "\n"
	info += "卡牌映射数: " + str(card_to_stack.size()) + "\n"
	
	for stack_id in card_stacks.keys():
		var stack = card_stacks[stack_id]
		info += "堆叠 " + str(stack_id) + ": " + str(stack.size()) + " 张卡牌\n"
		for i in range(stack.size()):
			var card = stack[i]
			if card != null and is_instance_valid(card):
				info += "  [" + str(i) + "] " + card.card_name + "\n"
	
	info += "==================\n"
	return info

# 清理无效的堆叠引用
static func cleanup_invalid_stacks():
	var stacks_to_remove: Array[int] = []
	var mappings_to_remove: Array[Node2D] = []
	
	# 检查堆叠中的无效卡牌
	for stack_id in card_stacks.keys():
		var stack = card_stacks[stack_id]
		var valid_cards: Array[Node2D] = []
		
		for card in stack:
			if card != null and is_instance_valid(card):
				valid_cards.append(card)
		
		# 更新堆叠或标记删除
		if valid_cards.size() == 0:
			stacks_to_remove.append(stack_id)
		else:
			card_stacks[stack_id] = valid_cards
	
	# 检查映射中的无效卡牌
	for instance_id in card_to_stack.keys():
		var found = false
		for card in all_cards:
			if card != null and is_instance_valid(card) and card.get_instance_id() == instance_id:
				found = true
				break
		
		if not found:
			mappings_to_remove.append(instance_id)
	
	# 移除无效的堆叠和映射
	for stack_id in stacks_to_remove:
		card_stacks.erase(stack_id)
	
	for instance_id in mappings_to_remove:
		card_to_stack.erase(instance_id)
	
	GlobalUtil.log("清理堆叠系统: 移除 " + str(stacks_to_remove.size()) + " 个无效堆叠, " + str(mappings_to_remove.size()) + " 个无效映射", GlobalUtil.LogLevel.DEBUG)

# 获取当前卡牌上方的所有卡牌（用于连带拖拽）
func get_cards_above() -> Array[Node2D]:
	var cards_above: Array[Node2D] = []
	var current_instance_id = get_instance_id()
	
	# 如果当前卡牌不在任何堆叠中，返回空数组
	if not current_instance_id in card_to_stack:
		return cards_above
	
	var current_stack_id = card_to_stack[current_instance_id]
	
	# 如果堆叠不存在，返回空数组
	if not current_stack_id in card_stacks:
		return cards_above
	
	var stack = card_stacks[current_stack_id]
	var current_index = -1
	
	# 找到当前卡牌在堆叠中的位置
	for i in range(stack.size()):
		if stack[i] == self:
			current_index = i
			break
	
	# 如果找到了当前卡牌的位置，获取其上方的所有卡牌
	if current_index >= 0:
		for i in range(current_index + 1, stack.size()):
			if stack[i] != null and is_instance_valid(stack[i]):
				cards_above.append(stack[i])
	
	GlobalUtil.log("获取到 " + str(cards_above.size()) + " 张上方卡牌", GlobalUtil.LogLevel.DEBUG)
	return cards_above
