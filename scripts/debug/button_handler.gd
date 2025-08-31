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
	elif text.to_lower() == "listall":
		# 扫描所有prefabs并生成卡牌实例
		GlobalUtil.log("扫描所有卡牌prefabs并生成实例...", GlobalUtil.LogLevel.INFO)
		create_all_prefab_cards()
		
		# 清空输入框
		input_field.text = ""
	else:
		# 尝试根据前缀创建卡牌
		var card_created = create_card_by_prefix(text)
		if not card_created:
			# 如果没有匹配的卡牌前缀，打印其他输入
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
	GlobalUtil.log("--- 卡牌前缀创建 ---", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("支持的卡牌前缀（中英文）：", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("blueberry/蓝莓, iron_axe/铁斧, iron_shovel/铁铲", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("sickle/镰刀, large_magic_aura/大魔法气息", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("small_magic_aura/小魔法气息, primary_flower_pot/初级花盆", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("pickaxe/十字镐, dirt_pile/土堆", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("large_blueberry_bush/大蓝莓丛, small_blueberry_bush/小蓝莓丛", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("old_wooden_house/旧木屋, forest_road/森林道路", GlobalUtil.LogLevel.INFO)
	GlobalUtil.log("wood_scraps/碎木头", GlobalUtil.LogLevel.INFO)
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

# 根据前缀创建卡牌
func create_card_by_prefix(prefix: String) -> bool:
	# 将输入转换为小写
	var input_prefix = prefix.to_lower().strip_edges()
	
	# 定义卡牌前缀映射表
	var card_prefix_map = {
		"blueberry": "blueberry",
		"蓝莓": "blueberry",
		"iron_axe": "iron_axe",
		"铁斧": "iron_axe",
		"iron_shovel": "iron_shovel",
		"铁铲": "iron_shovel",
		"sickle": "sickle",
		"镰刀": "sickle",
		"large_magic_aura": "large_magic_aura",
		"大魔法气息": "large_magic_aura",
		"small_magic_aura": "small_magic_aura",
		"小魔法气息": "small_magic_aura",
		"primary_flower_pot": "primary_flower_pot",
		"初级花盆": "primary_flower_pot",
		"pickaxe": "pickaxe",
		"十字镐": "pickaxe",
		"dirt_pile": "dirt_pile",
		"土堆": "dirt_pile",
		"large_blueberry_bush": "large_blueberry_bush",
		"大蓝莓丛": "large_blueberry_bush",
		"small_blueberry_bush": "small_blueberry_bush",
		"小蓝莓丛": "small_blueberry_bush",
		"old_wooden_house": "old_wooden_house",
		"旧木屋": "old_wooden_house",
		"forest_road": "forest_road",
		"森林道路": "forest_road",
		"wood_scraps": "wood_scraps",
		"碎木头": "wood_scraps"
	}
	
	# 检查是否有匹配的前缀
	if card_prefix_map.has(input_prefix):
		var card_type = card_prefix_map[input_prefix]
		GlobalUtil.log("根据前缀 '" + prefix + "' 创建卡牌类型：" + card_type, GlobalUtil.LogLevel.INFO)
		
		# 创建卡牌
		var card = CardUtil.create_card_from_pool(root_node, card_type, GlobalConstants.SCREEN_CENTER)
		if card:
			card_count += 1
			GlobalUtil.log("成功创建卡牌，当前卡牌数量：" + str(card_count), GlobalUtil.LogLevel.INFO)
			return true
		else:
			GlobalUtil.log("创建卡牌失败：" + card_type, GlobalUtil.LogLevel.ERROR)
			return false
	else:
		# 尝试模糊匹配
		for key in card_prefix_map.keys():
			if key.begins_with(input_prefix) or input_prefix.begins_with(key):
				var card_type = card_prefix_map[key]
				GlobalUtil.log("根据模糊匹配前缀 '" + prefix + "' 创建卡牌类型：" + card_type, GlobalUtil.LogLevel.INFO)
				
				# 创建卡牌
				var card = CardUtil.create_card_from_pool(root_node, card_type, GlobalConstants.SCREEN_CENTER)
				if card:
					card_count += 1
					GlobalUtil.log("成功创建卡牌，当前卡牌数量：" + str(card_count), GlobalUtil.LogLevel.INFO)
					return true
				else:
					GlobalUtil.log("创建卡牌失败：" + card_type, GlobalUtil.LogLevel.ERROR)
					return false
	
	# 没有找到匹配的前缀
	GlobalUtil.log("未找到匹配的卡牌前缀：" + prefix, GlobalUtil.LogLevel.WARNING)
	return false

# 扫描所有prefabs并生成卡牌实例的方法
func create_all_prefab_cards():
	# 确保卡牌池已初始化
	CardUtil.initialize_card_pool(root_node)
	
	# 获取prefabs目录路径
	var prefabs_dir = "res://scripts/cards/prefabs/"
	
	# 打开目录
	var dir = DirAccess.open(prefabs_dir)
	if dir == null:
		GlobalUtil.log("无法打开prefabs目录：" + prefabs_dir, GlobalUtil.LogLevel.ERROR)
		return
	
	# 获取所有.gd文件
	var prefab_files = []
	dir.list_dir_begin()
	var current_file = dir.get_next()
	
	while current_file != "":
		# 只处理.gd文件，排除README.md和.uid文件
		if current_file.ends_with(".gd") and not current_file.ends_with("_card_pack.gd.uid"):
			prefab_files.append(current_file)
		current_file = dir.get_next()
	
	dir.list_dir_end()
	
	# 排序文件名以保证一致的显示顺序
	prefab_files.sort()
	
	GlobalUtil.log("找到 " + str(prefab_files.size()) + " 个prefab文件", GlobalUtil.LogLevel.INFO)
	
	# 计算卡牌布局参数
	var cards_per_row = 17  # 每行17个卡牌
	var card_width = GlobalConstants.CARD_WIDTH  # 卡牌宽度
	var card_spacing = 10  # 卡牌间距
	var row_height = GlobalConstants.CARD_HEIGHT + 20  # 行高
	var start_x = 50  # 起始X坐标
	var start_y = 50  # 起始Y坐标
	
	# 遍历所有prefab文件并创建卡牌实例
	for i in range(prefab_files.size()):
		var file_name = prefab_files[i]
		
		# 从文件名提取卡牌类型（移除_card_pack.gd后缀）
		var card_type = file_name.replace("_card_pack.gd", "")
		
		# 计算卡牌位置
		var row = i / cards_per_row
		var col = i % cards_per_row
		var x = start_x + col * (card_width + card_spacing)
		var y = start_y + row * row_height
		var position = Vector2(x, y)
		
		# 创建卡牌实例
		var card_instance = CardUtil.create_card_from_pool(root_node, card_type, position)
		
		if card_instance:
			# 设置卡牌名称
			card_count += 1
			card_instance.card_name = card_type + " #" + str(card_count)
			
			# 更新显示
			card_instance.update_display()
			
			GlobalUtil.log("创建卡牌：" + card_type + " 位置：" + str(position), GlobalUtil.LogLevel.DEBUG)
		else:
			GlobalUtil.log("创建卡牌失败：" + card_type, GlobalUtil.LogLevel.WARNING)
	
	GlobalUtil.log("完成创建所有prefab卡牌，总计：" + str(prefab_files.size()) + " 个", GlobalUtil.LogLevel.INFO)
