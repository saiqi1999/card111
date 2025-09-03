extends Resource
class_name CardDecoratorManager

# 卡牌装饰器管理器
# 统一管理卡牌实例的所有装饰器

# 装饰器存储字典，key为装饰器标签，value为装饰器实例
var decorators: Dictionary = {}

# 被管理的卡牌实例
var card_instance: Node2D = null

# 初始化管理器
func _init(p_card_instance: Node2D):
	card_instance = p_card_instance
	
	# 检查卡牌已有的标签，自动创建对应的装饰器
	if card_instance and card_instance.has_method("get_tags"):
		var existing_tags = card_instance.get_tags()
		for tag in existing_tags:
			if tag == "fixed":
				# 为fixed标签创建FixedDecorator
				add_decorator(FixedDecorator)
				GlobalUtil.log("为卡牌实例ID:" + str(card_instance.get_instance_id()) + " 自动创建fixed装饰器", GlobalUtil.LogLevel.DEBUG)

# 添加装饰器
func add_decorator(decorator_class, tag: String = ""):
	if not card_instance:
		GlobalUtil.log("卡牌实例无效，无法添加装饰器", GlobalUtil.LogLevel.ERROR)
		return null
	
	# 如果没有指定标签，使用装饰器类的默认标签
	var decorator_instance = null
	
	# 根据装饰器类型创建实例
	if decorator_class == FixedDecorator:
		decorator_instance = FixedDecorator.new(card_instance)
		tag = "fixed"
	else:
		# 通用装饰器创建方式
		if tag == "":
			GlobalUtil.log("未知装饰器类型且未指定标签", GlobalUtil.LogLevel.ERROR)
			return null
		decorator_instance = decorator_class.new(card_instance, tag)
	
	# 检查是否已存在相同标签的装饰器
	if tag in decorators:
		GlobalUtil.log("装饰器标签 '" + tag + "' 已存在，移除旧装饰器", GlobalUtil.LogLevel.WARNING)
		remove_decorator(tag)
	
	# 添加新装饰器
	decorators[tag] = decorator_instance
	GlobalUtil.log("成功添加装饰器 '" + tag + "' 到卡牌实例ID:" + str(card_instance.get_instance_id()), GlobalUtil.LogLevel.DEBUG)
	
	return decorator_instance

# 移除装饰器
func remove_decorator(tag: String) -> bool:
	if tag in decorators:
		var decorator = decorators[tag]
		decorator.destroy()
		decorators.erase(tag)
		GlobalUtil.log("成功移除装饰器 '" + tag + "'", GlobalUtil.LogLevel.DEBUG)
		return true
	else:
		GlobalUtil.log("装饰器 '" + tag + "' 不存在", GlobalUtil.LogLevel.WARNING)
		return false

# 检查是否有指定装饰器
func has_decorator(tag: String) -> bool:
	return tag in decorators

# 获取装饰器
func get_decorator(tag: String):
	return decorators.get(tag, null)

# 获取所有装饰器标签
func get_all_decorator_tags() -> Array[String]:
	var tags: Array[String] = []
	for tag in decorators.keys():
		tags.append(tag)
	return tags

# 清空所有装饰器
func clear_all_decorators():
	for tag in decorators.keys():
		var decorator = decorators[tag]
		decorator.destroy()
	decorators.clear()
	GlobalUtil.log("清空所有装饰器", GlobalUtil.LogLevel.DEBUG)

# 销毁管理器
func destroy():
	clear_all_decorators()
	card_instance = null

# 便捷方法：添加固定装饰器
func add_fixed_decorator():
	return add_decorator(FixedDecorator)

# 便捷方法：移除固定装饰器
func remove_fixed_decorator() -> bool:
	return remove_decorator("fixed")

# 便捷方法：检查是否有固定装饰器
func is_fixed() -> bool:
	return has_decorator("fixed")