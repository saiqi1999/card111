extends Node

# 预加载场景和资源
var card_scene = preload("res://scenes/card.tscn")

# 导入卡牌工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")

# 获取根节点的引用
@onready var root_node = get_tree().get_root().get_node("Root")
# 获取输入框引用
@onready var input_field = get_parent().get_node("InputField")

# 记录已创建的卡牌数量
var card_count = 0

# 初始化函数
func _ready():
	# 确保输入框引用有效
	if input_field:
		print("输入框已准备就绪")
	else:
		print("警告：无法获取输入框引用")

# 按钮点击事件处理函数
func _on_button_pressed():
	# 打印一行文字
	print("按钮被点击了！")
	
	# 创建三张不同位置的卡牌
	create_card(Vector2(700, 540))
	create_card(Vector2(960, 540))
	create_card(Vector2(1220, 540))
	
	# 打印创建成功信息
	print("创建了三张打击卡牌！")

# 创建卡牌的辅助函数
func create_card(position: Vector2):
	# 创建卡牌场景实例
	var card_instance = card_scene.instantiate()
	
	# 设置卡牌位置
	card_instance.position = position
	
	# 通过类型字符串加载卡牌
	card_instance.load_from_card_type("strike")
	
	# 设置卡牌名称，使其区分
	card_count += 1
	card_instance.card_name = "打击 #" + str(card_count)
	
	# 将卡牌添加到根场景
	root_node.add_child(card_instance)

# 处理输入框文本提交事件
func _on_input_field_text_submitted(text: String):
	# 检查输入的文本
	if text.to_lower() == "hello":
		# 打印一行信息
		print("你好，世界！")
		
		# 在控制台显示一条消息
		print("收到问候：" + text)
		
		# 清空输入框
		input_field.text = ""
	elif text.to_lower() == "reboot":
		# 打印重启信息
		print("正在重启root节点...")
		
		# 调用重启方法
		reboot_root_node()
		
		# 清空输入框
		input_field.text = ""
	elif text.to_lower() == "slide":
		# 打印滑动信息
		print("创建滑动卡牌...")
		
		# 调用滑动卡牌方法
		create_sliding_card()
		
		# 清空输入框
		input_field.text = ""
	elif text.to_lower() == "random":
		# 打印随机移动信息
		print("创建随机移动卡牌...")
		
		# 调用随机移动卡牌方法
		create_random_move_card()
		
		# 清空输入框
		input_field.text = ""
	else:
		# 打印其他输入
		print("收到输入：" + text)
		
		# 清空输入框
		input_field.text = ""

# 重启root节点的方法
func reboot_root_node():
	# 获取root节点
	var root = get_tree().get_root().get_node("Root")
	
	# 清除所有卡牌
	for child in root.get_children():
		# 跳过Debug和Util节点
		if child.name != "Debug" and child.name != "Util":
			# 移除子节点
			root.remove_child(child)
			# 释放资源
			child.queue_free()
	
	# 重置卡牌计数
	card_count = 0
	
	# 打印重启完成信息
	print("root节点已重启，所有卡牌已清除")
	
	# 重新初始化全局工具
	var util_node = root.get_node("Util")
	if util_node and util_node.has_method("_ready"):
		util_node._ready()
		print("全局工具已重新初始化")

# 创建滑动卡牌的方法
func create_sliding_card():
	# 创建卡牌场景实例
	var card_instance = card_scene.instantiate()
	
	# 设置卡牌初始位置（屏幕左侧外）
	card_instance.position = Vector2(-200, 540)
	
	# 通过类型字符串加载卡牌
	card_instance.load_from_card_type("strike")
	
	# 设置卡牌名称
	card_count += 1
	card_instance.card_name = "滑动打击 #" + str(card_count)
	
	# 将卡牌添加到根场景
	root_node.add_child(card_instance)
	
	# 创建Tween动画
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	
	# 设置卡牌移动动画（从左到右）
	tween.tween_property(card_instance, "position", Vector2(960, 540), 1.5)
	
	# 添加第二段动画（轻微上下浮动）
	tween.tween_property(card_instance, "position", Vector2(960, 520), 0.5)
	tween.tween_property(card_instance, "position", Vector2(960, 540), 0.5)
	
	# 打印创建信息
	print("创建了一张从左向右滑动的打击卡牌！")

# 创建随机移动卡牌的方法
func create_random_move_card():
	# 创建卡牌场景实例
	var card_instance = card_scene.instantiate()
	
	# 设置卡牌初始位置（屏幕中央）
	card_instance.position = Vector2(960, 540)
	
	# 通过类型字符串加载卡牌
	card_instance.load_from_card_type("strike")
	
	# 设置卡牌名称
	card_count += 1
	card_instance.card_name = "随机移动打击 #" + str(card_count)
	
	# 将卡牌添加到根场景
	root_node.add_child(card_instance)
	
	# 使用CardUtil.random_move_card方法随机移动卡牌
	var move_distance = CardUtil.random_move_card(card_instance)
	
	# 打印创建和移动信息
	print("创建了一张随机移动的打击卡牌！")
	print("卡牌移动了：", move_distance)