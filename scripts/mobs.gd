# res://scripts/mobs.gd (or monster.gd)
extends Node2D # Or Sprite2D etc.

# --- Signals ---
signal health_changed(new_health, max_health)
signal died(monster_instance)
# --- NEW SIGNAL: Emitted when the monster itself is clicked ---
signal monster_clicked(monster_instance) # <-- Add this signal

# --- Exported Variables ---
@export var monster_name: String = "Generic Monster"
@export var max_health: int = 10
@export var attack: int = 2
@export var defense: int = 0

# --- Internal Variables ---
var current_health: int

# --- Lifecycle ---
func _ready() -> void:
	current_health = max_health

# --- Core Logic ---
func take_damage(damage: int, source = null) -> void: # Accept source, useful for effects
	var actual_damage = max(0, damage - defense)
	current_health = max(0, current_health - actual_damage)
	emit_signal("health_changed", current_health, max_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("%s has died!" % monster_name)
	emit_signal("died", self) # Pass self as the instance
	# queue_free() might be called here or by the CombatManager

# --- NEW FUNCTION: Handles input events on this monster ---
func _input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Check if the event is a mouse button press (left click)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("%s monster was clicked." % monster_name)
		# Emit the custom signal to notify listeners (like CombatManager)
		emit_signal("monster_clicked", self)
