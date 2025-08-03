# res://scripts/player_manager.gd
extends Node

# 玩家信号
signal health_changed(current, maximum)
signal energy_changed(current, maximum)
signal player_died

# 玩家属性
var max_health: int = 100
var current_health: int = 100
var max_energy: int = 3
var current_energy: int = 3

# UI引用
@export var health_label: Label
@export var energy_label: Label

# 状态效果
var status_effects = {}

func _ready() -> void:
	# 初始化玩家状态
	update_health_display()
	update_energy_display()
	print("Player Manager initialized")

# 更新生命值显示
func update_health_display() -> void:
	if health_label:
		health_label.text = "生命值: %d/%d" % [current_health, max_health]

# 更新能量显示
func update_energy_display() -> void:
	if energy_label:
		energy_label.text = "能量: %d/%d" % [current_energy, max_energy]

# 设置最大生命值
func set_max_health(value: int) -> void:
	max_health = value
	current_health = min(current_health, max_health)
	update_health_display()
	health_changed.emit(current_health, max_health)

# 设置生命值
func set_health(value: int) -> void:
	var old_health = current_health
	current_health = clamp(value, 0, max_health)
	
	if current_health != old_health:
		update_health_display()
		health_changed.emit(current_health, max_health)
		
		if current_health <= 0:
			player_died.emit()

# 设置最大能量
func set_max_energy(value: int) -> void:
	max_energy = value
	current_energy = min(current_energy, max_energy)
	update_energy_display()
	energy_changed.emit(current_energy, max_energy)

# 设置能量
func set_energy(value: int) -> void:
	var old_energy = current_energy
	current_energy = clamp(value, 0, max_energy)
	
	if current_energy != old_energy:
		update_energy_display()
		energy_changed.emit(current_energy, max_energy)

# 受到伤害
func take_damage(amount: int) -> void:
	print("Player takes ", amount, " damage")
	set_health(current_health - amount)

# 治疗生命值
func heal(amount: int) -> void:
	print("Player heals for ", amount, " health")
	set_health(current_health + amount)

# 获得护甲
func gain_block(amount: int) -> void:
	print("Player gains ", amount, " block")
	# 在这个简单版本中，我们将护甲实现为临时生命值
	# 在更复杂的实现中，应该有单独的护甲系统
	set_health(current_health + amount)

# 消耗能量
func spend_energy(amount: int) -> bool:
	if current_energy >= amount:
		set_energy(current_energy - amount)
		return true
	else:
		print("Not enough energy")
		return false

# 恢复能量
func restore_energy(amount: int) -> void:
	set_energy(current_energy + amount)

# 回合开始
func on_turn_start() -> void:
	# 恢复能量
	set_energy(max_energy)
	
	# 处理状态效果
	process_status_effects()

# 回合结束
func on_turn_end() -> void:
	# 处理状态效果
	process_status_effects()

# 添加状态效果
func add_status_effect(effect_name: String, duration: int, intensity: int = 1) -> void:
	if status_effects.has(effect_name):
		# 如果已有该效果，则更新持续时间和强度
		status_effects[effect_name].duration = max(status_effects[effect_name].duration, duration)
		status_effects[effect_name].intensity += intensity
	else:
		# 添加新效果
		status_effects[effect_name] = {
			"duration": duration,
			"intensity": intensity
		}
	
	print("Added status effect: ", effect_name, " (Duration: ", duration, ", Intensity: ", intensity, ")")

# 处理状态效果
func process_status_effects() -> void:
	var effects_to_remove = []
	
	for effect_name in status_effects:
		var effect = status_effects[effect_name]
		
		# 应用效果
		apply_status_effect(effect_name, effect.intensity)
		
		# 减少持续时间
		effect.duration -= 1
		
		# 如果持续时间结束，标记为移除
		if effect.duration <= 0:
			effects_to_remove.append(effect_name)
	
	# 移除已结束的效果
	for effect_name in effects_to_remove:
		status_effects.erase(effect_name)
		print("Removed status effect: ", effect_name)

# 应用状态效果
func apply_status_effect(effect_name: String, intensity: int) -> void:
	# 根据效果类型应用不同的效果
	match effect_name:
		"poison":
			take_damage(intensity)
			print("Applied poison effect: ", intensity, " damage")
		"regeneration":
			heal(intensity)
			print("Applied regeneration effect: ", intensity, " healing")
		"strength":
			# 增加攻击力的效果，在更复杂的实现中处理
			print("Applied strength effect: +", intensity, " attack")
		"weakness":
			# 减少攻击力的效果，在更复杂的实现中处理
			print("Applied weakness effect: -", intensity, " attack")
		_:
			print("Unknown status effect: ", effect_name)