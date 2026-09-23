# ---------- card_manager.gd ----------
# used to manage card placement and selecting/dragging
extends Node2D

# store collision mask for later use, default layer is 1
const COLLISION_MASK_CARD = 1
# store what card is being dragged
var card_being_dragged
# store screen size
var screen_size
# bool to store if mouse is on card
var is_hovering_on_card
# store card scales for reuse
var normalScale = Vector2(2, 2)
var largeScale = Vector2(3, 3)

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
				start_drag(card)
		# if card result was null, no card being dragged
		else: 
			finish_drag()

# store card drag abilities
func start_drag(card): 
	card_being_dragged = card
	# when dragging, set scale back to normal
	card.scale = normalScale

# store card finish drag abilities (if there is a card being dragged)
func finish_drag(): 
	if card_being_dragged:
		card_being_dragged = null

# function to connect child cards to this script through signals
func connect_card_signals(card):
	card.connect("hovered", on_hover_card)
	card.connect("hovered_off", on_hover_off)
	
# logic for when card is hovered over and signal is called
func on_hover_card(card):
	# ignore this hover if a different card is on top
	var top_card = raycast_check_for_card()
	if top_card != card:
		return
	highlight_card(card, true)
	
# logic for when a card is no longer hovered over and signal is called
func on_hover_off(card):
	# if there is a card being dragged
	if !card_being_dragged:
		# do not highlight a card being passed over
		highlight_card(card, false)
		# check if mouse hovered off card straight on to another card
		var new_card_hovered = raycast_check_for_card()
		# if there is another card, highlight it
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else: is_hovering_on_card = false;
	
# for effects applied to card on hover over
func highlight_card(card, hovered):
		if hovered:
			card.scale = largeScale
			card.z_index = 2
		else:
			card.scale = normalScale
			card.z_index = 1
	
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
		return get_card_with_highest_z_index(result)
	return null
	
# used to grab card on top of another card (cards because result returns an array)
func get_card_with_highest_z_index(cards):
	# collider with two .get_parent()s because card -> sprite -> collider
	var highest_z_card = cards[0].collider.get_parent().get_parent()
	var highest_z_index = highest_z_card.z_index
	
	# loop through cards for higher z index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent().get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
