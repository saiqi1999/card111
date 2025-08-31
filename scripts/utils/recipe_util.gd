# 配方管理工具类
# 用于管理卡牌之间的合成配方
extends Node

# 确保StackUtil可用（虽然它是autoload，但明确引用以避免IDE警告）
# StackUtil已在project.godot中注册为autoload单例

# 进度更新定时器
var progress_update_timer: Timer

# 合成进度条系统
var stack_progress_bars: Dictionary = {}  # 堆叠进度条映射 {stack_id: progress_bar_instance}

# 配方数据结构
class Recipe:
	var ingredients: Array[String] = []  # 参与合成的卡牌类型
	var craft_time: float = 0.0  # 合成时间（秒）
	var result_types: Array[String] = []  # 合成产物类型列表
	
	func _init(p_ingredients: Array[String], p_craft_time: float, p_result_types: Array[String]):
		ingredients = p_ingredients
		craft_time = p_craft_time
		result_types = p_result_types

# 正在进行的合成任务
class CraftingTask:
	var recipe: Recipe
	var cards: Array  # 参与合成的卡牌实例
	var stack_id: String  # 堆叠ID
	var timer: Timer  # 每个任务独立的计时器
	var recipe_util_ref: Node  # 对RecipeUtil的引用
	
	func _init(p_recipe: Recipe, p_cards: Array, p_stack_id: String, p_recipe_util: Node):
		recipe = p_recipe
		cards = p_cards
		stack_id = p_stack_id
		recipe_util_ref = p_recipe_util
		
		# 创建独立的计时器
		timer = Timer.new()
		timer.wait_time = recipe.craft_time
		timer.one_shot = true
		timer.timeout.connect(_on_crafting_complete)
		p_recipe_util.add_child(timer)
		timer.start()
		
		GlobalUtil.log("为合成任务创建计时器，时长: " + str(recipe.craft_time) + "秒", GlobalUtil.LogLevel.DEBUG)
	
	# 合成完成回调
	func _on_crafting_complete():
		GlobalUtil.log("合成任务计时器触发完成: " + str(recipe.ingredients) + " -> " + str(recipe.result_types), GlobalUtil.LogLevel.INFO)
		recipe_util_ref._complete_crafting_task(self)
	
	# 获取剩余时间
	func get_remaining_time() -> float:
		return timer.time_left
	
	# 获取进度（0.0-1.0）
	func get_progress() -> float:
		if timer.wait_time <= 0:
			return 1.0
		return 1.0 - (timer.time_left / timer.wait_time)
	
	# 清理资源
	func cleanup():
		if timer != null:
			timer.queue_free()
			timer = null

# 配方注册表
var recipes: Array[Recipe] = []
# 正在进行的合成任务
var active_crafting_tasks: Array[CraftingTask] = []

func _ready():
	# 从RecipeConstant加载配方
	load_recipes_from_constant()
	
	# 初始化进度更新定时器
	progress_update_timer = Timer.new()
	progress_update_timer.wait_time = GlobalConstants.RECIPE_CHECK_INTERVAL
	progress_update_timer.timeout.connect(_update_crafting_progress)
	add_child(progress_update_timer)
	progress_update_timer.start()
	
	GlobalUtil.log("RecipeUtil 初始化完成", GlobalUtil.LogLevel.INFO)

# 从RecipeConstant加载配方
func load_recipes_from_constant():
	var recipe_data_list = RecipeConstant.get_all_recipes()
	for recipe_data in recipe_data_list:
		if recipe_data.has("ingredients") and recipe_data.has("products") and recipe_data.has("craft_time"):
			# 支持多个产出
			var result_types: Array[String] = []
			for product in recipe_data.products:
				result_types.append(str(product))
			# 将普通Array转换为Array[String]类型
			var ingredients_typed: Array[String] = []
			for ingredient in recipe_data.ingredients:
				ingredients_typed.append(str(ingredient))
			var recipe = Recipe.new(ingredients_typed, recipe_data.craft_time, result_types)
			recipes.append(recipe)
			GlobalUtil.log("从RecipeConstant加载配方: " + str(recipe_data.ingredients) + " -> " + str(result_types) + " (" + str(recipe_data.craft_time) + "秒)", GlobalUtil.LogLevel.INFO)
		else:
			GlobalUtil.log("配方数据格式错误，跳过: " + str(recipe_data), GlobalUtil.LogLevel.ERROR)

# 注册新配方
func register_recipe(ingredients: Array[String], craft_time: float, result_types: Array[String]):
	var recipe = Recipe.new(ingredients, craft_time, result_types)
	recipes.append(recipe)
	
	# 同时添加到RecipeConstant中
	RecipeConstant.add_recipe(ingredients, result_types, craft_time)
	
	GlobalUtil.log("注册配方: " + str(ingredients) + " -> " + str(result_types) + " (" + str(craft_time) + "秒)", GlobalUtil.LogLevel.INFO)

# 检查堆叠是否匹配某个配方
func check_stack_for_recipe(stack_cards: Array) -> Recipe:
	if stack_cards.size() < 2:
		return null
	
	# 获取堆叠中的卡牌类型
	var card_types: Array[String] = []
	for card in stack_cards:
		if card.has_method("get") and card.get("card_type") != "":
			# 使用卡牌的类型名称（对应文件名）
			card_types.append(card.card_type)
			GlobalUtil.log("获取卡牌类型: " + card.card_type, GlobalUtil.LogLevel.DEBUG)
		else:
			GlobalUtil.log("卡牌缺少类型信息，跳过: " + str(card.get_instance_id()), GlobalUtil.LogLevel.WARNING)
	
	# 检查是否匹配任何配方
	for recipe in recipes:
		if _arrays_match(card_types, recipe.ingredients):
			# 检查配方是否还有剩余次数
			if not RecipeConstant.check_recipe_remaining_times(recipe.ingredients):
				GlobalUtil.log("配方已无剩余使用次数: " + str(card_types), GlobalUtil.LogLevel.INFO)
				return null
			
			GlobalUtil.log("找到匹配的配方: " + str(card_types) + " -> " + str(recipe.result_types), GlobalUtil.LogLevel.INFO)
			return recipe
	
	GlobalUtil.log("未找到匹配的配方，卡牌类型: " + str(card_types), GlobalUtil.LogLevel.DEBUG)
	return null

# 检查两个数组是否包含相同元素（不考虑顺序）
func _arrays_match(array1: Array, array2: Array) -> bool:
	if array1.size() != array2.size():
		return false
	
	var temp_array2 = array2.duplicate()
	for item in array1:
		if item in temp_array2:
			temp_array2.erase(item)
		else:
			return false
	
	return temp_array2.is_empty()

# 开始合成
func start_crafting(stack_cards: Array, stack_id: String) -> bool:
	var recipe = check_stack_for_recipe(stack_cards)
	if recipe == null:
		return false
	
	# 检查是否已经在合成中
	for task in active_crafting_tasks:
		if task.stack_id == stack_id:
			GlobalUtil.log("堆叠 " + stack_id + " 已在合成中", GlobalUtil.LogLevel.WARNING)
			return false
	
	# 创建合成任务
	var crafting_task = CraftingTask.new(recipe, stack_cards, stack_id, self)
	active_crafting_tasks.append(crafting_task)
	
	GlobalUtil.log("开始合成: " + str(recipe.ingredients) + " -> " + str(recipe.result_types) + " (堆叠ID: " + stack_id + ")", GlobalUtil.LogLevel.INFO)
	return true

# 完成合成任务（由计时器触发）
func _complete_crafting_task(task: CraftingTask):
	# 从活跃任务列表中移除
	active_crafting_tasks.erase(task)
	
	# 执行合成完成逻辑
	_complete_crafting(task)
	
	# 清理任务资源
	task.cleanup()

# 完成合成
func _complete_crafting(task: CraftingTask):
	GlobalUtil.log("合成完成: " + str(task.recipe.ingredients) + " -> " + str(task.recipe.result_types), GlobalUtil.LogLevel.INFO)
	
	# 隐藏进度条
	hide_progress_bar_for_stack(int(task.stack_id))
	
	# 创建所有产物卡牌
	_create_result_cards(task.recipe.result_types, task.cards[0].global_position)
	
	# 复制一份卡牌列表，避免在遍历过程中修改列表
	var cards_copy = task.cards.duplicate()
	
	# 调用参与合成卡牌的 after_recipe_done 方法
	for card in cards_copy:
		if card == null or not is_instance_valid(card):
			GlobalUtil.log("发现无效的卡牌实例", GlobalUtil.LogLevel.INFO)
			continue
		
		# 检查卡牌是否有get方法
		if not card.has_method("get"):
			GlobalUtil.log("卡牌 " + str(card.get_instance_id()) + " 没有get方法", GlobalUtil.LogLevel.INFO)
			continue
		
		# 获取卡牌包
		var card_pack = card.get("card_pack")
		if card_pack == null:
			GlobalUtil.log("卡牌 " + str(card.get_instance_id()) + " 没有关联的卡牌包", GlobalUtil.LogLevel.INFO)
			continue
		
		# 检查卡牌包是否有after_recipe_done方法
		if not card_pack.has_method("after_recipe_done"):
			GlobalUtil.log("卡牌 " + str(card.get_instance_id()) + " 的卡牌包没有 after_recipe_done 方法", GlobalUtil.LogLevel.INFO)
			continue
		
		# 调用after_recipe_done方法
		GlobalUtil.log("调用卡牌包 " + card_pack.pack_name + " 的 after_recipe_done 方法", GlobalUtil.LogLevel.INFO)
		card_pack.after_recipe_done(card, cards_copy)
	
	# 合成完成后，重新检查堆叠是否仍能继续合成
	_check_stack_for_continued_crafting(task.stack_id)

# 创建合成产物
func _create_result_cards(result_types: Array[String], position: Vector2):
	GlobalUtil.log("创建合成产物，类型: " + str(result_types) + " 位置: " + str(position), GlobalUtil.LogLevel.INFO)
	
	# 获取根节点（通过场景树）
	var root_node = get_tree().current_scene
	if root_node == null:
		GlobalUtil.log("无法获取根节点，创建合成产物失败", GlobalUtil.LogLevel.ERROR)
		return
	
	# 使用CardUtil创建卡牌
	var CardUtil = preload("res://scripts/cards/card_util.gd")
	
	# 创建每个产物
	for result_type in result_types:
		var result_card = CardUtil.create_card_from_pool(root_node, result_type, position)
		
		if result_card != null:
			GlobalUtil.log("成功创建合成产物: " + result_type, GlobalUtil.LogLevel.INFO)
			
			# 对合成产物进行随机移动
			var move_distance = CardUtil.random_move_card(result_card)
			GlobalUtil.log("合成产物随机移动距离: " + str(move_distance), GlobalUtil.LogLevel.INFO)
		else:
			GlobalUtil.log("创建合成产物失败: " + result_type, GlobalUtil.LogLevel.ERROR)

# 获取正在进行的合成任务信息
func get_active_crafting_info() -> Array[Dictionary]:
	var info: Array[Dictionary] = []
	for task in active_crafting_tasks:
		info.append({
			"stack_id": task.stack_id,
			"recipe": task.recipe.ingredients,
			"results": task.recipe.result_types,
			"progress": task.get_progress(),
			"remaining_time": task.get_remaining_time()
		})
	return info

# 检查堆叠是否能继续合成
func _check_stack_for_continued_crafting(stack_id: String):
	# 获取CardUtil类来访问堆叠数据
	var CardUtil = preload("res://scripts/cards/card_util.gd")
	
	# 检查堆叠是否仍然存在
	if not StackUtil.stack_exists(int(stack_id)):
		GlobalUtil.log("堆叠 " + stack_id + " 不存在，无法继续合成检查", GlobalUtil.LogLevel.DEBUG)
		return
	
	# 获取堆叠中的卡牌
	var stack_cards = StackUtil.get_stack_cards(int(stack_id))
	if stack_cards.size() < 2:
		GlobalUtil.log("堆叠 " + stack_id + " 卡牌数量不足，无法继续合成", GlobalUtil.LogLevel.DEBUG)
		return
	
	# 尝试开始新的合成任务
	if start_crafting(stack_cards, stack_id):
		# 显示进度条
		show_progress_bar_for_stack(int(stack_id))
		GlobalUtil.log("堆叠 " + stack_id + " 开始新的合成任务", GlobalUtil.LogLevel.INFO)
	else:
		GlobalUtil.log("堆叠 " + stack_id + " 无法开始新的合成任务", GlobalUtil.LogLevel.DEBUG)

# 取消合成
func cancel_crafting(stack_id: String) -> bool:
	for i in range(active_crafting_tasks.size()):
		if active_crafting_tasks[i].stack_id == stack_id:
			var task = active_crafting_tasks[i]
			GlobalUtil.log("取消合成: 堆叠ID " + stack_id, GlobalUtil.LogLevel.INFO)
			
			# 清理任务资源
			task.cleanup()
			
			# 从列表中移除
			active_crafting_tasks.remove_at(i)
			return true
	return false

# 更新合成进度（定时器回调）
func _update_crafting_progress():
	# 遍历所有活跃的合成任务
	for task in active_crafting_tasks:
		var progress = task.get_progress()
		var stack_id = int(task.stack_id)
		
		# 更新对应堆叠的进度条
		update_progress_bar_for_stack(stack_id, progress)

# ==================== 合成进度条管理 ====================

# 为堆叠创建并显示进度条
func show_progress_bar_for_stack(stack_id: int):
	# 检查堆叠是否存在
	if not StackUtil.stack_exists(stack_id):
		GlobalUtil.log("堆叠ID " + str(stack_id) + " 不存在，无法显示进度条", GlobalUtil.LogLevel.WARNING)
		return
	
	# 如果进度条已存在，先销毁
	if stack_id in stack_progress_bars:
		hide_progress_bar_for_stack(stack_id)
	
	# 创建进度条实例
	var progress_bar_script = preload("res://scripts/ui/crafting_progress_bar.gd")
	var progress_bar = Control.new()
	progress_bar.set_script(progress_bar_script)
	
	# 获取堆叠信息
	var stack_cards = StackUtil.get_stack_cards(stack_id)
	if stack_cards.size() == 0:
		return
	
	# 获取底部卡牌位置和卡牌宽度
	var bottom_card = stack_cards[0]
	var card_width = GlobalConstants.CARD_WIDTH
	var stack_height = GlobalConstants.CARD_HEIGHT + (stack_cards.size() - 1) * GlobalConstants.CARD_STACK_OFFSET
	
	# 将进度条添加到场景树
	bottom_card.get_parent().add_child(progress_bar)
	
	# 设置进度条位置和显示
	progress_bar.set_position_below_stack(bottom_card.global_position, stack_height)
	progress_bar.show_progress_bar(card_width)
	
	# 保存进度条引用
	stack_progress_bars[stack_id] = progress_bar
	
	GlobalUtil.log("为堆叠ID " + str(stack_id) + " 创建进度条", GlobalUtil.LogLevel.INFO)

# 更新堆叠进度条
func update_progress_bar_for_stack(stack_id: int, progress: float):
	if stack_id in stack_progress_bars:
		var progress_bar = stack_progress_bars[stack_id]
		if progress_bar != null and is_instance_valid(progress_bar):
			progress_bar.update_progress(progress)
			GlobalUtil.log("更新堆叠ID " + str(stack_id) + " 进度条: " + str(progress * 100) + "%", GlobalUtil.LogLevel.DEBUG)

# 隐藏并销毁堆叠进度条
func hide_progress_bar_for_stack(stack_id: int):
	if stack_id in stack_progress_bars:
		var progress_bar = stack_progress_bars[stack_id]
		if progress_bar != null and is_instance_valid(progress_bar):
			progress_bar.hide_progress_bar()
			progress_bar.queue_free()
		stack_progress_bars.erase(stack_id)
		GlobalUtil.log("销毁堆叠ID " + str(stack_id) + " 的进度条", GlobalUtil.LogLevel.INFO)

# 更新堆叠位置时同步更新进度条位置
func update_progress_bar_position_for_stack(stack_id: int):
	if not stack_id in stack_progress_bars or not StackUtil.stack_exists(stack_id):
		return
	
	var progress_bar = stack_progress_bars[stack_id]
	var stack_cards = StackUtil.get_stack_cards(stack_id)
	
	if progress_bar != null and is_instance_valid(progress_bar) and stack_cards.size() > 0:
		var bottom_card = stack_cards[0]
		var stack_height = GlobalConstants.CARD_HEIGHT + (stack_cards.size() - 1) * GlobalConstants.CARD_STACK_OFFSET
		progress_bar.set_position_below_stack(bottom_card.global_position, stack_height)
