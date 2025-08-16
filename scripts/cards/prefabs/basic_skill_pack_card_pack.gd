extends "res://scripts/cards/card_pack_base.gd"
# Basic Skill Pack卡包类

# 导入卡牌工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")

# 卡牌生成计数器
var generated_cards_count: int = 0
# 最大生成卡牌数量
const MAX_GENERATED_CARDS: int = 5

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("Basic Skill Pack卡包", "包含基础技能的卡包")
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/basicSkillPack.jpg")
	
	# 设置卡牌数据
	set_card_data("Basic Skill Pack", "生成随机卡牌并移动")
	
	# 设置点击特效：生成卡牌效果
	on_click = basic_skill_pack_click_effect

# Basic Skill Pack卡牌的点击特效：生成随机卡牌
# 参数: card_instance - 触发点击的卡牌实例
func basic_skill_pack_click_effect(card_instance):
	# 检查是否已达到最大生成数量
	if generated_cards_count >= MAX_GENERATED_CARDS:
		GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " Basic Skill Pack已生成" + str(MAX_GENERATED_CARDS) + "张卡牌，开始回收", GlobalUtil.LogLevel.INFO)
		# 回收当前卡牌到池中
		CardUtil.return_card_to_pool(card_instance)
		return
	
	# 随机选择卡牌类型（打击或防御）
	var card_types = ["strike", "defend"]
	var random_type = card_types[randi() % card_types.size()]
	
	# 获取当前卡牌的位置作为生成位置
	var spawn_position = card_instance.position
	
	# 获取根节点（通过卡牌实例的父节点）
	var root_node = card_instance.get_parent()
	if root_node == null:
		GlobalUtil.log("无法获取根节点，生成卡牌失败", GlobalUtil.LogLevel.ERROR)
		return
	
	# 确保卡牌池已初始化
	CardUtil.initialize_card_pool(root_node)
	
	# 从卡牌池创建新卡牌
	var new_card = CardUtil.create_card_from_pool(root_node, random_type, spawn_position)
	if new_card == null:
		GlobalUtil.log("创建卡牌失败", GlobalUtil.LogLevel.ERROR)
		return
	
	# 设置新卡牌的名称
	generated_cards_count += 1
	var type_name = "打击" if random_type == "strike" else "防御"
	new_card.card_name = "技能包生成" + type_name + " #" + str(generated_cards_count)
	card_instance.bring_to_front()
	# 更新新卡牌显示
	new_card.update_display()
	
	# 使用随机移动功能移动新卡牌
	var move_distance = CardUtil.random_move_card(new_card)
	
	# 记录生成信息
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " Basic Skill Pack生成了" + type_name + "卡牌，移动距离: " + str(move_distance) + "，已生成: " + str(generated_cards_count) + "/" + str(MAX_GENERATED_CARDS), GlobalUtil.LogLevel.INFO)
	
	# 如果生成了第五张卡牌，立即回收自身
	if generated_cards_count >= MAX_GENERATED_CARDS:
		GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " Basic Skill Pack已生成第" + str(MAX_GENERATED_CARDS) + "张卡牌，立即回收自身", GlobalUtil.LogLevel.INFO)
		CardUtil.return_card_to_pool(card_instance)
