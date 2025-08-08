# res://scripts/cards/strike.gd
extends "res://scripts/card.gd"

# 打击卡牌 - 造成基础伤害

var damage: int = 6  # 基础伤害值

func _ready() -> void:
	# 设置卡牌基本属性
	card_name = "打击"
	cost = 1
	description = "造成 %d 点伤害" % damage
	
	# 加载卡牌图片
	var image_path = "res://assets/images/strike.png"
	card_image = load(image_path)
	if card_image:
		print("打击卡牌图片已加载: %s" % image_path)
		print("打击卡牌图片原始尺寸: 宽度 %d, 高度 %d" % [card_image.get_width(), card_image.get_height()])
	else:
		print("无法加载打击卡牌图片: %s" % image_path)
	
	# 调用父类的_ready方法初始化UI
	super._ready()

func _apply_card_effect() -> void:
	# 获取游戏管理器和战斗管理器
	var main = get_tree().get_root().get_node("Main")
	if main:
		var combat_manager = main.get_node("CombatManager")
		if combat_manager:
			# 对敌人造成伤害
			# 在实际游戏中，这里应该获取当前选中的敌人
			# 简化版本中，我们假设直接对玩家造成伤害（用于测试）
			combat_manager.take_damage(damage)
			print("Strike card dealt %d damage!" % damage)
		else:
			print("Error: CombatManager not found")
	else:
		print("Error: Main scene not found")