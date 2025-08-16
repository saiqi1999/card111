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
var on_click: Callable = Callable()  # 卡牌点击时的个性化效果

# 卡包引用
var card_pack: CardPackBase = null

# 卡牌拖拽相关变量
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
# 存储当前活动的Tween引用，用于在拖拽时停止动画
var active_tween: Tween = null

# 卡牌层级管理
static var card_layer_counter: int = 0  # 全局层级计数器
var card_layer: int = 0  # 当前卡牌的层级
static var all_cards: Array[Node2D] = []  # 所有卡牌实例的引用

# 卡牌池系统
static var card_pool: Array[Node2D] = []  # 预加载的卡牌池
static var pool_size: int = 5  # 卡牌池大小
static var is_pool_initialized: bool = false  # 卡牌池是否已初始化
static var hidden_position: Vector2 = Vector2(-1000, -1000)  # 隐藏位置

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

# 清理无效的卡牌引用（静态函数）
static func cleanup_invalid_cards():
	var valid_cards: Array[Node2D] = []
	
	for card in all_cards:
		if card != null and is_instance_valid(card):
			valid_cards.append(card)
	
	all_cards = valid_cards
	GlobalUtil.log("清理无效卡牌引用，当前有效卡牌数量:" + str(all_cards.size()), GlobalUtil.LogLevel.DEBUG)

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
	GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 调用 setup_input_detection() 函数", GlobalUtil.LogLevel.DEBUG)
	
	# 关键修复：设置所有Control节点的mouse_filter为IGNORE，避免阻挡输入事件
	var card_background = get_node("CardBackground")
	if card_background and card_background is Control:
		card_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 设置CardBackground mouse_filter为IGNORE", GlobalUtil.LogLevel.DEBUG)
	
	# 设置Label节点的mouse_filter
	var label = get_node("Label")
	if label and label is Control:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 设置Label mouse_filter为IGNORE", GlobalUtil.LogLevel.DEBUG)
	
	# 设置Description节点的mouse_filter
	var description = get_node("Description")
	if description and description is Control:
		description.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
			GlobalUtil.log("卡牌实例ID:" + str(get_instance_id()) + " 检测到鼠标左键点击", GlobalUtil.LogLevel.DEBUG)
			
			# 检查当前卡牌是否是点击位置的最上层卡牌
			var mouse_pos = get_global_mouse_position()
			if not is_top_card_at_position(mouse_pos):
				GlobalUtil.log("卡牌不是最上层，忽略点击事件", GlobalUtil.LogLevel.DEBUG)
				return
			
			# 触发卡牌的个性化点击效果
			if on_click.is_valid():
				GlobalUtil.log("触发卡牌点击效果", GlobalUtil.LogLevel.DEBUG)
				on_click.call(self)
			
			# 打印卡牌信息
			print_card_info()
			
			# 将当前卡牌移动到最上层
			bring_to_front()
			
			# 停止当前活动的Tween动画，避免与拖拽冲突
			if active_tween != null and active_tween.is_valid():
				active_tween.kill()
				active_tween = null
				GlobalUtil.log("停止了正在进行的Tween动画", GlobalUtil.LogLevel.DEBUG)
			
			# 开始拖拽
			is_dragging = true
			drag_offset = global_position - get_global_mouse_position()
			modulate.a = 0.8  # 拖拽时半透明效果
			GlobalUtil.log("开始拖拽卡牌，偏移量:" + str(drag_offset), GlobalUtil.LogLevel.DEBUG)

# 全局输入处理，用于处理拖拽时的鼠标释放事件
func _input(event):
	# 只有在拖拽状态下才处理全局输入
	if not is_dragging:
		return
		
	# 处理鼠标释放事件
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		# 结束拖拽
		is_dragging = false
		modulate.a = 1.0  # 恢复透明度
		GlobalUtil.log("卡牌拖拽结束，最终位置:" + str(global_position), GlobalUtil.LogLevel.DEBUG)

# 每帧更新，用于处理拖拽时的位置跟随
func _process(_delta):
	# 如果正在拖拽，更新卡牌位置跟随鼠标
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset

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
	card.modulate.a = 1.0
	
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
