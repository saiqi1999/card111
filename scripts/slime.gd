# res://scripts/slime.gd
extends "res://scripts/mobs.gd" # 继承 Monster 基类

# 史莱姆特有导出变量
@export var is_jiggly: bool = true

# --- 新增：存储对 CombatManager 的引用 ---
var combat_manager_instance: Node # 使用 Node 类型，或者如果你有 CombatManager 的具体类名，可以使用那个

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 设置史莱姆的初始属性 (可以覆盖基类的默认值)
	monster_name = "Slime"
	max_health = 8
	attack = 3
	defense = 0
	current_health = max_health # 确保初始化当前血量
	
	# --- 新增：在 _ready 中获取 CombatManager 的引用 ---
	# 假设场景结构是 Main -> CombatManager, Main -> EnemyArea -> MonsterContainer -> Slime
	# "../../CombatManager" 表示：从父节点(Slime的父节点是MonsterContainer)的父节点(MonsterContainer的父节点是EnemyArea)的父节点(EnemyArea的父节点是Main)下找到 CombatManager
	# 请根据你实际的场景结构调整这个路径！
	# 使用 weakref 或 is_instance_valid 检查是个好习惯，以防节点意外被删除。
	combat_manager_instance = get_node("../../CombatManager")
	if not combat_manager_instance:
		# 或者使用 push_warning, push_error
		print("Warning: Could not find CombatManager node at '../../CombatManager'")
	# ---------------------------------------------------------

# 重写受伤方法，添加史莱姆特有效果
func take_damage(damage: int, source=null) -> void:
	# 可以在这里添加史莱姆特有的受伤效果，比如屏幕抖动、特殊音效等
	if is_jiggly:
		print("The Slime jiggles angrily!")
	# 调用基类的受伤逻辑
	super.take_damage(damage)


# 重写死亡方法，添加史莱姆特有效果
func die() -> void:
	print("Slime lets out a final, pathetic splat.")
	
	# --- 新增：调用 CombatManager 的接口 ---
	# 确保引用有效再调用
	if combat_manager_instance:
		# 调用 CombatManager 的 draw_card 方法
		# 注意：draw_card 返回的是抽到的卡牌实例，如果需要可以接收它
		var drawn_card = combat_manager_instance.draw_card() 
		print("Slime's death granted a card: %s" % str(drawn_card if drawn_card else "None"))
		
		# 如果 CombatManager 有其他接口，比如 draw_cards(amount)，也可以调用
		# combat_manager_instance.draw_cards(2) # 例如，抽两张牌
		
		# 或者调用一个更通用的奖励方法
		# combat_manager_instance.give_reward("slime_defeated") 
	else:
		print("Slime could not call CombatManager: Reference is invalid.")
	# -------------------------------------------
	
	# 可以在这里添加史莱姆特有的死亡效果，比如播放分裂动画、生成金币等
	# ...
	
	# 最后调用基类的死亡逻辑
	super.die()


# 实现具体的行动逻辑 (例子)
#func perform_action() -> void:
	#print("%s attacks for %d damage!" % [get_monster_name(), attack])
	# 这里应该包含实际的游戏逻辑，比如对玩家造成伤害
	# 通常会通过信号与战斗管理器通信
