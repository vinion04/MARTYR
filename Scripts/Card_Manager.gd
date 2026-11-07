# ---------- card_manager.gd ----------
# used to handle hovering/dragging mechanics
extends Node2D

# ----- VARIABLES -----
# store what card is being dragged
var card_being_dragged
# store screen size
var screen_size
# keep track of what card is hovered over
var hovered_card
# store card scales for reuse
var normalScale = Vector2(4, 4)
var largeScale = Vector2(5, 5)
# player hand
@onready var player_hand_ref = $"../PlayerHand"
var played_vamp_card_this_turn = false
@onready var board_manager_ref = $"../BoardManager"
@onready var game_manager_ref = $".."

# ----- CONSTANTS -----
# store collision masks for later use, default layer is 1
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
# default speedd
const DEFAULT_CARD_MOVE_SPEED = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# if there is a card being dragged, set the card pos to mouse pos
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		# clamps within screen size
		card_being_dragged.global_position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))
		clear_hover()
		return
	update_hover()
	
# update the hover function
func update_hover():
	# check what card is on top
	var top_card = raycast_check_for_card()
	if top_card == hovered_card:
		return
	# unhighlight the old card (if it exists)
	if is_instance_valid(hovered_card):
		highlight_card(hovered_card, false)
	hovered_card = top_card
	if hovered_card:
		highlight_card(hovered_card, true)

# stop hovering
func clear_hover():
	if is_instance_valid(hovered_card):
		highlight_card(hovered_card, false)
	hovered_card = null

func on_left_click_released():
	if card_being_dragged:
		finish_drag()
	
# store card drag abilities
func start_drag(card):
	# if not player turn, don't touch cards at all
	if game_manager_ref.state != game_manager_ref.State.PLAYER_TURN:
		return 
	# no touch if vampire card
	if card.data.card_owner == CardData.CardOwner.VAMPIRE:
		return
	# if this isn't the card's first time being placed, can't go back into hand
	if card.has_fought:
		return
	# free the slot this card is in
	if card.current_slot:
		board_manager_ref.remove_card(card.current_slot)
	card_being_dragged = card
	card.scale = normalScale

# store card finish drag abilities (if there is a card being dragged)
func finish_drag(): 
	if card_being_dragged:
		# check if there is a card slot to be dropped into
		var card_slot_found = raycast_check_for_slot()
		if card_slot_found and board_manager_ref.can_player_place(card_slot_found):
			# card removed from player hand
			player_hand_ref.remove_card_from_hand(card_being_dragged)
			board_manager_ref.place_card(card_being_dragged, card_slot_found)
			card_being_dragged.global_position = card_slot_found.global_position
		else:
			# if there is no card slot to be dropped in to, return to hand
			player_hand_ref.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
		card_being_dragged = null
	
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
	
# check if there is a slot for the card to be dropped in to
func raycast_check_for_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	# set params to check for card
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	# if there was a result, get the Card node
	if result.size() > 0:	
		return result[0].collider.get_parent()
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
