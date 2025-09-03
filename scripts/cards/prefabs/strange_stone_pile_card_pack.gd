extends "res://scripts/cards/card_pack_base.gd"
# 奇怪石堆卡包

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("奇怪石堆", "散发着神秘气息的石头堆，似乎蕴含着未知的力量")
	
	# 设置卡牌类型标识符
	card_type = "strange_stone_pile"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/奇怪石堆.png")
	
	# 设置卡牌数据
	set_card_data("奇怪石堆", "散发着神秘气息的石头堆，似乎蕴含着未知的力量")
	
	# 添加fixed标签，防止拖动
	add_tag("fixed")
	
	# 设置点击特效
	on_click = strange_stone_pile_click_effect
	
	# 设置合成完成后的回调
	after_recipe_done = strange_stone_pile_after_recipe_done

# 奇怪石堆卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func strange_stone_pile_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 奇怪石堆卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 奇怪石堆的特效逻辑
	GlobalUtil.log("奇怪石堆：神秘的石堆散发出诡异的光芒，似乎隐藏着秘密", GlobalUtil.LogLevel.INFO)

# 合成完成后的回调方法
func strange_stone_pile_after_recipe_done(card_instance, crafting_cards: Array):
		GlobalUtil.log("奇怪石堆参与合成完成，检查事件标签", GlobalUtil.LogLevel.INFO)
		
		# 获取卡牌实例的所有标签
		var tags = card_instance.get_tags()
		GlobalUtil.log("奇怪石堆获取到的标签: " + str(tags), GlobalUtil.LogLevel.INFO)
		
		# 检查card_pack是否存在
		if card_instance.card_pack:
			var pack_tags = card_instance.card_pack.get_tags()
			GlobalUtil.log("奇怪石堆card_pack标签: " + str(pack_tags), GlobalUtil.LogLevel.INFO)
		else:
			GlobalUtil.log("奇怪石堆card_pack为null", GlobalUtil.LogLevel.ERROR)
		
		# 遍历标签，查找事件标签
		for tag in tags:
			GlobalUtil.log("检查标签: " + str(tag), GlobalUtil.LogLevel.DEBUG)
			if tag.begins_with("event_"):
				# 提取事件ID
				var event_id_str = tag.substr(6)  # 移除"event_"前缀
				var event_id = int(event_id_str)
				
				# 触发事件
				var event_util = card_instance.get_node("/root/EventUtil")
				if event_util:
					event_util.trigger_event(event_id)
					GlobalUtil.log("奇怪石堆触发事件: " + str(event_id), GlobalUtil.LogLevel.INFO)
				else:
					GlobalUtil.log("无法找到EventUtil节点", GlobalUtil.LogLevel.ERROR)
		
		# 回收卡牌实例
		const CardUtil = preload("res://scripts/cards/card_util.gd")
		CardUtil.remove(card_instance)
