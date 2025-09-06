extends "res://scripts/cards/card_pack_base.gd"
# 旧木屋卡包

# 预加载工具类
const CardUtil = preload("res://scripts/cards/card_util.gd")

# 点击计数器，用于跟踪点击次数
var click_count: int = 0

# 初始化函数
func _init():
	# 调用父类的初始化函数，设置名称和描述
	super._init("旧木屋", "破旧的木制房屋，可以提供基础庇护")
	
	# 设置卡牌类型标识符
	card_type = "old_wooden_house"
	
	# 覆盖父类的pack_image变量
	pack_image = preload("res://assets/images/旧木屋.png")
	
	# 设置卡牌数据
	set_card_data("旧木屋", "破旧的木制房屋，可以提供基础庇护")
	
	# 设置点击特效
	on_click = old_wooden_house_click_effect
	
	# 初始化点击计数器
	click_count = 0

# 旧木屋卡牌的点击特效
# 参数: card_instance - 触发点击的卡牌实例
func old_wooden_house_click_effect(card_instance):
	# 获取卡牌位置
	var card_position = card_instance.global_position
	GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 旧木屋卡牌特效触发！位置: " + str(card_position), GlobalUtil.LogLevel.INFO)
	
	# 增加点击计数
	click_count += 1
	GlobalUtil.log("旧木屋点击次数: " + str(click_count), GlobalUtil.LogLevel.DEBUG)
	
	# 根据点击次数执行不同的逻辑
	if click_count == 1:
		# 第一次点击：显示翻找前提示，生成木板
		GlobalUtil.log("这里只有一些垃圾", GlobalUtil.LogLevel.INFO)
		# 位置生成现在直接基于all_cards，无需手动清空
		var target_position = CardUtil.get_valid_position(card_position, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
		var wood = CardUtil.create_card_from_pool(card_instance.get_tree().root, "wood", card_position)
		if wood:
			CardUtil.move_card(wood, target_position)
			GlobalUtil.log("旧木屋：生成木板卡牌，位置: " + str(target_position), GlobalUtil.LogLevel.INFO)
	
	elif click_count == 2:
		# 第二次点击：生成第二块木板
		var target_position = CardUtil.get_valid_position(card_position, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
		var wood = CardUtil.create_card_from_pool(card_instance.get_tree().root, "wood", card_position)
		if wood:
			CardUtil.move_card(wood, target_position)
			GlobalUtil.log("旧木屋：生成第二块木板卡牌，位置: " + str(target_position), GlobalUtil.LogLevel.INFO)
	
	elif click_count == 3:
		# 第三次点击：生成燧石
		var target_position = CardUtil.get_valid_position(card_position, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
		var flint = CardUtil.create_card_from_pool(card_instance.get_tree().root, "flint", card_position)
		if flint:
			CardUtil.move_card(flint, target_position)
			GlobalUtil.log("旧木屋：生成燧石卡牌，位置: " + str(target_position), GlobalUtil.LogLevel.INFO)
	
	elif click_count == 4:
		# 第四次点击：生成第二块燧石，显示翻找后提示
		var target_position = CardUtil.get_valid_position(card_position, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
		var flint = CardUtil.create_card_from_pool(card_instance.get_tree().root, "flint", card_position)
		if flint:
			CardUtil.move_card(flint, target_position)
			GlobalUtil.log("旧木屋：生成第二块燧石卡牌，位置: " + str(target_position), GlobalUtil.LogLevel.INFO)
		GlobalUtil.log("这里什么都没有了", GlobalUtil.LogLevel.INFO)
	
	else:
		# 超过4次点击：只显示翻找后提示
		GlobalUtil.log("这里什么都没有了", GlobalUtil.LogLevel.INFO)
