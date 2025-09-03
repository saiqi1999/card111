extends Node

# 卡牌堆叠管理工具
# 使用Autoload单例模式，管理所有卡牌的堆叠逻辑

# 卡牌堆叠系统
static var card_stacks: Dictionary = {}  # 卡牌堆叠状态管理 {stack_id: [card1, card2, ...]}
static var card_to_stack: Dictionary = {}  # 卡牌到堆叠的映射 {card_instance_id: stack_id}
static var stack_id_counter: int = 0  # 堆叠ID计数器

# 清理无效的堆叠引用
static func cleanup_invalid_stacks():
	var stacks_to_remove: Array[int] = []
	var mappings_to_remove: Array[int] = []
	
	# 获取CardUtil来访问all_cards
	var CardUtil = preload("res://scripts/cards/card_util.gd")
	
	# 检查堆叠中的无效卡牌
	for stack_id in card_stacks.keys():
		var stack = card_stacks[stack_id]
		var valid_cards: Array[Node2D] = []
		
		for card in stack:
			if card != null and is_instance_valid(card):
				valid_cards.append(card)
		
		# 如果堆叠为空或只有一张卡牌，移除堆叠
		if valid_cards.size() <= 1:
			stacks_to_remove.append(stack_id)
		else:
			card_stacks[stack_id] = valid_cards
	
	# 检查映射中的无效卡牌
	for instance_id in card_to_stack.keys():
		var found = false
		for card in CardUtil.all_cards:
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

# 获取卡牌上方的所有卡牌（用于连带拖拽）
static func get_cards_above(card: Node2D) -> Array[Node2D]:
	var cards_above: Array[Node2D] = []
	var current_instance_id = card.get_instance_id()
	
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
		if stack[i] == card:
			current_index = i
			break
	
	# 如果找到了当前卡牌的位置，获取其上方的所有卡牌
	if current_index >= 0:
		for i in range(current_index + 1, stack.size()):
			if stack[i] != null and is_instance_valid(stack[i]):
				cards_above.append(stack[i])
	
	GlobalUtil.log("获取到 " + str(cards_above.size()) + " 张上方卡牌", GlobalUtil.LogLevel.DEBUG)
	return cards_above

# 检查卡牌是否在堆叠中
static func is_in_stack(card: Node2D) -> bool:
	var current_instance_id = card.get_instance_id()
	return current_instance_id in card_to_stack

# 获取卡牌所在堆叠的统计信息
static func get_stack_info(card: Node2D) -> Dictionary:
	var stack_info = {}
	var current_instance_id = card.get_instance_id()
	
	# 如果不在堆叠中，返回空字典
	if not current_instance_id in card_to_stack:
		return stack_info
	
	var current_stack_id = card_to_stack[current_instance_id]
	
	# 如果堆叠不存在，返回空字典
	if not current_stack_id in card_stacks:
		return stack_info
	
	var stack = card_stacks[current_stack_id]
	var card_counts = {}  # 存储每种卡牌的数量
	var total_cards = 0
	
	# 统计堆叠中每种卡牌的数量
	for stack_card in stack:
		if stack_card != null and is_instance_valid(stack_card):
			total_cards += 1
			var card_name = stack_card.card_name if stack_card.card_name else "未知卡牌"
			
			if card_name in card_counts:
				card_counts[card_name] += 1
			else:
				card_counts[card_name] = 1
	
	# 构建返回信息
	stack_info["total_cards"] = total_cards
	stack_info["card_counts"] = card_counts
	stack_info["stack_id"] = current_stack_id
	
	GlobalUtil.log("获取堆叠信息: 总计 " + str(total_cards) + " 张卡牌，" + str(card_counts.size()) + " 种类型", GlobalUtil.LogLevel.DEBUG)
	return stack_info

# 格式化堆叠信息用于显示
static func format_stack_info_for_display(card: Node2D) -> Dictionary:
	var stack_info = get_stack_info(card)
	
	if stack_info.is_empty():
		return {"title": card.card_name, "description": card.description}
	
	var card_counts = stack_info["card_counts"]
	var total_cards = stack_info["total_cards"]
	
	# 构建标题
	var title = "卡牌堆叠 (" + str(total_cards) + "张)"
	
	# 构建描述
	var description_lines = []
	for cardname in card_counts.keys():
		var count = card_counts[cardname]
		description_lines.append(cardname + " x" + str(count))
	
	var formatted_description = "\n".join(description_lines)
	
	return {"title": title, "description": formatted_description}

# 检查堆叠是否匹配配方并开始合成
static func check_stack_for_crafting(stack_id: int):
	# 检查堆叠是否存在
	if not stack_id in card_stacks:
		GlobalUtil.log("堆叠ID " + str(stack_id) + " 不存在，无法检查配方", GlobalUtil.LogLevel.WARNING)
		return
	
	var stack_cards = card_stacks[stack_id]
	
	# 检查堆叠中是否有足够的卡牌
	if stack_cards.size() < 2:
		GlobalUtil.log("堆叠卡牌数量不足，无法进行合成检查", GlobalUtil.LogLevel.DEBUG)
		return
	
	# 调用RecipeUtil检查配方并开始合成
	var success = RecipeUtil.start_crafting(stack_cards, str(stack_id))
	if success:
		GlobalUtil.log("堆叠ID " + str(stack_id) + " 开始合成", GlobalUtil.LogLevel.INFO)
		# 通过RecipeUtil显示进度条
		RecipeUtil.show_progress_bar_for_stack(stack_id)
	else:
		GlobalUtil.log("堆叠ID " + str(stack_id) + " 无匹配配方", GlobalUtil.LogLevel.DEBUG)

# 取消指定堆叠的合成任务
static func cancel_crafting_task_for_stack(stack_id: int):
	# 调用RecipeUtil取消合成任务和隐藏进度条
	var success = RecipeUtil.cancel_crafting(str(stack_id))
	if success:
		GlobalUtil.log("已取消堆叠ID " + str(stack_id) + " 的合成任务", GlobalUtil.LogLevel.INFO)
		# 通过RecipeUtil隐藏进度条
		RecipeUtil.hide_progress_bar_for_stack(stack_id)
	else:
		GlobalUtil.log("堆叠ID " + str(stack_id) + " 没有正在进行的合成任务", GlobalUtil.LogLevel.DEBUG)

# 从当前堆叠中移除卡牌但保持合成状态（用于卡牌放回原堆叠的情况）
static func remove_from_current_stack_preserve_crafting(card: Node2D, preserve_stack_id: int):
	var current_instance_id = card.get_instance_id()
	
	# 如果卡牌不在任何堆叠中，直接返回
	if not current_instance_id in card_to_stack:
		return
	
	var current_stack_id = card_to_stack[current_instance_id]
	
	# 从映射中移除
	card_to_stack.erase(current_instance_id)
	
	# 从堆叠中移除卡牌
	if current_stack_id in card_stacks:
		var stack = card_stacks[current_stack_id]
		stack.erase(card)
		
		# 如果堆叠只剩一张卡牌或为空，移除整个堆叠
		if stack.size() <= 1:
			# 如果还有一张卡牌，也要从映射中移除
			if stack.size() == 1:
				var remaining_card = stack[0]
				card_to_stack.erase(remaining_card.get_instance_id())
				# 重置卡牌的stack_id
				if remaining_card.has_method("set") and remaining_card.get("stack_id") != null:
					remaining_card.stack_id = -1
			
			# 移除堆叠
			card_stacks.erase(current_stack_id)
			GlobalUtil.log("移除空堆叠ID: " + str(current_stack_id), GlobalUtil.LogLevel.DEBUG)
			
			# 只有当不是要保持合成状态的堆叠时，才取消合成任务
			if current_stack_id != preserve_stack_id:
				cancel_crafting_task_for_stack(current_stack_id)
		else:
			# 堆叠还有多张卡牌时，只有当不是要保持合成状态的堆叠时，才取消合成任务
			if current_stack_id != preserve_stack_id:
				cancel_crafting_task_for_stack(current_stack_id)
	
	# 重置卡牌的stack_id
	if card.has_method("set") and card.get("stack_id") != null:
		card.stack_id = -1

# 从当前堆叠中移除卡牌
static func remove_from_current_stack(card: Node2D):
	var current_instance_id = card.get_instance_id()
	
	# 如果卡牌不在任何堆叠中，直接返回
	if not current_instance_id in card_to_stack:
		return
	
	var current_stack_id = card_to_stack[current_instance_id]
	
	# 从映射中移除
	card_to_stack.erase(current_instance_id)
	
	# 从堆叠中移除卡牌
	if current_stack_id in card_stacks:
		var stack = card_stacks[current_stack_id]
		stack.erase(card)
		
		# 如果堆叠只剩一张卡牌或为空，移除整个堆叠
		if stack.size() <= 1:
			# 如果还有一张卡牌，也要从映射中移除
			if stack.size() == 1:
				var remaining_card = stack[0]
				card_to_stack.erase(remaining_card.get_instance_id())
				# 重置卡牌的stack_id
				if remaining_card.has_method("set") and remaining_card.get("stack_id") != null:
					remaining_card.stack_id = -1
			
			# 移除堆叠
			card_stacks.erase(current_stack_id)
			GlobalUtil.log("移除空堆叠ID: " + str(current_stack_id), GlobalUtil.LogLevel.DEBUG)
		
		# 取消该堆叠的合成任务
		cancel_crafting_task_for_stack(current_stack_id)
	
	# 重置卡牌的stack_id
	if card.has_method("set") and card.get("stack_id") != null:
		card.stack_id = -1
	
	GlobalUtil.log("卡牌从堆叠ID " + str(current_stack_id) + " 中移除", GlobalUtil.LogLevel.DEBUG)

# 获取或创建卡牌的堆叠ID
static func get_or_create_stack_id(card: Node2D) -> int:
	var current_instance_id = card.get_instance_id()
	
	# 如果卡牌已经在堆叠中，返回现有的堆叠ID
	if current_instance_id in card_to_stack:
		return card_to_stack[current_instance_id]
	
	# 创建新的堆叠ID
	stack_id_counter += 1
	var new_stack_id = stack_id_counter
	
	# 创建新堆叠
	card_stacks[new_stack_id] = [card]
	card_to_stack[current_instance_id] = new_stack_id
	
	# 设置卡牌的stack_id
	if card.has_method("set") and card.get("stack_id") != null:
		card.stack_id = new_stack_id
	
	GlobalUtil.log("为卡牌创建新堆叠ID: " + str(new_stack_id), GlobalUtil.LogLevel.DEBUG)
	return new_stack_id

# 检查并尝试将当前卡牌堆叠到其他卡牌上
static func check_and_stack_card(card: Node2D, dragging_cards: Array[Node2D]):
	var current_pos = card.global_position
	# 首先尝试找到可堆叠的卡牌（包括正在合成的堆叠，用于检测是否回到原堆叠）
	var target_card = find_stackable_card_at_position(current_pos, card, dragging_cards, true)
	
	# 记录原始堆叠信息，用于检测是否需要取消合成任务
	var original_stack_id = -1
	var was_bottom_card = false
	var original_stack_cards = []
	var original_was_crafting = false
	var current_instance_id = card.get_instance_id()
	
	# 检查当前卡牌是否在堆叠中
	if is_in_stack_by_id(current_instance_id):
		original_stack_id = get_stack_id_by_card_id(current_instance_id)
		# 记录原始堆叠的所有卡牌
		if stack_exists(original_stack_id):
			original_stack_cards = card_stacks[original_stack_id].duplicate()
			original_was_crafting = RecipeUtil.is_stack_crafting_by_id(original_stack_id)
	
	if stack_exists(original_stack_id) and get_stack_size(original_stack_id) > 0:
		was_bottom_card = is_bottom_card(card, original_stack_id)
	
	if target_card != null and target_card != card:
		GlobalUtil.log("找到可堆叠的目标卡牌: " + target_card.card_name, GlobalUtil.LogLevel.DEBUG)
		
		# 检查是否回到原来的堆叠位置（相当于没有移动）
		var target_instance_id = target_card.get_instance_id()
		var is_returning_to_original = false
		var target_stack_id = -1
		
		if is_in_stack_by_id(target_instance_id):
			target_stack_id = get_stack_id_by_card_id(target_instance_id)
			is_returning_to_original = (target_stack_id == original_stack_id)
		
		# 如果目标堆叠正在合成中，但不是回到原堆叠，则拒绝堆叠
		if target_stack_id != -1 and RecipeUtil.is_stack_crafting_by_id(target_stack_id) and not is_returning_to_original:
			GlobalUtil.log("目标堆叠ID " + str(target_stack_id) + " 正在合成中，无法堆叠卡牌: " + card.card_name, GlobalUtil.LogLevel.INFO)
			return
		
		# 如果是回到原来的堆叠，且原来正在合成，保持合成状态
		if is_returning_to_original and original_was_crafting:
			GlobalUtil.log("卡牌回到原堆叠，保持合成状态", GlobalUtil.LogLevel.DEBUG)
			# 直接堆叠，不取消合成任务
			stack_card_group_on_target_preserve_crafting(card, target_card, dragging_cards, original_stack_id)
			return
		
		# 如果不是回到原来的位置，且原来不是底部卡牌，说明拆分了堆叠，需要取消原堆叠的合成任务
		if not is_returning_to_original and not was_bottom_card and original_stack_id != -1:
			cancel_crafting_task_for_stack(original_stack_id)
		
		stack_card_group_on_target(card, target_card, dragging_cards)
		
		# 堆叠状态变化完成后，检查原始堆叠是否能形成新的recipe
		if not is_returning_to_original and not was_bottom_card and original_stack_id != -1:
			if stack_exists(original_stack_id):
				check_stack_for_crafting(original_stack_id)
	else:
		GlobalUtil.log("未找到可堆叠的目标卡牌", GlobalUtil.LogLevel.DEBUG)
		
		# 检查是否是底部卡牌移动整个堆叠到空地
		var is_moving_whole_stack = was_bottom_card and dragging_cards.size() == (get_stack_size(original_stack_id) - 1)
		
		# 如果是移动整个堆叠且原来正在合成，尝试保持合成状态
		if is_moving_whole_stack and original_was_crafting:
			GlobalUtil.log("移动整个堆叠到空地，尝试保持合成状态", GlobalUtil.LogLevel.DEBUG)
			# 创建新堆叠但保持合成状态
			create_new_stack_with_cards_preserve_crafting(card, dragging_cards, original_stack_id, original_stack_cards)
			return
		
		# 如果原来不是底部卡牌且移动到了新位置，说明拆分了堆叠，需要取消原堆叠的合成任务
		if not was_bottom_card and original_stack_id != -1:
			cancel_crafting_task_for_stack(original_stack_id)
		
		# 如果没有找到目标卡牌，检查是否有连带拖拽的卡牌
		if dragging_cards.size() > 0:
			# 创建新的堆叠
			create_new_stack_with_cards(card, dragging_cards)
		else:
			# 如果只是单张卡牌，移除原有堆叠关系
			remove_from_current_stack(card)
		
		# 堆叠状态变化完成后，检查原始堆叠是否能形成新的recipe
		if not was_bottom_card and original_stack_id != -1:
			if stack_exists(original_stack_id):
				check_stack_for_crafting(original_stack_id)



# 将卡牌组堆叠到目标卡牌上并保持合成状态
static func stack_card_group_on_target_preserve_crafting(card: Node2D, target_card: Node2D, dragging_cards: Array[Node2D], original_stack_id: int):
	# 获取或创建目标卡牌的堆叠
	var target_stack_id = get_or_create_stack_for_card(target_card)
	
	# 首先处理主卡牌
	remove_from_current_stack_preserve_crafting(card, original_stack_id)
	
	# 确保目标堆叠仍然存在
	if not stack_exists(target_stack_id):
		target_stack_id = get_or_create_stack_for_card(target_card)
	
	add_card_to_stack(card, target_stack_id)
	card.stack_id = target_stack_id
	
	# 然后处理连带拖拽的卡牌
	for dragging_card in dragging_cards:
		if dragging_card != null and is_instance_valid(dragging_card):
			remove_from_current_stack_preserve_crafting(dragging_card, original_stack_id)
			
			if not stack_exists(target_stack_id):
				target_stack_id = get_or_create_stack_for_card(target_card)
			
			add_card_to_stack(dragging_card, target_stack_id)
			dragging_card.stack_id = target_stack_id
	
	# 更新堆叠中所有卡牌的位置
	update_stack_positions(target_stack_id)
	
	# 尝试恢复合成任务到目标堆叠
	var target_stack_cards = card_stacks[target_stack_id]
	var success = RecipeUtil.restore_crafting_task(str(original_stack_id), str(target_stack_id), target_stack_cards)
	if success:
		GlobalUtil.log("成功恢复合成任务到目标堆叠ID " + str(target_stack_id), GlobalUtil.LogLevel.INFO)
		RecipeUtil.show_progress_bar_for_stack(target_stack_id)
	else:
		GlobalUtil.log("无法恢复合成任务，可能原堆叠未在合成中", GlobalUtil.LogLevel.DEBUG)
	
	GlobalUtil.log("卡牌组已堆叠到 " + target_card.card_name + " 上，保持合成状态，主卡牌: " + card.card_name + "，连带卡牌数: " + str(dragging_cards.size()), GlobalUtil.LogLevel.INFO)

# 将卡牌组（主卡牌和连带卡牌）堆叠到目标卡牌上
static func stack_card_group_on_target(card: Node2D, target_card: Node2D, dragging_cards: Array[Node2D]):
	# 获取或创建目标卡牌的堆叠
	var target_stack_id = get_or_create_stack_for_card(target_card)
	
	# 检查目标堆叠是否正在合成中
	if RecipeUtil.is_stack_crafting_by_id(target_stack_id):
		GlobalUtil.log("目标堆叠ID " + str(target_stack_id) + " 正在合成中，无法堆叠卡牌组: " + card.card_name, GlobalUtil.LogLevel.INFO)
		return
	
	# 记录原始堆叠ID，用于后续检查（所有卡牌来自同一个堆叠）
	var original_stack_id = -1
	var current_instance_id = card.get_instance_id()
	if is_in_stack_by_id(current_instance_id):
		original_stack_id = get_stack_id_by_card_id(current_instance_id)
	
	# 首先处理主卡牌
	remove_from_current_stack(card)
	
	# 确保目标堆叠仍然存在（可能在remove_from_current_stack中被删除）
	if not stack_exists(target_stack_id):
		# 重新创建目标堆叠
		target_stack_id = get_or_create_stack_for_card(target_card)
	
	add_card_to_stack(card, target_stack_id)
	card.stack_id = target_stack_id
	
	# 然后处理连带拖拽的卡牌
	for dragging_card in dragging_cards:
		if dragging_card != null and is_instance_valid(dragging_card):
			# 移除连带卡牌的旧堆叠关系
			remove_from_current_stack(dragging_card)
			
			# 确保目标堆叠仍然存在
			if not stack_exists(target_stack_id):
				target_stack_id = get_or_create_stack_for_card(target_card)
			
			# 添加到目标堆叠
			add_card_to_stack(dragging_card, target_stack_id)
			dragging_card.stack_id = target_stack_id
	
	# 更新堆叠中所有卡牌的位置
	update_stack_positions(target_stack_id)
	
	# 检查目标堆叠是否匹配配方并开始合成
	check_stack_for_crafting(target_stack_id)
	
	# 检查原始堆叠是否依然存在，如果存在也需要检查合成条件
	if original_stack_id != -1 and stack_exists(original_stack_id) and original_stack_id != target_stack_id:
		check_stack_for_crafting(original_stack_id)
		GlobalUtil.log("检查原始堆叠ID " + str(original_stack_id) + " 的合成条件", GlobalUtil.LogLevel.DEBUG)
	
	GlobalUtil.log("卡牌组已堆叠到 " + target_card.card_name + " 上，主卡牌: " + card.card_name + "，连带卡牌数: " + str(dragging_cards.size()), GlobalUtil.LogLevel.INFO)

# 创建新的堆叠包含主卡牌和连带卡牌，并保持合成状态
static func create_new_stack_with_cards_preserve_crafting(card: Node2D, dragging_cards: Array[Node2D], original_stack_id: int, original_stack_cards: Array):
	# 移除主卡牌的旧堆叠关系，但保持合成状态
	remove_from_current_stack_preserve_crafting(card, original_stack_id)
	
	# 创建新堆叠
	var new_stack_id = create_new_stack_with_card(card)
	
	# 添加连带拖拽的卡牌
	for dragging_card in dragging_cards:
		if dragging_card != null and is_instance_valid(dragging_card):
			# 移除连带卡牌的旧堆叠关系，但保持合成状态
			remove_from_current_stack_preserve_crafting(dragging_card, original_stack_id)
			# 添加到新堆叠
			add_card_to_stack(dragging_card, new_stack_id)
			dragging_card.stack_id = new_stack_id
	
	# 更新堆叠中所有卡牌的位置
	update_stack_positions(new_stack_id)
	
	# 检查新堆叠是否与原堆叠卡牌相同，如果相同则尝试恢复合成状态
	var new_stack_cards = card_stacks[new_stack_id]
	var cards_match = true
	
	# 检查卡牌数量是否相同
	if new_stack_cards.size() != original_stack_cards.size():
		cards_match = false
	else:
		# 检查每张卡牌是否相同（通过卡牌名称比较）
		for i in range(new_stack_cards.size()):
			var found = false
			for original_card in original_stack_cards:
				if new_stack_cards[i].card_name == original_card.card_name:
					found = true
					break
			if not found:
				cards_match = false
				break
	
	# 如果卡牌完全匹配，尝试恢复合成状态
	if cards_match:
		GlobalUtil.log("新堆叠卡牌与原堆叠相同，尝试恢复合成状态", GlobalUtil.LogLevel.DEBUG)
		# 尝试恢复原有的合成任务和进度
		var success = RecipeUtil.restore_crafting_task(str(original_stack_id), str(new_stack_id), new_stack_cards)
		if success:
			GlobalUtil.log("成功恢复堆叠ID " + str(new_stack_id) + " 的合成进度", GlobalUtil.LogLevel.INFO)
			RecipeUtil.show_progress_bar_for_stack(new_stack_id)
		else:
			# 如果恢复失败，正常开始新的合成
			check_stack_for_crafting(new_stack_id)
	else:
		# 如果卡牌不匹配，正常检查合成条件
		check_stack_for_crafting(new_stack_id)
	
	GlobalUtil.log("创建新堆叠包含主卡牌和连带卡牌，保持合成状态，主卡牌: " + card.card_name + "，连带卡牌数: " + str(dragging_cards.size()), GlobalUtil.LogLevel.INFO)

# 创建新的堆叠包含主卡牌和连带卡牌
static func create_new_stack_with_cards(card: Node2D, dragging_cards: Array[Node2D]):
	# 移除主卡牌的旧堆叠关系
	remove_from_current_stack(card)
	
	# 创建新堆叠
	var new_stack_id = create_new_stack_with_card(card)
	
	# 添加连带拖拽的卡牌
	for dragging_card in dragging_cards:
		if dragging_card != null and is_instance_valid(dragging_card):
			# 移除连带卡牌的旧堆叠关系
			remove_from_current_stack(dragging_card)
			# 添加到新堆叠
			add_card_to_stack(dragging_card, new_stack_id)
			dragging_card.stack_id = new_stack_id
	
	# 更新堆叠中所有卡牌的位置
	update_stack_positions(new_stack_id)
	
	# 检查堆叠是否匹配配方并开始合成
	check_stack_for_crafting(new_stack_id)
	
	GlobalUtil.log("创建新堆叠，ID: " + str(new_stack_id) + "，主卡牌: " + card.card_name + "，连带卡牌数: " + str(dragging_cards.size()), GlobalUtil.LogLevel.INFO)

# 获取堆叠系统调试信息
static func get_stack_debug_info() -> String:
	var debug_info = "堆叠系统调试信息:\n"
	debug_info += "总堆叠数: " + str(card_stacks.size()) + "\n"
	debug_info += "卡牌到堆叠映射数: " + str(card_to_stack.size()) + "\n"
	
	for stack_id in card_stacks.keys():
		var stack = card_stacks[stack_id]
		debug_info += "堆叠ID " + str(stack_id) + ": " + str(stack.size()) + " 张卡牌\n"
		for i in range(stack.size()):
			var card = stack[i]
			if card != null and is_instance_valid(card):
				debug_info += "  [" + str(i) + "] " + card.card_name + "\n"
			else:
				debug_info += "  [" + str(i) + "] 无效卡牌\n"
	
	return debug_info

# 将卡牌堆叠到目标卡牌上（单张卡牌）
static func stack_card_on_target(source_card: Node2D, target_card: Node2D):
	var source_instance_id = source_card.get_instance_id()
	var target_instance_id = target_card.get_instance_id()
	
	# 获取或创建目标卡牌的堆叠ID
	var target_stack_id = get_or_create_stack_id(target_card)
	
	# 检查目标堆叠是否正在合成中
	if RecipeUtil.is_stack_crafting_by_id(target_stack_id):
		GlobalUtil.log("目标堆叠ID " + str(target_stack_id) + " 正在合成中，无法堆叠卡牌: " + source_card.card_name, GlobalUtil.LogLevel.INFO)
		return
	
	# 如果源卡牌已经在堆叠中，先移除
	remove_from_current_stack(source_card)
	
	# 将源卡牌添加到目标堆叠
	card_stacks[target_stack_id].append(source_card)
	card_to_stack[source_instance_id] = target_stack_id
	
	# 设置源卡牌的stack_id
	if source_card.has_method("set") and source_card.get("stack_id") != null:
		source_card.stack_id = target_stack_id
	
	# 更新堆叠中所有卡牌的位置
	update_stack_positions(target_stack_id)
	
	# 检查是否可以开始合成
	check_stack_for_crafting(target_stack_id)
	
	GlobalUtil.log("卡牌堆叠到目标卡牌，堆叠ID: " + str(target_stack_id), GlobalUtil.LogLevel.DEBUG)

# 将卡牌组堆叠到目标卡牌上
static func stack_cards_on_target(source_cards: Array[Node2D], target_card: Node2D):
	var target_instance_id = target_card.get_instance_id()
	
	# 获取或创建目标卡牌的堆叠ID
	var target_stack_id = get_or_create_stack_id(target_card)
	
	# 检查目标堆叠是否正在合成中
	if RecipeUtil.is_stack_crafting_by_id(target_stack_id):
		GlobalUtil.log("目标堆叠ID " + str(target_stack_id) + " 正在合成中，无法堆叠卡牌组", GlobalUtil.LogLevel.INFO)
		return
	
	# 将所有源卡牌添加到目标堆叠
	for source_card in source_cards:
		if source_card == target_card:
			continue  # 跳过目标卡牌自身
		
		var source_instance_id = source_card.get_instance_id()
		
		# 如果源卡牌已经在堆叠中，先移除
		remove_from_current_stack(source_card)
		
		# 将源卡牌添加到目标堆叠
		card_stacks[target_stack_id].append(source_card)
		card_to_stack[source_instance_id] = target_stack_id
		
		# 设置源卡牌的stack_id
		if source_card.has_method("set") and source_card.get("stack_id") != null:
			source_card.stack_id = target_stack_id
	
	# 更新堆叠中所有卡牌的位置
	update_stack_positions(target_stack_id)
	
	# 检查是否可以开始合成
	check_stack_for_crafting(target_stack_id)
	
	GlobalUtil.log("卡牌组堆叠到目标卡牌，堆叠ID: " + str(target_stack_id) + "，卡牌数量: " + str(source_cards.size()), GlobalUtil.LogLevel.DEBUG)

# 更新堆叠中所有卡牌的位置
static func update_stack_positions(stack_id: int):
	if not stack_id in card_stacks:
		return
	
	var stack = card_stacks[stack_id]
	if stack.size() <= 1:
		return
	
	# 获取底部卡牌的位置作为基准
	var base_position = stack[0].global_position
	
	# 更新每张卡牌的位置
	for i in range(1, stack.size()):
		var card = stack[i]
		if card != null and is_instance_valid(card):
			# 计算堆叠偏移位置（后面的卡牌向下偏移，显示在上面）
			var offset = Vector2(0, i * GlobalConstants.CARD_STACK_OFFSET)
			card.global_position = base_position + offset
	
	# 同步更新进度条位置
	RecipeUtil.update_progress_bar_position_for_stack(stack_id)
	
	GlobalUtil.log("更新堆叠ID " + str(stack_id) + " 中 " + str(stack.size()) + " 张卡牌的位置", GlobalUtil.LogLevel.DEBUG)

# 在指定位置查找可以堆叠的卡牌
static func find_stackable_card_at_position(position: Vector2, exclude_card: Node2D = null, dragging_cards: Array[Node2D] = [], allow_crafting_stacks: bool = false) -> Node2D:
	var CardUtil = preload("res://scripts/cards/card_util.gd")
	var closest_card: Node2D = null
	var closest_distance: float = GlobalConstants.CARD_STACK_DETECTION_RANGE
	
	for card in CardUtil.all_cards:
		if card == null or not is_instance_valid(card):
			continue
		
		# 排除指定的卡牌
		if card == exclude_card:
			continue
		
		# 排除连带拖拽的卡牌
		if card in dragging_cards:
			continue
		
		# 检查目标卡牌所在的堆叠是否正在合成中（除非明确允许）
		var card_id = card.get_instance_id()
		if is_in_stack_by_id(card_id) and not allow_crafting_stacks:
			var target_stack_id = get_stack_id_by_card_id(card_id)
			if RecipeUtil.is_stack_crafting_by_id(target_stack_id):
				GlobalUtil.log("堆叠ID " + str(target_stack_id) + " 正在合成中，跳过卡牌: " + card.card_name, GlobalUtil.LogLevel.DEBUG)
				continue
		
		# 计算距离
		var distance = card.global_position.distance_to(position)
		
		# 如果在检测范围内且距离更近
		if distance < closest_distance:
			closest_distance = distance
			closest_card = card
	
	if closest_card != null:
		GlobalUtil.log("在位置 " + str(position) + " 找到可堆叠卡牌，距离: " + str(closest_distance), GlobalUtil.LogLevel.DEBUG)
	
	return closest_card

# 检查并尝试堆叠卡牌
static func try_stack_card(card: Node2D, position: Vector2) -> bool:
	# 查找可堆叠的目标卡牌
	var target_card = find_stackable_card_at_position(position, card)
	
	if target_card == null:
		return false
	
	# 检查目标卡牌所在堆叠是否正在合成中
	var target_card_id = target_card.get_instance_id()
	if is_in_stack_by_id(target_card_id):
		var target_stack_id = get_stack_id_by_card_id(target_card_id)
		if RecipeUtil.is_stack_crafting_by_id(target_stack_id):
			GlobalUtil.log("目标堆叠ID " + str(target_stack_id) + " 正在合成中，无法堆叠卡牌: " + card.card_name, GlobalUtil.LogLevel.INFO)
			return false
	
	# 获取当前卡牌上方的所有卡牌（用于连带拖拽）
	var cards_above = get_cards_above(card)
	
	if cards_above.size() > 0:
		# 如果有上方卡牌，将整个卡牌组堆叠到目标
		var all_cards_to_stack = [card] + cards_above
		stack_cards_on_target(all_cards_to_stack, target_card)
	else:
		# 只堆叠当前卡牌
		stack_card_on_target(card, target_card)
	
	return true

# 检查卡牌ID是否在堆叠中
static func is_in_stack_by_id(card_id: int) -> bool:
	return card_id in card_to_stack

# 根据卡牌ID获取堆叠ID
static func get_stack_id_by_card_id(card_id: int) -> int:
	if card_id in card_to_stack:
		return card_to_stack[card_id]
	return -1

# 检查堆叠是否存在
static func stack_exists(stack_id: int) -> bool:
	return stack_id in card_stacks

# 将卡牌添加到指定堆叠
static func add_card_to_stack(card: Node2D, stack_id: int):
	if not stack_id in card_stacks:
		card_stacks[stack_id] = []
	
	card_stacks[stack_id].append(card)
	card_to_stack[card.get_instance_id()] = stack_id
	card.stack_id = stack_id

# 创建新堆叠并添加卡牌
static func create_new_stack_with_card(card: Node2D) -> int:
	var new_stack_id = stack_id_counter
	stack_id_counter += 1
	
	# 初始化堆叠
	card_stacks[new_stack_id] = [card]
	card_to_stack[card.get_instance_id()] = new_stack_id
	card.stack_id = new_stack_id
	
	GlobalUtil.log("为卡牌 " + card.card_name + " 创建新堆叠，ID: " + str(new_stack_id), GlobalUtil.LogLevel.DEBUG)
	return new_stack_id

# 获取堆叠大小
static func get_stack_size(stack_id: int) -> int:
	if stack_id in card_stacks:
		return card_stacks[stack_id].size()
	return 0

# 检查卡牌是否是堆叠底部卡牌
static func is_bottom_card(card: Node2D, stack_id: int) -> bool:
	if not stack_id in card_stacks:
		return false
	
	var stack = card_stacks[stack_id]
	if stack.size() == 0:
		return false
	
	return stack[0] == card

# 获取堆叠中的卡牌数组
static func get_stack_cards(stack_id: int) -> Array:
	if stack_id in card_stacks:
		return card_stacks[stack_id]
	return []

# 获取或创建卡牌的堆叠ID
static func get_or_create_stack_for_card(card: Node2D) -> int:
	var card_id = card.get_instance_id()
	
	# 如果卡牌已经在堆叠中，返回现有堆叠ID
	if card_id in card_to_stack:
		return card_to_stack[card_id]
	
	# 否则创建新堆叠
	return create_new_stack_with_card(card)
