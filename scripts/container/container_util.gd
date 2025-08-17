extends Node2D
class_name ContainerUtil

# 容器工具类
# 用于显示容器的视觉表现和提供容器相关工具函数

# 容器实例的静态管理
static var current_container: ContainerUtil = null

# 容器属性
var container_name: String = "未命名容器"
var description: String = "无描述"
# 容器基本属性
var container_width: float = GlobalConstants.CONTAINER_WIDTH
var container_height: float = GlobalConstants.CONTAINER_HEIGHT
var container_texture: Texture2D = null
var on_click: Callable = Callable()  # 容器点击时的个性化效果

# 容器包引用
var container_pack: ContainerBase = null

# 召唤此容器的卡牌引用
var summoner_card: Node2D = null

# 节点引用
var background: Sprite2D
var area_2d: Area2D
var collision_shape: CollisionShape2D
var title_label: Label
var description_label: Label

func _ready():
	# Node2D类型不需要设置mouse_filter
	GlobalUtil.log("容器初始化开始", GlobalUtil.LogLevel.DEBUG)
	
	# 设置容器的z_index为上层，确保容器及其UI元素显示在卡牌上方
	z_index = GlobalConstants.CONTAINER_Z_INDEX
	GlobalUtil.log("容器设置z_index为" + str(GlobalConstants.CONTAINER_Z_INDEX) + "，显示在卡牌上方", GlobalUtil.LogLevel.DEBUG)
	
	# 移除已存在的容器（确保场上只能存在一个容器）
	if current_container != null and current_container != self:
		GlobalUtil.log("移除已存在的容器，实例ID: " + str(current_container.get_instance_id()), GlobalUtil.LogLevel.INFO)
		current_container.queue_free()
	
	# 记录当前容器实例
	current_container = self
	GlobalUtil.log("容器创建，实例ID: " + str(get_instance_id()) + ", 尺寸: " + str(container_width) + "x" + str(container_height), GlobalUtil.LogLevel.INFO)
	
	# 初始化容器
	setup_container()
	# 连接信号
	connect_signals()
	# 居中显示
	center_container()
	# 更新显示（确保纹理正确设置）
	update_display()

func setup_container():
	"""设置容器的基本结构"""
	# 创建背景节点（使用Sprite2D与卡牌保持一致）
	background = Sprite2D.new()
	background.name = "Background"
	# Sprite2D不需要设置mouse_filter，因为它不是Control节点
	GlobalUtil.log("容器背景使用Sprite2D，与卡牌保持一致", GlobalUtil.LogLevel.DEBUG)
	add_child(background)
	
	# 创建点击检测区域（与卡牌保持一致的方式）
	area_2d = Area2D.new()
	area_2d.name = "ClickArea"
	# 关键设置：启用输入检测
	area_2d.input_pickable = true
	area_2d.monitoring = true
	area_2d.monitorable = true
	# 设置碰撞层，这是输入检测的关键要求
	area_2d.collision_layer = 1
	area_2d.collision_mask = 0  # 不需要检测碰撞，只需要输入
	GlobalUtil.log("容器Area2D设置完成，与卡牌保持一致", GlobalUtil.LogLevel.DEBUG)
	add_child(area_2d)
	
	# 将Area2D移动到最上层，确保点击检测优先级
	move_child(area_2d, get_child_count() - 1)
	
	# 创建碰撞形状
	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape"
	collision_shape.position = Vector2(0, 0)  # 确保碰撞形状位于容器中心
	area_2d.add_child(collision_shape)
	
	# 创建矩形形状
	var shape = RectangleShape2D.new()
	shape.size = Vector2(container_width, container_height)
	collision_shape.shape = shape
	
	# 创建标题Label
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "标题"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.position = Vector2(-container_width / 2, -container_height / 2 + 20)
	title_label.size = Vector2(container_width, 40)
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 不拦截鼠标事件
	add_child(title_label)
	GlobalUtil.log("创建容器标题Label", GlobalUtil.LogLevel.DEBUG)
	
	# 创建描述Label
	description_label = Label.new()
	description_label.name = "DescriptionLabel"
	description_label.text = "描述"
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	description_label.position = Vector2(-container_width / 2, -container_height / 2 + 70)
	description_label.size = Vector2(container_width, container_height - 100)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 14)
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 不拦截鼠标事件
	add_child(description_label)
	GlobalUtil.log("创建容器描述Label", GlobalUtil.LogLevel.DEBUG)
	
	GlobalUtil.log("容器工具类初始化完成，尺寸: " + str(container_width) + "x" + str(container_height), GlobalUtil.LogLevel.DEBUG)

func connect_signals():
	"""连接信号（与卡牌保持一致的方式）"""
	# 连接输入事件
	area_2d.input_event.connect(_on_container_input_event)
	# 连接鼠标进入和离开事件用于调试
	area_2d.mouse_entered.connect(_on_mouse_entered)
	area_2d.mouse_exited.connect(_on_mouse_exited)

func center_container():
	"""将容器居中显示"""
	# Node2D使用position属性进行定位
	if summoner_card != null:
		return
	position = GlobalConstants.SCREEN_CENTER
	GlobalUtil.log("容器居中显示，位置: " + str(position), GlobalUtil.LogLevel.DEBUG)

# 处理容器输入事件（与卡牌保持一致的方式）
func _on_container_input_event(_viewport, event, _shape_idx):
	"""处理容器点击事件"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 获取鼠标位置
			var mouse_pos = get_global_mouse_position()
			# 检查是否有卡牌在此位置
			var has_card_at_position = _check_card_at_position(mouse_pos)
			if has_card_at_position:
				# 容器内有卡牌，完全不处理事件，让卡牌正常接收
				GlobalUtil.log("点击了容器内部的卡牌，让卡牌处理事件", GlobalUtil.LogLevel.DEBUG)
				# 不拦截事件，让事件继续传播到卡牌
				return
			else:
				# 点击了容器内部的空白区域，保持容器显示
				GlobalUtil.log("点击了容器内部空白区域，保持容器显示", GlobalUtil.LogLevel.DEBUG)
				GlobalUtil.log(str(container_width) + "x" + str(container_height) + "容器被点击，容器实例ID: " + str(get_instance_id()), GlobalUtil.LogLevel.INFO)
				# 触发个性化点击效果
				if on_click.is_valid():
					on_click.call(self)
				# 只有点击空白区域时才拦截事件
				get_viewport().set_input_as_handled()

# 鼠标进入事件处理
func _on_mouse_entered():
	GlobalUtil.log("鼠标进入容器区域", GlobalUtil.LogLevel.DEBUG)

# 鼠标离开事件处理
func _on_mouse_exited():
	GlobalUtil.log("鼠标离开容器区域", GlobalUtil.LogLevel.DEBUG)

# 从容器包加载数据
func load_from_container_pack(pack: ContainerBase):
	container_pack = pack
	var data = pack.get_container_data()
	container_name = data["name"]
	description = data["description"]
	container_width = data["width"]
	container_height = data["height"]
	container_texture = data["texture"]
	on_click = data["on_click"]
	
	GlobalUtil.log("从容器包加载数据: " + container_name, GlobalUtil.LogLevel.DEBUG)
	
	# 调用update_display统一处理显示更新
	update_display()
	
	# 如果容器包有标题和描述属性，则设置到UI元素中
	if "title_text" in pack and "description_text" in pack:
		set_title_and_description_ui(pack.title_text, pack.description_text)
	else:
		pass
	
	# 如果是大容器，创建特有的UI元素（在update_display之后）
	if pack is ContainerBig:
		var big_container = pack as ContainerBig
		big_container.create_big_container_ui(self)
		GlobalUtil.log("为大容器创建特有UI元素", GlobalUtil.LogLevel.DEBUG)

# 通过类型字符串加载容器
func load_from_container_type(type: String):
	var pack = get_container_pack_by_type(type)
	if pack:
		load_from_container_pack(pack)
	else:
		GlobalUtil.log("未找到容器类型: " + type, GlobalUtil.LogLevel.ERROR)

# 设置容器数据
func set_container_data(p_name: String, p_description: String, texture: Texture2D = null, click_callback: Callable = Callable()):
	container_name = p_name
	description = p_description
	if texture:
		container_texture = texture
	if click_callback.is_valid():
		on_click = click_callback
	update_display()

# 更新显示
func update_display():
	if background and container_texture:
		background.texture = container_texture
		background.position = Vector2(0, 0)  # Sprite2D以中心点为锚点
		# 计算缩放比例以适应容器尺寸
		if background.texture:
			var texture_size = background.texture.get_size()
			var scale_x = container_width / texture_size.x
			var scale_y = container_height / texture_size.y
			background.scale = Vector2(scale_x, scale_y)
			GlobalUtil.log("更新容器显示: " + container_name + "，缩放: " + str(background.scale), GlobalUtil.LogLevel.DEBUG)
	
	# 更新碰撞形状尺寸
	if collision_shape and collision_shape.shape:
		collision_shape.shape.size = Vector2(container_width, container_height)
		GlobalUtil.log("更新显示时同步碰撞形状尺寸: " + str(container_width) + "x" + str(container_height), GlobalUtil.LogLevel.DEBUG)

# 设置召唤此容器的卡牌
func set_summoner_card(card: Node2D):
	summoner_card = card
	GlobalUtil.log("容器设置召唤卡牌，卡牌实例ID: " + str(card.get_instance_id()), GlobalUtil.LogLevel.DEBUG)

# 设置标题和描述UI
func set_title_and_description_ui(title: String, desc: String):
	if title_label:
		title_label.text = title
		GlobalUtil.log("设置容器标题: " + title, GlobalUtil.LogLevel.DEBUG)
	if description_label:
		description_label.text = desc
		GlobalUtil.log("设置容器描述: " + desc, GlobalUtil.LogLevel.DEBUG)
	
	# 更新容器显示
	update_display()

# 静态方法：移除当前容器
static func remove_current_container():
	if current_container != null:
		GlobalUtil.log("移除当前容器，实例ID: " + str(current_container.get_instance_id()), GlobalUtil.LogLevel.INFO)
		current_container.queue_free()
		current_container = null

# 静态方法：检查是否存在容器
static func has_container() -> bool:
	return current_container != null

# 静态方法：通过类型字符串获取容器包实例
static func get_container_pack_by_type(type: String) -> ContainerBase:
	match type:
		"400x300":
			return preload("res://scripts/container/prefabs/container_400_300.gd").new()
		"1200x1000":
			return preload("res://scripts/container/prefabs/container_big.gd").new()
		_:
			GlobalUtil.log("未知的容器类型: " + type, GlobalUtil.LogLevel.ERROR)
			return null

# 处理输入事件（使用普通input处理方式）
func _input(event):
	# 检查是否点击了鼠标左键（按下时）
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 获取鼠标位置
		var mouse_pos = get_global_mouse_position()
		# 检查鼠标是否在容器范围内（Sprite2D以中心点为锚点）
		var container_rect = Rect2(
			global_position - Vector2(container_width / 2, container_height / 2),
			Vector2(container_width, container_height)
		)
		GlobalUtil.log("容器点击检测 - 鼠标位置: " + str(mouse_pos) + ", 容器矩形: " + str(container_rect), GlobalUtil.LogLevel.DEBUG)
		if not container_rect.has_point(mouse_pos):
			# 点击了容器外部，检查是否点击了召唤此容器的卡牌
			var clicked_summoner = _check_summoner_card_clicked(mouse_pos)
			
			# 检查鼠标下是否有其他可拖拽的卡牌或UI元素
			var has_draggable_element = _check_draggable_element_at_position(mouse_pos)
			
			if clicked_summoner:
				# 点击了召唤卡牌，移除容器（不标记事件已处理，允许卡牌拖动）
				GlobalUtil.log("点击了召唤卡牌，移除容器", GlobalUtil.LogLevel.INFO)
				remove_current_container()
				# 不标记事件已处理，让卡牌可以继续处理拖拽
			elif has_draggable_element:
				# 点击了其他可拖拽元素，不移除容器，也不标记事件已处理
				GlobalUtil.log("点击了可拖拽元素，保持容器显示", GlobalUtil.LogLevel.DEBUG)
			else:
				# 点击的是空白区域，移除容器
				GlobalUtil.log("点击空白区域，移除容器", GlobalUtil.LogLevel.INFO)
				remove_current_container()
				# 只有在空白区域点击时才标记事件已处理
				get_viewport().set_input_as_handled()

# 检查指定位置是否有卡牌的辅助函数
func _check_card_at_position(pos: Vector2) -> bool:
	# 检查场景树中的所有节点，寻找卡牌节点
	var root_node = get_tree().current_scene
	if root_node:
		return _check_card_node_recursive(root_node, pos)
	return false

# 递归检查节点是否为卡牌元素
func _check_card_node_recursive(node: Node, pos: Vector2) -> bool:
	# 跳过容器自身
	if node == self:
		return false
	
	# 检查是否是卡牌节点（通过脚本类型判断）
	if node.get_script() != null:
		var script_path = node.get_script().resource_path
		if script_path.ends_with("card_util.gd"):
			# 这是一个卡牌节点，检查是否在鼠标位置
			var click_area = node.get_node_or_null("ClickArea")
			if click_area and click_area is Area2D:
				var collision_shape = click_area.get_node_or_null("CollisionShape2D")
				if collision_shape and collision_shape.shape:
					# 将鼠标位置转换为卡牌的本地坐标
					var local_pos = node.to_local(pos)
					# 检查是否在碰撞形状内
					var shape_rect = collision_shape.shape.get_rect()
					if shape_rect.has_point(local_pos):
						GlobalUtil.log("检测到卡牌在鼠标位置: " + str(node.name) + ", 实例ID: " + str(node.get_instance_id()), GlobalUtil.LogLevel.DEBUG)
						return true
	
	# 递归检查子节点
	for child in node.get_children():
		if _check_card_node_recursive(child, pos):
			return true
	
	return false

# 检查指定位置是否有Area2D元素的辅助函数
func _check_draggable_element_at_position(pos: Vector2) -> bool:
	# 检查场景树中的所有节点，寻找Area2D节点
	var root_node = get_tree().current_scene
	if root_node:
		return _check_area2d_node_recursive(root_node, pos)
	return false

# 递归检查节点是否为Area2D元素
func _check_area2d_node_recursive(node: Node, pos: Vector2) -> bool:
	# 跳过容器自身
	if node == self:
		return false
	
	# 直接检查Area2D节点
	if node is Area2D and node.name == "ClickArea":
		var area_2d = node as Area2D
		# 检查Area2D是否启用了输入检测
		if area_2d.input_pickable:
			var collision_shape = area_2d.get_node_or_null("CollisionShape2D")
			if collision_shape and collision_shape.shape:
				# 将鼠标位置转换为Area2D的本地坐标
				var local_pos = area_2d.to_local(pos)
				# 对于RectangleShape2D，使用size属性创建矩形
				var shape_rect = Rect2(
					collision_shape.position - collision_shape.shape.size / 2,
					collision_shape.shape.size
				)
				GlobalUtil.log("检查Area2D碰撞: " + str(area_2d.get_parent().name) + ", 鼠标本地坐标: " + str(local_pos) + ", 碰撞矩形: " + str(shape_rect), GlobalUtil.LogLevel.DEBUG)
				if shape_rect.has_point(local_pos):
					GlobalUtil.log("检测到Area2D: " + str(area_2d.get_parent().name) + " 在鼠标位置", GlobalUtil.LogLevel.DEBUG)
					return true
	
	# 检查Control节点（可能是UI元素）
	if node is Control and node.visible and node != self:
		var control = node as Control
		# 只检查可能阻挡拖拽的Control节点
		if control.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			var rect = Rect2(control.global_position, control.size)
			if rect.has_point(pos):
				GlobalUtil.log("检测到Control节点: " + str(node.name) + " 在鼠标位置", GlobalUtil.LogLevel.DEBUG)
				return true
	
	# 递归检查子节点
	for child in node.get_children():
		if _check_area2d_node_recursive(child, pos):
			return true
	
	return false

# 检查指定位置是否有Control节点的辅助函数
func _check_control_at_position(node: Node, pos: Vector2) -> bool:
	# 如果是Control节点且可见，检查是否包含鼠标位置
	if node is Control and node.visible and node != self:
		var control = node as Control
		var rect = Rect2(control.global_position, control.size)
		if rect.has_point(pos):
			# 找到了包含鼠标位置的Control节点
			GlobalUtil.log("检测到Control节点: " + str(node.name) + " 在鼠标位置", GlobalUtil.LogLevel.DEBUG)
			return true
	
	# 递归检查子节点
	for child in node.get_children():
		if _check_control_at_position(child, pos):
			return true
	
	return false

# 注释：使用_input方法处理容器点击，通过Area2D的input_event处理容器内部点击
# 使用_input方法处理容器外部点击，确保正确的事件处理优先级

# 检查是否点击了召唤此容器的卡牌
func _check_summoner_card_clicked(pos: Vector2) -> bool:
	GlobalUtil.log("开始检查召唤卡牌点击，鼠标位置: " + str(pos), GlobalUtil.LogLevel.DEBUG)
	
	if summoner_card == null:
		GlobalUtil.log("召唤卡牌引用为null", GlobalUtil.LogLevel.DEBUG)
		return false
	
	if not is_instance_valid(summoner_card):
		GlobalUtil.log("召唤卡牌实例无效", GlobalUtil.LogLevel.DEBUG)
		return false
	
	GlobalUtil.log("召唤卡牌有效，实例ID: " + str(summoner_card.get_instance_id()), GlobalUtil.LogLevel.DEBUG)
	
	# 检查召唤卡牌是否有Area2D组件用于点击检测
	var click_area = summoner_card.get_node_or_null("ClickArea")
	if click_area == null:
		GlobalUtil.log("召唤卡牌没有ClickArea节点", GlobalUtil.LogLevel.DEBUG)
		return false
	
	if not (click_area is Area2D):
		GlobalUtil.log("ClickArea节点不是Area2D类型", GlobalUtil.LogLevel.DEBUG)
		return false
	
	GlobalUtil.log("找到ClickArea节点", GlobalUtil.LogLevel.DEBUG)
	
	# 获取Area2D的碰撞形状
	var collision_shape_node = click_area.get_node_or_null("CollisionShape2D")
	if collision_shape_node == null:
		GlobalUtil.log("ClickArea没有CollisionShape2D节点", GlobalUtil.LogLevel.DEBUG)
		return false
	
	if collision_shape_node.shape == null:
		GlobalUtil.log("CollisionShape2D没有shape", GlobalUtil.LogLevel.DEBUG)
		return false
	
	GlobalUtil.log("找到碰撞形状", GlobalUtil.LogLevel.DEBUG)
	
	# 将鼠标位置转换为卡牌的本地坐标
	var local_pos = summoner_card.to_local(pos)
	GlobalUtil.log("鼠标本地坐标: " + str(local_pos), GlobalUtil.LogLevel.DEBUG)
	
	# 检查是否在碰撞形状内
	var shape_rect = collision_shape_node.shape.get_rect()
	GlobalUtil.log("碰撞形状矩形: " + str(shape_rect), GlobalUtil.LogLevel.DEBUG)
	
	if shape_rect.has_point(local_pos):
		GlobalUtil.log("检测到点击了召唤卡牌，卡牌实例ID: " + str(summoner_card.get_instance_id()), GlobalUtil.LogLevel.INFO)
		return true
	else:
		GlobalUtil.log("鼠标位置不在召唤卡牌范围内", GlobalUtil.LogLevel.DEBUG)
	
	return false
