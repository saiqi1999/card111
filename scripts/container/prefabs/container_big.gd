extends ContainerBase
class_name ContainerBig

# 大容器类 - 1200x1000尺寸
# 用于展示更多元素的大型容器，包含确认按钮和卡槽

# UI元素引用
var confirm_button: Button
var card_slots: Array[Button] = []

# 初始化大容器
func _init():
	# 设置容器尺寸
	container_width = GlobalConstants.CONTAINER_BIG_WIDTH
	container_height = GlobalConstants.CONTAINER_BIG_HEIGHT
	
	# 设置容器纹理
	container_texture = preload("res://assets/images/frame.jpg")
	
	# 设置点击效果
	on_click = big_container_click_effect
	
	GlobalUtil.log("创建大容器实例，尺寸: " + str(container_width) + "x" + str(container_height), GlobalUtil.LogLevel.DEBUG)

# 获取容器类型标识
func get_container_type() -> String:
	return "1200x1000"

# 创建大容器特有的UI元素
func create_big_container_ui(container_util: ContainerUtil):
	# 调整标题字体大小
	if container_util.title_label:
		container_util.title_label.add_theme_font_size_override("font_size", GlobalConstants.UI_TITLE_FONT_SIZE)
		container_util.title_label.add_theme_color_override("font_color", Color.BLACK)
		# 确保标题显示在最上层
		container_util.title_label.z_index = GlobalConstants.CONTAINER_TITLE_Z_INDEX
		GlobalUtil.log("设置大容器标题字体大小为: " + str(GlobalConstants.UI_TITLE_FONT_SIZE), GlobalUtil.LogLevel.DEBUG)
	
	# 创建确认按钮（底部中间）
	create_confirm_button(container_util)
	
	# 创建3个空卡槽（确认按钮上方）
	create_card_slots(container_util)
	
	# 将UI元素移动到节点树的最后，确保显示在最上层
	if confirm_button:
		container_util.move_child(confirm_button, container_util.get_child_count() - 1)
		GlobalUtil.log("确认按钮移动到最上层，可见性: " + str(confirm_button.visible) + ", z_index: " + str(confirm_button.z_index), GlobalUtil.LogLevel.DEBUG)
	
	for slot in card_slots:
		if slot:
			container_util.move_child(slot, container_util.get_child_count() - 1)
			GlobalUtil.log("卡槽移动到最上层: " + slot.name + ", 可见性: " + str(slot.visible) + ", z_index: " + str(slot.z_index), GlobalUtil.LogLevel.DEBUG)
	
	# 打印容器的所有子节点信息
	GlobalUtil.log("容器子节点总数: " + str(container_util.get_child_count()), GlobalUtil.LogLevel.DEBUG)
	for i in range(container_util.get_child_count()):
		var child = container_util.get_child(i)
		GlobalUtil.log("子节点 " + str(i) + ": " + child.name + ", 类型: " + str(child.get_class()) + ", z_index: " + str(child.z_index if "z_index" in child else "N/A"), GlobalUtil.LogLevel.DEBUG)
	
	GlobalUtil.log("大容器UI元素创建完成", GlobalUtil.LogLevel.INFO)

# 创建确认按钮
func create_confirm_button(container_util: ContainerUtil):
	confirm_button = Button.new()
	confirm_button.name = "ConfirmButton"
	confirm_button.text = "确认"
	
	# 设置按钮尺寸
	confirm_button.size = Vector2(GlobalConstants.UI_BUTTON_WIDTH, GlobalConstants.UI_BUTTON_HEIGHT)
	
	# 设置按钮位置（底部中间）
	var button_x = -GlobalConstants.UI_BUTTON_WIDTH / 2
	var button_y = container_height / 2 - GlobalConstants.UI_BUTTON_HEIGHT - GlobalConstants.UI_SPACING_MEDIUM
	confirm_button.position = Vector2(button_x, button_y)
	
	# 设置按钮纹理
	var confirm_texture = preload("res://assets/images/confirm.jpg")
	if confirm_texture:
		var style_box = StyleBoxTexture.new()
		style_box.texture = confirm_texture
		confirm_button.add_theme_stylebox_override("normal", style_box)
	
	# 设置字体颜色为黑色
	confirm_button.add_theme_color_override("font_color", Color.BLACK)
	confirm_button.add_theme_font_size_override("font_size", GlobalConstants.UI_NORMAL_FONT_SIZE)
	confirm_button.z_index = GlobalConstants.CONTAINER_UI_Z_INDEX
	# 确保按钮不被其他元素遮挡
	confirm_button.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# 连接按钮点击事件
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	
	# 添加到容器
	container_util.add_child(confirm_button)
	GlobalUtil.log("创建确认按钮，位置: " + str(confirm_button.position), GlobalUtil.LogLevel.DEBUG)

# 创建3个空卡槽
func create_card_slots(container_util: ContainerUtil):
	card_slots.clear()
	
	# 计算卡槽总宽度和起始位置
	var total_slots = 3
	var slot_spacing = GlobalConstants.UI_SPACING_LARGE
	var total_width = total_slots * GlobalConstants.UI_CARD_SLOT_WIDTH + (total_slots - 1) * slot_spacing
	var start_x = -total_width / 2
	
	# 卡槽Y位置（确认按钮上方）
	var slot_y = container_height / 2 - GlobalConstants.UI_BUTTON_HEIGHT - GlobalConstants.UI_SPACING_MEDIUM * 2 - GlobalConstants.UI_CARD_SLOT_HEIGHT
	
	for i in range(total_slots):
		var card_slot = Button.new()
		card_slot.name = "CardSlot" + str(i + 1)
		card_slot.text = "空槽" + str(i + 1)
		
		# 设置卡槽尺寸
		card_slot.size = Vector2(GlobalConstants.UI_CARD_SLOT_WIDTH, GlobalConstants.UI_CARD_SLOT_HEIGHT)
		
		# 设置卡槽位置
		var slot_x = start_x + i * (GlobalConstants.UI_CARD_SLOT_WIDTH + slot_spacing)
		card_slot.position = Vector2(slot_x, slot_y)
		
		# 设置卡槽纹理
		var addcard_texture = preload("res://assets/images/addCardUX.jpg")
		if addcard_texture:
			var style_box = StyleBoxTexture.new()
			style_box.texture = addcard_texture
			card_slot.add_theme_stylebox_override("normal", style_box)
		
		# 设置字体颜色为黑色
		card_slot.add_theme_color_override("font_color", Color.BLACK)
		card_slot.add_theme_font_size_override("font_size", GlobalConstants.UI_NORMAL_FONT_SIZE)
		
		# 设置z_index确保卡槽显示在最上层
		card_slot.z_index = GlobalConstants.CONTAINER_UI_Z_INDEX
		# 确保卡槽不被其他元素遮挡
		card_slot.mouse_filter = Control.MOUSE_FILTER_PASS
		
		# 连接卡槽点击事件
		card_slot.pressed.connect(_on_card_slot_pressed.bind(i))
		
		# 添加到容器和数组
		container_util.add_child(card_slot)
		card_slots.append(card_slot)
		
		GlobalUtil.log("创建卡槽" + str(i + 1) + "，位置: " + str(card_slot.position), GlobalUtil.LogLevel.DEBUG)

# 确认按钮点击事件
func _on_confirm_button_pressed():
	GlobalUtil.log("确认按钮被点击", GlobalUtil.LogLevel.INFO)
	# 在这里添加确认按钮的具体功能

# 卡槽点击事件
func _on_card_slot_pressed(slot_index: int):
	GlobalUtil.log("卡槽" + str(slot_index + 1) + "被点击", GlobalUtil.LogLevel.INFO)
	# 在这里添加卡槽的具体功能

# 大容器点击效果
func big_container_click_effect(container_instance):
	GlobalUtil.log("大容器被点击，容器实例ID: " + str(container_instance.get_instance_id()), GlobalUtil.LogLevel.INFO)
	
	# 可以在这里添加大容器特有的点击效果
	# 例如：显示更多信息、展开更多功能等
	pass

# 大容器特有的初始化方法
func initialize_big_container():
	# 大容器特有的初始化逻辑
	GlobalUtil.log("大容器初始化完成，可展示更多元素", GlobalUtil.LogLevel.INFO)
	
	# 可以在这里添加大容器特有的功能
	# 例如：更多的显示区域、特殊功能等