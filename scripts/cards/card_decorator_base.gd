extends Resource
class_name CardDecoratorBase

# 卡牌装饰器基类
# 使用装饰器模式为卡牌添加额外的行为和属性

# 被装饰的卡牌实例引用
var card_instance: Node2D = null

# 装饰器的标签名称
var decorator_tag: String = ""

# 初始化装饰器
func _init(p_card_instance: Node2D, p_tag: String):
	card_instance = p_card_instance
	decorator_tag = p_tag
	
	# 将标签添加到卡牌的card_pack中
	if card_instance and card_instance.card_pack:
		card_instance.card_pack.add_tag(p_tag)
		
	# 应用装饰器效果
	apply_decorator()

# 应用装饰器效果（子类重写）
func apply_decorator():
	pass

# 移除装饰器效果（子类重写）
func remove_decorator():
	pass

# 检查装饰器是否激活
func is_active() -> bool:
	if not card_instance or not card_instance.card_pack:
		return false
	return card_instance.card_pack.has_tag(decorator_tag)

# 销毁装饰器
func destroy():
	remove_decorator()
	if card_instance and card_instance.card_pack:
		card_instance.card_pack.remove_tag(decorator_tag)
	card_instance = null