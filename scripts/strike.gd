# res://scripts/strike.gd
extends "res://scripts/card.gd"

@export var damage: int = 6

func _ready() -> void:
	card_name = "Strike"
	cost = 1
	description = "Deal %d damage to one enemy." % damage # Updated description

# --- Implement the targeting logic for Strike ---
func get_target_count() -> int:
	"""
	Strike requires exactly 1 target (an enemy).
	"""
	return 1 # Strike needs one target

# --- Keep the 'play' method for the effect ---
func play(targets: Array = []) -> void:
	super.play(targets) 
	
	if targets.size() != 1:
		# This check is important for validation.
		# The UI/CombatManager should ideally ensure the correct number.
		print("  Error: Strike requires exactly 1 target, got %d." % targets.size())
		# Depending on your game rules, you might return, ignore extra targets, or apply to a default target.
		# For strictness, let's return early.
		return 
	
	var target = targets[0] # Get the single target
	print("  Strike is resolving its effect on %s..." % target.name if target.name else str(target))
	
	if target.has_method("take_damage"):
		target.take_damage(damage, self)
		print("    Dealt %d damage to %s." % [damage, target.name if target.name else str(target)])
	else:
		print("    Warning: Target %s does not have a 'take_damage' method." % (target.name if target.name else str(target)))


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("strike click")
