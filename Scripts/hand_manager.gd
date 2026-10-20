# ---------- player_hand_manager.gd ----------
# keeps hand's cards arranged
extends Node2D

# ----- VARIABLES -----
@export var hand_y_position = 950
# array of cards for hand
var hand = []
# store where center screen is
var center_screen_x

# ----- CONSTANTS -----
# card scene path
const CARD_WIDTH = 100
# card move speed
const DEFAULT_CARD_MOVE_SPEED = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set center screen
	center_screen_x = get_viewport_rect().size.x / 2
		
# function for adding a card to hand array
func add_card_to_hand(card, speed):
	print(card.get_class(), " | ", card.get_script(), " | ", card.scene_file_path)
	if card not in hand:
		hand.insert(0, card)
		update_hand_position(speed)
	else:
		# if card in hand
		animate_card_to_position(card, card.starting_position, speed)

# function for organizing cards in hand
func update_hand_position(speed):
	# for every card in hand
	for i in range(hand.size()):
		# set new position
		var new_position = Vector2(calculate_card_position(i), hand_y_position)
		var card = hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)

# function for finding card position in hand
func calculate_card_position(index):
	# calculate width of all cards total in hand
	var total_width = (hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

# function using tween to animate card to new_position over a range of time
func animate_card_to_position(card, new_position, speed):
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", new_position, speed)

# function to remove card from hand
func remove_card_from_hand(card):
		if card in hand:
			# takes card out of array
			hand.erase(card)
			# updates the hand so it organizes nicely
			update_hand_position(DEFAULT_CARD_MOVE_SPEED)
