extends "res://scripts/cards/card_pack_base.gd"
# 由于全局已存在同名类，这里移除class_name声明

# 在子类中不应重新声明父类已有的变量

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("打击卡包", "包含基础打击卡牌的卡包")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/strike.png")
	
	# 设置卡牌数据
	set_card_data("打击", "造成6点伤害")
	
	# 设置点击特效：打印随机数
	on_click = strike_click_effect

# 打击卡牌的点击特效：召唤400x300容器
# 参数: card_instance - 触发点击的卡牌实例
func strike_click_effect(card_instance):
	# 获取容器工具类的引用（用于静态方法调用）
	var container_util_class = preload("res://scripts/container/container_util.gd")
	
	# 如果已经存在容器，先移除（确保场上只能存在一个容器）
	if container_util_class.has_container():
		container_util_class.remove_current_container()
		# 等待一帧确保容器完全移除
		await card_instance.get_tree().process_frame
	
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 卡牌位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 创建容器实例
	var container_instance = preload("res://scripts/container/container_util.gd").new()
	
	# 从容器类型加载容器数据
	container_instance.load_from_container_type("400x300")
	
	# 设置容器位置（在卡牌左侧，向左移动一个卡牌宽度）
	var container_position = Vector2(card_position.x - 220 - GlobalConstants.CARD_WIDTH, card_position.y)
	container_instance.global_position = container_position
	
	# 设置召唤此容器的卡牌引用
	container_instance.set_summoner_card(card_instance)
	
	# 将容器添加到场景树中（这会触发_ready方法，初始化UI组件）
	card_instance.get_tree().current_scene.add_child(container_instance)
	
	# 等待一帧确保容器完全初始化
	await card_instance.get_tree().process_frame
	
	# 设置容器的标题和描述（使用召唤卡牌的card_base属性）
	var card_title = card_instance.card_name if card_instance.card_name else "打击"
	var card_desc = card_instance.description if card_instance.description else "造成6点伤害"
	container_instance.set_title_and_description_ui(card_title, card_desc)
	GlobalUtil.log("设置容器标题和描述 - 标题: " + card_title + ", 描述: " + card_desc, GlobalUtil.LogLevel.DEBUG)
	
	# 生成攻击数据
	var damage = randi() % 6 + 6  # 生成6-11的随机伤害值
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 打击卡牌特效触发！造成伤害: " + str(damage) + ", 容器位置: " + str(container_position), GlobalUtil.LogLevel.INFO)
