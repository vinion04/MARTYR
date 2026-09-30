# # ---------- player_manager.gd ----------
# used to hold player info (health, hand size, curses applied)
extends Node2D

# ----- VARIABLES -----
# hand count definition
const HAND_COUNT = 8
# card scene path
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_WIDTH = 100
const HAND_Y_POSITION = 900
# array of cards for hand
var player_hand = []
# store where center screen is
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set center screen
	center_screen_x = get_viewport_rect().size.x / 2
	# load player hand
	var card_scene = preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		var new_card = card_scene.instantiate()
		$"../CardManager".add_child(new_card)
		new_card.name = "Card"
		add_card_to_hand(new_card)
		
# function for adding a card to player_hand array
func add_card_to_hand(card):
		if card not in player_hand:
			player_hand.insert(0, card)
			update_hand_position()
		else:
			# if card in player_hand
			animate_card_to_position(card, card.starting_position)

# function for organizing cards in hand
func update_hand_position():
	# for every card in player_hand
	for i in range(player_hand.size()):
		# set new position
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position)

# function for finding card position in hand
func calculate_card_position(index):
	# calculate width of all cards total in hand
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

func animate_card_to_position(card, new_position):
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", new_position, 0.1)
