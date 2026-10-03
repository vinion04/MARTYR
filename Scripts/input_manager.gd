extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

# ----- VARIABLES -----
# collision mask constants
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4
# references
var card_manager_ref
var deck_ref

func _ready() -> void:
	# set references
	card_manager_ref = $"../CardManager"
	deck_ref = $"../Deck"

# handle mouse click
func _input(event):
	# if left mouse button clicked
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# emit signal to communicate left mouse button clicked
			emit_signal("left_mouse_button_clicked")
			# find what is at cursor
			raycast_at_cursor()
		else: 
			# emit signal to communicate left mouse button clicked
			emit_signal("left_mouse_button_released")
			
func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	# set params to check for card or deck
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD | COLLISION_MASK_DECK
	var result = space_state.intersect_point(parameters)
	# if there was a result, get the Card node
	if result.size() > 0:	
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			# card clicked (collider -> sprite -> card)
			var card_found = result[0].collider.get_parent().get_parent()
			if card_found:
				card_manager_ref.start_drag(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK:
			# deck clicked
			deck_ref.draw_card()
