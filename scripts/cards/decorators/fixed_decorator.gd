extends "res://scripts/cards/card_decorator_base.gd"
class_name FixedDecorator

# 固定装饰器
# 为卡牌添加"fixed"标签，防止卡牌被拖动

# 初始化固定装饰器
func _init(p_card_instance: Node2D):
	super._init(p_card_instance, "fixed")

# 应用装饰器效果
func apply_decorator():
	if not card_instance:
		return
	
	GlobalUtil.log("应用固定装饰器到卡牌实例ID:" + str(card_instance.get_instance_id()), GlobalUtil.LogLevel.DEBUG)
	
	# 固定装饰器不需要禁用输入，拖拽控制由card_util.gd中的逻辑处理
	# 这里只需要确保卡牌包有"fixed"标签即可
	if card_instance.card_pack and not card_instance.card_pack.has_tag("fixed"):
		card_instance.card_pack.add_tag("fixed")
	
	# 停止当前拖拽（如果正在拖拽）
	if card_instance.has_method("set") and "is_dragging" in card_instance:
		card_instance.is_dragging = false
	
	GlobalUtil.log("固定装饰器应用完成，卡牌拖拽将被card_util.gd逻辑控制", GlobalUtil.LogLevel.DEBUG)

# 移除装饰器效果
func remove_decorator():
	if not card_instance:
		return
	
	GlobalUtil.log("移除固定装饰器从卡牌实例ID:" + str(card_instance.get_instance_id()), GlobalUtil.LogLevel.DEBUG)
	
	# 从卡牌包中移除"fixed"标签
	if card_instance.card_pack and card_instance.card_pack.has_tag("fixed"):
		card_instance.card_pack.remove_tag("fixed")
	
	GlobalUtil.log("固定装饰器移除完成，卡牌已恢复拖拽功能", GlobalUtil.LogLevel.DEBUG)

# 检查卡牌是否被固定
static func is_card_fixed(card_instance: Node2D) -> bool:
	if not card_instance or not card_instance.card_pack:
		return false
	return card_instance.card_pack.has_tag("fixed")
