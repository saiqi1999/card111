extends Node

# 预加载场景和资源
var card_scene = preload("res://scenes/card.tscn")

# 获取根节点的引用
@onready var root_node = get_tree().get_root().get_node("Root")

# 按钮点击事件处理函数
func _on_button_pressed():
	# 打印一行文字
	print("按钮被点击了！")
	
	# 创建卡牌场景实例
	var card_instance = card_scene.instantiate()
	
	# 设置卡牌位置在屏幕中央
	card_instance.position = Vector2(960, 540)
	
	# 通过类型字符串加载卡牌
	card_instance.load_from_card_type("strike")
	
	# 将卡牌添加到根场景
	root_node.add_child(card_instance)
	
	# 打印创建成功信息
	print("创建了一张打击卡牌！")