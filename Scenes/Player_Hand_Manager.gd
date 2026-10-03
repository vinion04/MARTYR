# ---------- player_hand_manager.gd ----------
# keeps hand's cards arranged
extends Node2D

# ----- VARIABLES -----
# card scene path
const CARD_WIDTH = 100
const HAND_Y_POSITION = 900
# card move speed
const DEFAULT_CARD_MOVE_SPEED = 0.1
# array of cards for hand
var player_hand = []
# store where center screen is
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set center screen
	center_screen_x = get_viewport_rect().size.x / 2
		
# function for adding a card to player_hand array
func add_card_to_hand(card, speed):
	print(card.get_class(), " | ", card.get_script(), " | ", card.scene_file_path)
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_position(speed)
	else:
		# if card in player_hand
		animate_card_to_position(card, card.starting_position, speed)

# function for organizing cards in hand
func update_hand_position(speed):
	# for every card in player_hand
	for i in range(player_hand.size()):
		# set new position
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)

# function for finding card position in hand
func calculate_card_position(index):
	# calculate width of all cards total in hand
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

# function using tween to animate card to new_position over a range of time
func animate_card_to_position(card, new_position, speed):
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", new_position, speed)

# function to remove card from hand
func remove_card_from_hand(card):
		if card in player_hand:
			# takes card out of array
			player_hand.erase(card)
			# updates the hand so it organizes nicely
			update_hand_position(DEFAULT_CARD_MOVE_SPEED)
