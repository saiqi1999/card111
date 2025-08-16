extends Node2D
# 通用容器类

# 容器实例的引用
static var current_container: Node2D = null

# 容器固定大小（使用全局常量）
const CONTAINER_SIZE: Vector2 = Vector2(GlobalConstants.CONTAINER_WIDTH, GlobalConstants.CONTAINER_HEIGHT)

# 召唤此容器的卡牌引用
var summoner_card: Node2D = null

# 初始化函数
func _ready():
	# 设置容器为可见
	visible = true
	# 记录当前容器实例
	current_container = self
	GlobalUtil.log("通用容器创建，实例ID: " + str(get_instance_id()), GlobalUtil.LogLevel.INFO)

# 静态方法：移除当前容器
static func remove_current_container():
	if current_container != null:
		GlobalUtil.log("移除通用容器，实例ID: " + str(current_container.get_instance_id()), GlobalUtil.LogLevel.INFO)
		current_container.queue_free()
		current_container = null

# 静态方法：检查是否存在容器
static func has_container() -> bool:
	return current_container != null

# 设置召唤此容器的卡牌
func set_summoner_card(card: Node2D):
	summoner_card = card
	GlobalUtil.log("容器设置召唤卡牌，卡牌实例ID: " + str(card.get_instance_id()), GlobalUtil.LogLevel.DEBUG)

# 处理输入事件（使用_unhandled_input确保在UI元素处理后执行）
func _unhandled_input(event):
	# 检查是否点击了鼠标左键（按下时）
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 获取鼠标位置
		var mouse_pos = get_global_mouse_position()
		# 检查鼠标是否在容器范围内（Sprite2D以中心为锚点）
		var container_rect = Rect2(global_position - CONTAINER_SIZE / 2, CONTAINER_SIZE)
		GlobalUtil.log("容器点击检测 - 鼠标位置: " + str(mouse_pos) + ", 容器矩形: " + str(container_rect), GlobalUtil.LogLevel.DEBUG)
		if container_rect.has_point(mouse_pos):
			# 点击了容器内部，不移除容器
			GlobalUtil.log("点击了容器内部，保持容器显示", GlobalUtil.LogLevel.DEBUG)
			return
		else:
			# 检查鼠标下是否有其他Control节点（如卡牌、按钮等）
			var gui_input_captured = false
			
			# 遍历场景树中的所有Control节点，检查是否有节点在鼠标位置
			var root_node = get_tree().current_scene
			if root_node:
				gui_input_captured = _check_control_at_position(root_node, mouse_pos)
			
			# 检查是否点击了召唤此容器的卡牌
			var clicked_summoner = _check_summoner_card_clicked(mouse_pos)
			
			if clicked_summoner:
				# 点击了召唤卡牌，移除容器（不标记事件已处理，允许卡牌拖动）
				GlobalUtil.log("点击了召唤卡牌，移除通用容器", GlobalUtil.LogLevel.INFO)
				remove_current_container()
			elif not gui_input_captured:
				# 点击的是空白区域，移除容器
				GlobalUtil.log("点击空白区域，移除通用容器", GlobalUtil.LogLevel.INFO)
				remove_current_container()
				# 标记事件已处理
				get_viewport().set_input_as_handled()
			else:
				# 点击了其他卡牌或UI元素，不移除容器
				GlobalUtil.log("点击了其他UI元素，保持容器显示", GlobalUtil.LogLevel.DEBUG)

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
	var collision_shape = click_area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		GlobalUtil.log("ClickArea没有CollisionShape2D节点", GlobalUtil.LogLevel.DEBUG)
		return false
	
	if collision_shape.shape == null:
		GlobalUtil.log("CollisionShape2D没有shape", GlobalUtil.LogLevel.DEBUG)
		return false
	
	GlobalUtil.log("找到碰撞形状", GlobalUtil.LogLevel.DEBUG)
	
	# 将鼠标位置转换为卡牌的本地坐标
	var local_pos = summoner_card.to_local(pos)
	GlobalUtil.log("鼠标本地坐标: " + str(local_pos), GlobalUtil.LogLevel.DEBUG)
	
	# 检查是否在碰撞形状内
	var shape_rect = collision_shape.shape.get_rect()
	GlobalUtil.log("碰撞形状矩形: " + str(shape_rect), GlobalUtil.LogLevel.DEBUG)
	
	if shape_rect.has_point(local_pos):
		GlobalUtil.log("检测到点击了召唤卡牌，卡牌实例ID: " + str(summoner_card.get_instance_id()), GlobalUtil.LogLevel.INFO)
		return true
	else:
		GlobalUtil.log("鼠标位置不在召唤卡牌范围内", GlobalUtil.LogLevel.DEBUG)
	
	return false

# 备用输入处理（高优先级，确保能捕获到所有点击）
func _input(event):
	# 检查是否点击了鼠标左键（按下时）
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 获取鼠标位置
		var mouse_pos = get_global_mouse_position()
		# 检查鼠标是否在容器范围内（Sprite2D以中心为锚点）
		var container_rect = Rect2(global_position - CONTAINER_SIZE / 2, CONTAINER_SIZE)
		GlobalUtil.log("容器点击检测(_input) - 鼠标位置: " + str(mouse_pos) + ", 容器矩形: " + str(container_rect), GlobalUtil.LogLevel.DEBUG)
		if container_rect.has_point(mouse_pos):
			# 点击了容器内部，不移除容器
			GlobalUtil.log("点击了容器内部(_input)，保持容器显示", GlobalUtil.LogLevel.DEBUG)
			return
		else:
			# 检查鼠标下是否有其他Control节点
			var gui_input_captured = false
			var root_node = get_tree().current_scene
			if root_node:
				gui_input_captured = _check_control_at_position(root_node, mouse_pos)
			
			# 检查是否点击了召唤此容器的卡牌
			var clicked_summoner = _check_summoner_card_clicked(mouse_pos)
			
			if clicked_summoner:
				# 点击了召唤卡牌，移除容器（不标记事件已处理，允许卡牌拖动）
				GlobalUtil.log("通过_input检测到召唤卡牌点击，移除通用容器", GlobalUtil.LogLevel.INFO)
				remove_current_container()
			elif not gui_input_captured:
				# 只有点击空白区域才移除容器
				GlobalUtil.log("通过_input检测到空白区域点击，移除通用容器", GlobalUtil.LogLevel.INFO)
				remove_current_container()
