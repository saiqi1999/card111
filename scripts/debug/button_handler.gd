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
		GlobalUtil.log("输入框已准备就绪", GlobalUtil.LogLevel.INFO)
	else:
		GlobalUtil.log("警告：无法获取输入框引用", GlobalUtil.LogLevel.WARNING)

# 按钮点击事件处理函数
func _on_button_pressed():
	# 打印一行文字
	GlobalUtil.log("按钮被点击了！", GlobalUtil.LogLevel.INFO)
	
	# 创建三张不同位置的卡牌
	create_card(Vector2(700, 540))
	create_card(GlobalConstants.SCREEN_CENTER)
	create_card(Vector2(1220, 540))
	
	# 打印创建成功信息
	GlobalUtil.log("创建了三张打击卡牌！", GlobalUtil.LogLevel.INFO)

# 创建卡牌的辅助函数
func create_card(position: Vector2):
	# 确保卡牌池已初始化
	CardUtil.initialize_card_pool(root_node)
	
	# 使用卡牌池创建卡牌
	var card_instance = CardUtil.create_card_from_pool(root_node, "strike", position)
	
	# 设置卡牌名称，使其区分
	card_count += 1
	card_instance.card_name = "打击 #" + str(card_count)
	
	# 更新显示
	card_instance.update_display()

# 处理输入框文本提交事件
func _on_input_field_text_submitted(text: String):
	# 检查输入的文本
	if text.to_lower() == "hello":
		# 打印一行信息
		GlobalUtil.log("你好，世界！", GlobalUtil.LogLevel.INFO)
		
		# 在控制台显示一条消息
		GlobalUtil.log("收到问候：" + text, GlobalUtil.LogLevel.INFO)
		
		# 清空输入框
		input_field.text = ""
	elif text.to_lower() == "reboot":
		# 打印重启信息
		GlobalUtil.log("正在重启root节点...", GlobalUtil.LogLevel.INFO)
		
		# 调用重启方法
		reboot_root_node()
		
		# 清空输入框
		input_field.text = ""
	elif text.to_lower() == "slide":
		# 打印滑动信息
		GlobalUtil.log("创建滑动卡牌...", GlobalUtil.LogLevel.INFO)
		
		# 调用滑动卡牌方法
		create_sliding_card()
		
		# 清空输入框
		input_field.text = ""
	elif text.to_lower() == "random":
		# 打印随机移动信息
		GlobalUtil.log("创建随机移动卡牌...", GlobalUtil.LogLevel.INFO)
		
		# 调用随机移动卡牌方法
		create_random_move_card()
		
		# 清空输入框
		input_field.text = ""
	elif text.to_lower() == "random2":
		# 打印随机卡牌类型信息
		GlobalUtil.log("创建随机类型卡牌...", GlobalUtil.LogLevel.INFO)
		
		# 调用随机类型卡牌方法
		create_random_type_card()
		
		# 清空输入框
		input_field.text = ""
	elif text.to_lower() == "overlap":
		# 打印重叠卡牌信息
		GlobalUtil.log("创建重叠卡牌测试...", GlobalUtil.LogLevel.INFO)
		
		# 调用重叠卡牌测试方法
		create_overlapping_cards_test()
		
		# 清空输入框
		input_field.text = ""
	elif text.to_lower() == "log off":
		# 关闭日志输出
		GlobalUtil.set_log_enabled(false)
		
		# 清空输入框
		input_field.text = ""
	elif text.to_lower() == "log on":
		# 开启日志输出
		GlobalUtil.set_log_enabled(true)
		
		# 清空输入框
		input_field.text = ""
	elif text.to_lower() == "slime":
		# 创建Want Slime卡牌
		GlobalUtil.log("创建Want Slime卡牌...", GlobalUtil.LogLevel.INFO)
		create_specific_card("want_slime")
		input_field.text = ""
	elif text.to_lower() == "skill":
		# 创建Basic Skill Pack卡牌
		GlobalUtil.log("创建Basic Skill Pack卡牌...", GlobalUtil.LogLevel.INFO)
		create_specific_card("basic_skill_pack")
		input_field.text = ""
	elif text.to_lower() == "help":
		# 显示帮助信息
		show_help()
		
		# 清空输入框
		input_field.text = ""
	else:
		# 打印其他输入
		GlobalUtil.log("收到输入：" + text, GlobalUtil.LogLevel.INFO)
		
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
	GlobalUtil.log("root节点已重启，所有卡牌已清除", GlobalUtil.LogLevel.INFO)
	
	# 重新初始化全局工具
	var util_node = root.get_node("Util")
	if util_node and util_node.has_method("_ready"):
		util_node._ready()
		GlobalUtil.log("全局工具已重新初始化", GlobalUtil.LogLevel.INFO)

# 创建滑动卡牌的方法
func create_sliding_card():
	# 确保卡牌池已初始化
	CardUtil.initialize_card_pool(root_node)
	
	# 设置卡牌初始位置（屏幕左侧外）
	var start_position = GlobalConstants.SCREEN_LEFT_OUTSIDE
	
	# 使用卡牌池创建卡牌
	var card_instance = CardUtil.create_card_from_pool(root_node, "strike", start_position)
	
	# 设置卡牌名称
	card_count += 1
	card_instance.card_name = "滑动打击 #" + str(card_count)
	
	# 更新显示
	card_instance.update_display()
	
	# 创建Tween动画
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	
	# 保存Tween引用到卡牌实例，以便拖拽时能停止动画
	if card_instance.has_method("set"):
		card_instance.set("active_tween", tween)
	
	# 设置卡牌移动动画（从左到右）
	tween.tween_property(card_instance, "position", GlobalConstants.SCREEN_CENTER, 1.5)
	
	# 添加第二段动画（轻微上下浮动）
	tween.tween_property(card_instance, "position", Vector2(GlobalConstants.SCREEN_CENTER.x, GlobalConstants.SCREEN_CENTER.y - 20), 0.5)
	tween.tween_property(card_instance, "position", GlobalConstants.SCREEN_CENTER, 0.5)
	
	# 动画完成后清除引用
	tween.finished.connect(func(): 
		if card_instance.has_method("set"):
			card_instance.set("active_tween", null)
	)
	
	# 打印创建信息
	GlobalUtil.log("创建了一张从左向右滑动的打击卡牌！", GlobalUtil.LogLevel.INFO)

# 创建随机移动卡牌的方法
func create_random_move_card():
	# 确保卡牌池已初始化
	CardUtil.initialize_card_pool(root_node)
	
	# 设置卡牌初始位置（屏幕中央）
	var start_position = GlobalConstants.SCREEN_CENTER
	
	# 使用卡牌池创建卡牌
	var card_instance = CardUtil.create_card_from_pool(root_node, "strike", start_position)
	
	# 设置卡牌名称
	card_count += 1
	card_instance.card_name = "随机移动打击 #" + str(card_count)
	
	# 更新显示
	card_instance.update_display()
	
	# 使用CardUtil.random_move_card方法随机移动卡牌
	var move_distance = CardUtil.random_move_card(card_instance)
	
	# 打印创建和移动信息
	GlobalUtil.log("创建了一张随机移动的打击卡牌！", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("卡牌移动了：" + str(move_distance), GlobalUtil.LogLevel.INFO)

# 创建随机类型卡牌的方法
func create_random_type_card():
	# 确保卡牌池已初始化
	CardUtil.initialize_card_pool(root_node)
	
	# 设置卡牌初始位置（屏幕中央）
	var start_position = GlobalConstants.SCREEN_CENTER
	
	# 定义可用的卡牌类型
	var card_types = ["strike", "defend", "want_slime", "basic_skill_pack"]
	
	# 随机选择卡牌类型
	var random_type = card_types[randi() % card_types.size()]
	
	# 使用卡牌池创建随机类型的卡牌
	var card_instance = CardUtil.create_card_from_pool(root_node, random_type, start_position)
	
	# 设置卡牌名称
	card_count += 1
	var type_name = ""
	match random_type:
		"strike":
			type_name = "打击"
		"defend":
			type_name = "防御"
		"want_slime":
			type_name = "Want Slime"
		"basic_skill_pack":
			type_name = "Basic Skill Pack"
		_:
			type_name = "未知"
	card_instance.card_name = "随机" + type_name + " #" + str(card_count)
	
	# 更新显示
	card_instance.update_display()
	
	# 使用CardUtil.random_move_card方法随机移动卡牌
	var move_distance = CardUtil.random_move_card(card_instance)
	
	# 打印创建和移动信息
	GlobalUtil.log("创建了一张随机移动的" + type_name + "卡牌！类型：" + random_type, GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("卡牌移动了：" + str(move_distance), GlobalUtil.LogLevel.INFO)

# 显示帮助信息的方法
func show_help():
	GlobalUtil.log("===== 可用命令列表 =====", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("hello - 显示问候信息", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("reboot - 重启root节点，清除所有卡牌", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("slide - 创建滑动卡牌", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("random - 创建随机移动打击卡牌", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("random2 - 创建随机移动的所有类型卡牌", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("slime - 创建Want Slime卡牌", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("skill - 创建Basic Skill Pack卡牌", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("overlap - 创建重叠卡牌测试层级管理", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("log on - 开启日志输出", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("log off - 关闭日志输出", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("help - 显示此帮助信息", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("========================", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("当前日志状态: " + ("开启" if GlobalUtil.is_log_enabled() else "关闭"), GlobalUtil.LogLevel.INFO)

# 创建特定类型卡牌的方法
func create_specific_card(card_type: String):
	# 确保卡牌池已初始化
	CardUtil.initialize_card_pool(root_node)
	
	# 设置卡牌位置（屏幕中央）
	var target_position = GlobalConstants.SCREEN_CENTER
	
	# 使用卡牌池创建指定类型的卡牌
	var card_instance = CardUtil.create_card_from_pool(root_node, card_type, target_position)
	
	# 设置卡牌名称
	card_count += 1
	var type_name = ""
	match card_type:
		"want_slime":
			type_name = "Want Slime"
		"basic_skill_pack":
			type_name = "Basic Skill Pack"
		"strike":
			type_name = "打击"
		"defend":
			type_name = "防御"
		_:
			type_name = "未知"
	card_instance.card_name = type_name + " #" + str(card_count)
	
	# 更新显示
	card_instance.update_display()
	
	# 打印创建信息
	GlobalUtil.log("创建了一张" + type_name + "卡牌！", GlobalUtil.LogLevel.INFO)

# 创建重叠卡牌测试的方法
func create_overlapping_cards_test():
	# 在同一位置创建多张卡牌，测试层级管理
	var base_position = GlobalConstants.SCREEN_CENTER
	
	# 确保卡牌池已初始化
	CardUtil.initialize_card_pool(root_node)
	
	# 创建5张重叠的卡牌
	for i in range(5):
		# 计算卡牌位置（稍微偏移以便观察层级）
		var offset = Vector2(i * 20, i * 15)  # 每张卡牌稍微偏移
		var target_position = base_position + offset
		
		# 使用卡牌池创建卡牌
		var card_instance = CardUtil.create_card_from_pool(root_node, "strike", target_position)
		
		# 设置卡牌名称
		card_count += 1
		card_instance.card_name = "重叠测试卡牌 #" + str(card_count)
		
		# 更新显示
		card_instance.update_display()
		
		GlobalUtil.log("创建重叠测试卡牌 #" + str(card_count) + " 完成", GlobalUtil.LogLevel.DEBUG)
	
	# 打印创建信息
	GlobalUtil.log("创建了5张重叠的测试卡牌！", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("提示：点击卡牌测试层级管理功能", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("只有最上层的卡牌应该响应点击事件", GlobalUtil.LogLevel.INFO)
	
	# 打印所有卡牌的调试信息
	GlobalUtil.log(CardUtil.get_all_cards_debug_info(), GlobalUtil.LogLevel.INFO)
