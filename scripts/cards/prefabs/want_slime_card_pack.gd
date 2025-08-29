extends "res://scripts/cards/card_pack_base.gd"
# Want Slime卡包类

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("Want Slime卡包", "包含召唤史莱姆的卡牌")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/wantSlime.jpg")
	
	# 设置卡牌数据
	set_card_data("Want Slime", "召唤一只可爱的史莱姆")
	
	# 设置点击特效：召唤史莱姆效果
	on_click = want_slime_click_effect

# Want Slime卡牌的点击特效：召唤史莱姆
# 参数: card_instance - 触发点击的卡牌实例
func want_slime_click_effect(card_instance):
	# 获取容器工具类的引用（用于静态方法调用）
	var ctrl_util_class = preload("res://scripts/ctrl/ctrl_util.gd")
	
	# 检查是否已有控制器存在，如果有则移除
	if ctrl_util_class.has_ctrl():
		ctrl_util_class.remove_current_ctrl()
		# 等待一帧确保容器完全移除
		await card_instance.get_tree().process_frame
	
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 卡牌位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 创建控制器实例
	var ctrl_instance = preload("res://scripts/ctrl/ctrl_util.gd").new()
	
	# 从控制器类型加载控制器数据（改为小控制器）
	ctrl_instance.load_from_ctrl_type("400x300")
	
	# Control实现的容器会自动布局到左下角，无需手动设置位置
	
	# 将控制器添加到场景树中（这会触发_ready方法，初始化UI组件）
	card_instance.get_tree().current_scene.add_child(ctrl_instance)
	
	# 等待一帧确保控制器完全初始化
	await card_instance.get_tree().process_frame
	
	# 设置控制器的标题和描述（使用召唤卡牌的card_base属性）
	var card_title = card_instance.card_name if card_instance.card_name else "Want Slime"
	var card_desc = card_instance.description if card_instance.description else "召唤一只可爱的史莱姆"
	ctrl_instance.set_ctrl_title_and_description(card_title, card_desc)
	GlobalUtil.log("设置容器标题和描述 - 标题: " + card_title + ", 描述: " + card_desc, GlobalUtil.LogLevel.DEBUG)
	
	# 生成史莱姆数据
	var slime_hp = randi() % 10 + 5  # 生成5-14的随机生命值
	var slime_attack = randi() % 3 + 1  # 生成1-3的随机攻击力
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " Want Slime卡牌特效触发！召唤史莱姆 - 生命值: " + str(slime_hp) + ", 攻击力: " + str(slime_attack), GlobalUtil.LogLevel.INFO)
