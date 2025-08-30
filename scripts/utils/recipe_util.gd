# 配方管理工具类
# 用于管理卡牌之间的合成配方
extends Node

# 配方数据结构
class Recipe:
	var ingredients: Array[String] = []  # 参与合成的卡牌类型
	var craft_time: float = 0.0  # 合成时间（秒）
	var result_type: String = ""  # 合成产物类型
	
	func _init(p_ingredients: Array[String], p_craft_time: float, p_result_type: String):
		ingredients = p_ingredients
		craft_time = p_craft_time
		result_type = p_result_type

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
		GlobalUtil.log("合成任务计时器触发完成: " + str(recipe.ingredients) + " -> " + recipe.result_type, GlobalUtil.LogLevel.INFO)
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
	# 注册默认配方
	register_default_recipes()
	GlobalUtil.log("RecipeUtil 初始化完成", GlobalUtil.LogLevel.INFO)

# 注册默认配方
func register_default_recipes():
	# 铲子 + 土堆 = 基础花盆
	# 使用卡牌类型名称（对应文件名）
	var shovel_soil_recipe = Recipe.new(["iron_shovel", "dirt_pile"], GlobalConstants.DEFAULT_CRAFT_TIME, "primary_flower_pot")
	recipes.append(shovel_soil_recipe)
	GlobalUtil.log("注册配方: iron_shovel + dirt_pile -> primary_flower_pot (" + str(GlobalConstants.DEFAULT_CRAFT_TIME) + "秒)", GlobalUtil.LogLevel.INFO)

# 注册新配方
func register_recipe(ingredients: Array[String], craft_time: float, result_type: String):
	var recipe = Recipe.new(ingredients, craft_time, result_type)
	recipes.append(recipe)
	GlobalUtil.log("注册配方: " + str(ingredients) + " -> " + result_type + " (" + str(craft_time) + "秒)", GlobalUtil.LogLevel.INFO)

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
			GlobalUtil.log("找到匹配的配方: " + str(card_types) + " -> " + recipe.result_type, GlobalUtil.LogLevel.INFO)
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
	
	GlobalUtil.log("开始合成: " + str(recipe.ingredients) + " -> " + recipe.result_type + " (堆叠ID: " + stack_id + ")", GlobalUtil.LogLevel.INFO)
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
	GlobalUtil.log("合成完成: " + str(task.recipe.ingredients) + " -> " + task.recipe.result_type, GlobalUtil.LogLevel.INFO)
	
	# 这里需要根据result_type创建对应的卡牌
	_create_result_card(task.recipe.result_type, task.cards[0].global_position)
	
	# 调用参与合成卡牌的 after_recipe_done 方法
	for card in task.cards:
		if card.card_pack and card.card_pack.has_method("after_recipe_done"):
			GlobalUtil.log("调用卡牌包 " + card.card_pack.card_name + " 的 after_recipe_done 方法", GlobalUtil.LogLevel.DEBUG)
			card.card_pack.after_recipe_done(card, task.cards)
		else:
			GlobalUtil.log("卡牌 " + str(card.get_instance_id()) + " 没有关联的卡牌包或 after_recipe_done 方法", GlobalUtil.LogLevel.DEBUG)
	
	# 合成完成后，重新检查堆叠是否仍能继续合成
	_check_stack_for_continued_crafting(task.stack_id)

# 创建合成产物
func _create_result_card(result_type: String, position: Vector2):
	GlobalUtil.log("创建合成产物: " + result_type + " 位置: " + str(position), GlobalUtil.LogLevel.INFO)
	
	# 获取根节点（通过场景树）
	var root_node = get_tree().current_scene
	if root_node == null:
		GlobalUtil.log("无法获取根节点，创建合成产物失败", GlobalUtil.LogLevel.ERROR)
		return
	
	# 使用CardUtil创建卡牌
	var CardUtil = preload("res://scripts/cards/card_util.gd")
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
			"result": task.recipe.result_type,
			"progress": task.get_progress(),
			"remaining_time": task.get_remaining_time()
		})
	return info

# 检查堆叠是否能继续合成
func _check_stack_for_continued_crafting(stack_id: String):
	# 获取CardUtil类来访问堆叠数据
	var CardUtil = preload("res://scripts/cards/card_util.gd")
	
	# 检查堆叠是否仍然存在
	if not CardUtil.card_stacks.has(int(stack_id)):
		GlobalUtil.log("堆叠 " + stack_id + " 不存在，无法继续合成检查", GlobalUtil.LogLevel.DEBUG)
		return
	
	# 获取堆叠中的卡牌
	var stack_cards = CardUtil.card_stacks[int(stack_id)]
	if stack_cards.size() < 2:
		GlobalUtil.log("堆叠 " + stack_id + " 卡牌数量不足，无法继续合成", GlobalUtil.LogLevel.DEBUG)
		return
	
	# 尝试开始新的合成任务
	if start_crafting(stack_cards, stack_id):
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
