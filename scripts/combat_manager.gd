# res://scripts/combat_manager.gd
extends Node

# --- Signals for UI Interaction ---
# Emitted when a card is played that requires target selection.
# UI should listen to this and enable target selection mode.
signal target_selection_requested(card_instance, target_count)
# Emitted when a card play attempt fails (e.g., not enough energy)
signal card_play_failed(reason)
# Emitted when a card is successfully played (moved to discard)
signal card_played_successfully(card_instance)

# --- Scene References ---
@onready var player_area = $"../player area"
@onready var monster_container = $"../mobs area/mobs container"
@onready var hand_area = $"../card area"

# --- Monster Scene References ---
# Preload the Slime scene so we can spawn it.
# Make sure the path is correct for your project!
@onready var slime_scene = preload("res://scenes/slime.tscn") # <-- Add this


# --- Game State ---
var player_energy: int = 3 # Example starting energy
# --- State for target selection ---
var is_selecting_targets: bool = false
var card_awaiting_targets: Card # Use your Card base class type if defined
var required_targets_count: int = 0
var selected_targets: Array = [] # Stores the targets selected by the player

# --- Deck Management Variables ---
# These arrays will hold Card instances (which are Nodes).
# Using 'Node' type hint as Card will likely be a scene instance (Node).
# You might refine this later with a specific Card base class if needed.

# --- Deck Management Variables ---
var draw_pile: Array = []
var discard_pile: Array = []
var hand: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Combat Manager initialized.")
	initialize_test_deck()
	# You can connect signals here if needed, or in other setup functions.
	# For example, if Main had a signal for starting combat:
	# owner.start_combat_requested.connect(_on_start_combat_requested)

# --- Monster Management ---
# --- UPDATED spawn_monster function ---
func spawn_monster(monster_scene: PackedScene) -> Node: # Return the instance
	if monster_scene:
		var monster_instance = monster_scene.instantiate()
		# Connect the monster's 'died' signal back to the CombatManager
		monster_instance.died.connect(_on_monster_died.bind(monster_instance))
		monster_container.add_child(monster_instance)
		print("Combat Manager spawned a monster: %s" % monster_instance.name)
		return monster_instance # Return the instance in case the caller needs it
	else:
		printerr("spawn_monster called with null scene.")
	return null

func _on_monster_died(monster_instance) -> void:
	# Handle monster death (already handled by monster itself emitting 'died' signal,
	# but manager might do extra things like give player rewards)
	print("CombatManager: A monster died. Checking win condition...")
	# Check if all monsters are gone etc.


# --- Dependencies ---
# Get a reference to the HandArea where card instances will be displayed.
# Adjust the path if your structure is different.
# --- Example function to spawn a Slime ---
# This is what a card effect would ultimately call.
func spawn_slime() -> void:
	# Check if the scene was loaded successfully
	if slime_scene:
		var new_slime = spawn_monster(slime_scene)
		if new_slime:
			print("A new Slime '%s' has entered the battlefield!" % new_slime.name)
		# Handle case where spawn_monster failed?
	else:
		printerr("Slime scene not loaded. Cannot spawn Slime.")

# --- Lifecycle ---
# --- Deck Initialization ---
func initialize_test_deck() -> void:
	spawn_slime()
	# Clear any existing state
	draw_pile.clear()
	discard_pile.clear()
	hand.clear()
	
	# --- IMPORTANT ---
	# You need to have your Card scenes ready (e.g., strike.tscn, defend.tscn).
	# For this example, let's assume you have a basic card scene.
	# You would typically have a list of resource paths or a data structure
	# defining your starting deck.
	
	# Example: Load card scenes and instantiate them for the deck.
	# In practice, you'd load these once (e.g., in a preload) and reuse the PackedScene.
	# Let's simulate adding some cards.
	# Note: This is pseudo-code for loading scenes. You'd have actual .tscn files.
	
	# Simulate creating card instances (Nodes). In reality, these come from instancing .tscn files.
	# For demonstration, we'll use dummy data. You'll replace this with actual card instances.
	# A more robust way is to have a data-driven approach for the deck list.
	
	var card_scenes = [
		 preload("res://scenes/strike.tscn"),
		# Add paths to your actual card scenes
	]
	
	# Example using dummy objects to represent card instances for logic demonstration
	# In Godot, these would be actual Node instances from your card scenes.
	for i in range(3): # Add 3 dummy "Strike" cards
		var card_instance = preload("res://scenes/strike.tscn").instantiate()
		draw_pile.append(card_instance)
		#draw_pile.append({"name": "Strike_%d" % (i + 1)}) # Dummy card object
				
	# Shuffle the draw pile
	draw_pile.shuffle()
	print("Initialized test deck with %d cards and shuffled." % draw_pile.size())
	# Debug print initial state
	debug_print_state()
	
	draw_card()

# --- Core Card Draw Logic ---
func draw_card() -> Node: # Return type should ideally be your Card base class or Node
	"""
	Draws a single card from the draw pile.
	Handles reshuffling the discard pile if the draw pile is empty.
	Returns the drawn card instance (Node) or null if no cards are available.
	"""
	# 1. Check if draw pile is empty
	if draw_pile.is_empty():
		# 2. If draw pile is empty, check discard pile
		if discard_pile.is_empty():
			print("No cards left to draw!")
			return null # No cards anywhere
		else:
			print("Draw pile empty. Shuffling discard pile into draw pile.")
			# 3. Reshuffle: Move all cards from discard pile to draw pile
			draw_pile = discard_pile.duplicate() # Duplicate the array contents
			discard_pile.clear() # Clear the discard pile
			# 4. Shuffle the new draw pile
			draw_pile.shuffle()

	# 5. Draw the top card (last element in PoolVector/Array simulates top of stack)
	if not draw_pile.is_empty():
		# Use 'pop_back()' to remove and get the last element (top of the pile)
		var drawn_card_instance = draw_pile.pop_back() 
		# 6. Add the drawn card instance to the player's hand array
		hand.append(drawn_card_instance) 
		# 7. (Optional but common) Add the card instance visually to the HandArea
		# Ensure the card instance is a Node before adding.
		if drawn_card_instance is Node:
			hand_area.add_child(drawn_card_instance) 
		# The visual part might be handled by a separate UI system listening to hand changes
		
		print("Drew card: %s" % str(drawn_card_instance)) # Adjust based on your Card object
		return drawn_card_instance

	return null # Should rarely happen, but safe


# --- Drawing a Hand ---
func draw_hand(num_cards: int = 5) -> void:
	"""
	Draws a specified number of cards (default 5) into the player's hand.
	"""
	print("\n--- Drawing a new hand of %d cards ---" % num_cards)
	for i in range(num_cards):
		var card = draw_card()
		if card == null:
			print("Could not draw card %d, no cards left." % (i + 1))
			break # Stop drawing if no cards are left
	print("Hand after drawing: %s" % str(hand)) # Adjust based on your Card object
	print("Cards left in Draw Pile: %d" % draw_pile.size())
	print("Cards in Discard Pile: %d" % discard_pile.size())

# --- Playing a Card (Moving to Discard) ---
func play_card(card_instance) -> bool: # Accepts the actual card Node instance
	"""
	Moves a card from the player's hand to the discard pile.
	This usually happens when the player uses the card.
	Returns true if successful, false otherwise.
	"""
	# 1. Check if the card is actually in the player's hand
	if hand.has(card_instance):
		# 2. Remove it from the hand array
		hand.erase(card_instance) 
		# 3. (Optional) Remove it from the visual HandArea
		# if card_instance.get_parent() == hand_area:
		#     hand_area.remove_child(card_instance)
		
		# 4. Add it to the discard pile array
		discard_pile.append(card_instance)
		
		# 5. (Crucial) Add the card instance to the discard visual area if you have one
		# You might have a DiscardPileArea similar to HandArea
		# var discard_area = $"../DiscardPileArea" # Example path
		# if discard_area:
		#     discard_area.add_child(card_instance)
		
		print("Played card: %s. Moved to discard pile." % str(card_instance)) # Adjust
		# Here you would typically call the card's effect function
		# e.g., card_instance.execute_effect()
		return true
	else:
		print("Error: Attempted to play a card (%s) not in hand." % str(card_instance)) # Adjust
		return false

# --- Accessor for Hand (Read-Only) ---
func get_hand() -> Array:
	"""
	Provides a copy of the current hand array.
	This prevents external code from directly modifying the internal 'hand' array
	without using the intended methods like 'play_card'.
	"""
	# Returning a duplicate ensures the internal state isn't accidentally modified.
	return hand.duplicate()

# --- Debugging ---
func debug_print_state() -> void:
	""" Helper to print the current state of all piles for debugging. """
	print("\n--- Deck State ---")
	print("Draw Pile (%d): %s" % [draw_pile.size(), str(draw_pile)]) # Adjust str() for Node names
	print("Hand (%d): %s" % [hand.size(), str(hand)])
	print("Discard Pile (%d): %s" % [discard_pile.size(), str(discard_pile)])
	print("------------------")


# --- NEW: Main Entry Point for Playing a Card ---
func attempt_play_card(card_instance) -> bool:
	"""
	This is the function called when a player clicks a card in their hand.
	It handles the initial checks and target selection request.
	Returns true if the process started (including target selection), false on immediate failure.
	"""
	if not card_instance is Card: # Assuming 'Card' is your base class
		printerr("Error: attempt_play_card called with non-Card instance.")
		return false
		
	if not hand.has(card_instance):
		printerr("Error: Attempted to play a card not in hand.")
		emit_signal("card_play_failed", "Card not in hand")
		return false

	if card_instance.cost > player_energy:
		print("Not enough energy to play %s." % card_instance.card_name)
		emit_signal("card_play_failed", "Not enough energy")
		return false # Fail immediately

	var target_count = card_instance.get_target_count()
	print("Attempting to play %s. Cost: %d, Targets needed: %d" % [card_instance.card_name, card_instance.cost, target_count])

	if target_count > 0:
		# --- Enter Target Selection Mode ---
		is_selecting_targets = true
		card_awaiting_targets = card_instance
		required_targets_count = target_count
		selected_targets.clear()
		print("Entering target selection mode for %s." % card_instance.card_name)
		# --- Notify UI ---
		emit_signal("target_selection_requested", card_instance, target_count)
		# The UI is now responsible for allowing the player to select targets
		# and calling select_target() accordingly.
		return true # Process started, waiting for targets
	else:
		# --- No targets needed, play immediately ---
		return execute_play_card(card_instance, [])

# --- NEW: Function to Handle Target Selection by Player ---
func select_target(target_node) -> bool:
	"""
	Called by the UI when the player selects a target during the target selection phase.
	Returns true if the target was accepted, false otherwise.
	"""
	if not is_selecting_targets:
		print("Warning: select_target called, but not currently selecting targets.")
		return false

	if selected_targets.size() >= required_targets_count:
		print("Warning: Already selected the required number of targets (%d)." % required_targets_count)
		return false

	# --- Basic validation could go here ---
	# e.g., check if target_node is a valid type (Monster, Player)
	# For now, we assume the UI only allows valid selections.
	
	selected_targets.append(target_node)
	print("Target selected: %s (%d/%d)" % [target_node.name, selected_targets.size(), required_targets_count])

	# --- Check if all targets are selected ---
	if selected_targets.size() == required_targets_count:
		print("All targets selected for %s." % card_awaiting_targets.card_name)
		# --- Play the card with the selected targets ---
		var success = execute_play_card(card_awaiting_targets, selected_targets)
		# --- Reset target selection state ---
		_reset_target_selection_state()
		return success
		
	return true # Target accepted, waiting for more

# --- NEW: Function to Cancel Target Selection ---
func cancel_target_selection() -> void:
	"""
	Called by the UI if the player cancels target selection (e.g., right-clicks).
	"""
	if is_selecting_targets:
		print("Target selection cancelled for %s." % card_awaiting_targets.card_name)
		_reset_target_selection_state()
		# UI might need a signal to update its state too
		# emit_signal("target_selection_cancelled") # Optional signal

func _reset_target_selection_state() -> void:
	""" Helper to reset the target selection related variables. """
	is_selecting_targets = false
	card_awaiting_targets = null
	required_targets_count = 0
	selected_targets.clear()

# --- UPDATED: The Core Execution Logic ---
func execute_play_card(card_instance, targets: Array) -> bool:
	"""
	This function performs the actual cost payment, effect resolution, and discarding.
	This is the final step of playing a card.
	"""
	if not card_instance is Card:
		printerr("Error: execute_play_card called with non-Card instance.")
		return false

	# --- 1. Final check (should ideally be redundant if called correctly) ---
	if card_instance.cost > player_energy:
		printerr("Error: execute_play_card called but player lacks energy. Logic error?")
		emit_signal("card_play_failed", "Logic error: Insufficient energy at execution")
		return false

	# --- 2. Pay the cost ---
	player_energy -= card_instance.cost
	print("Paid %d energy for %s. Remaining energy: %d" % [card_instance.cost, card_instance.card_name, player_energy])

	# --- 3. Resolve the card's effect ---
	# This calls the specific card's play() method
	card_instance.play(targets)

	# --- 4. Move card to discard pile ---
	if hand.has(card_instance):
		hand.erase(card_instance)
		discard_pile.append(card_instance)
		print("Card %s moved to discard pile." % card_instance.card_name)
		emit_signal("card_played_successfully", card_instance)
		return true
	else:
		printerr("Error: execute_play_card could not find card in hand to discard.")
		return false

# --- Example Usage (Conceptual) ---
# These would be called by UI signals or other game logic
#
# func _on_ui_card_clicked(card_instance):
#     attempt_play_card(card_instance)
#
# func _on_ui_enemy_clicked(enemy_instance):
#     if is_selecting_targets:
#         select_target(enemy_instance)
#
# func _on_ui_right_click(): # Example cancel
#     cancel_target_selection()
# --- Example Usage ---
# This part would typically be called by other game logic (e.g., start of turn, UI button)
# func _on_turn_start():
#     draw_hand(5)
#
# func _on_card_played_ui_signal(card_instance): # Connected from UI/Card signal
#     if play_card(card_instance):
#         # Card played successfully, maybe trigger combat effects
#         pass
