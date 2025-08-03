# res://scripts/card.gd
class_name Card # Ensure class_name is at the top
extends Node2D

# --- Signals ---
signal card_played(card_instance, targets)
signal target_selection_needed(card_instance, target_count)
signal card_hovered(card_instance)
# --- NEW SIGNAL: Emitted when the card itself is clicked ---
signal card_clicked(card_instance) # <-- Add this signal

# --- Exported Variables ---
@export var card_name: String = "New Card"
@export var cost: int = 0
@export_multiline var description: String = "A card description."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("card ready %s" % card_name)
	pass

# --- New Method: Get Target Count ---
func get_target_count() -> int:
	return 0

# --- Method to initiate target selection (optional helper) ---
func request_target_selection() -> void:
	var count = get_target_count()
	if count > 0:
		emit_signal("target_selection_needed", self, count)

# --- Updated 'play' method signature ---
func play(targets: Array = []) -> void:
	print("Playing base card: %s (Cost: %d)" % [card_name, cost])
	if not targets.is_empty():
		print("  Targets: ", targets)
	emit_signal("card_played", self, targets)

# --- NEW FUNCTION: Handles input events on this card ---
# This function is called when an input event happens over this node's collision area.
func _input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Check if the event is a mouse button press (left click)
	# For touch, you might check for InputEventScreenTouch with pressed=true
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("%s card was clicked." % card_name)
		# Emit the custom signal to notify listeners (like CombatManager)
		emit_signal("card_clicked", self)

	# You can handle other events like hover (MouseMotion) here too if needed
	# Check Godot 4 docs for InputEventMouseMotion


func _on_card_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("%s card was clicked." % card_name)
	_input_event(viewport, event, shape_idx)
