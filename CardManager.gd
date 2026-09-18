# ---------- CARD MANAGER ----------
# used to manage card placement
extends Node2D

# store collision mask for later use, default layer is 1
const COLLISION_MASK_CARD = 1
# store what card is being dragged
var card_being_dragged
# store screen size
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# if there is a card being dragged, set the card pos to mouse pos
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		# clamps within screen size
		card_being_dragged.global_position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))
	
# handle mouse click on card
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# check if there was a card result where mouse clicked
			var card = raycast_check_for_card()
			if card:
				# card result is now being dragged
				card_being_dragged = card
		# if card result was null, no card being dragged
		else: card_being_dragged = null
			
# check if there is a card under the mouse position
# -- mostly taken from godot engine documentation --
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	# set params to check for card
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	# if there was a result, get the Card node
	if result.size() > 0:	
		return result[0].collider.get_parent()
	return null
