# ---------- vampire_manager.gd ----------
# places vampire lord's cards in slot positions
extends Node2D

# ----- VARIABLES -----
# what is in the vampire's deck ?
var lord_deck = ['SmThrall', 'LgThrall', 'MdThrall', "MdThrall", "SmThrall"]
# the vampire's slots
@export var vamp_slots_container: Node2D
var vampire_slots:  Array[CardSlot] = []
# board manager
var board_manager_ref

# ----- CONSTANTS -----
# card move speed
const DEFAULT_CARD_MOVE_SPEED = 0.3
const DRAW_SPEED = 0.5
const STARTING_HAND_SIZE = 5
# paths
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_manager_ref = $"../BoardManager"
	lord_deck.shuffle()
	for child in vamp_slots_container.get_children():
		if child is CardSlot:
			vampire_slots.append(child)
			
	
func draw_card():
	var data = CardDatabase.get_card(lord_deck.pop_front())
	var card = preload(CARD_SCENE_PATH).instantiate()
	$"../CardManager".add_child(card)
	card.setup(data)
	card.name = "VampCard"
	# start at vamp hand position then slide on to board
	card.position = $"../VampireDeck".position
	$"../VampireHand".add_card_to_hand(card, DRAW_SPEED)
	
# play the first card in hand into the first open slot
func play_turn():
	for slot in vampire_slots:
		var hand = $"../VampireHand".hand
		if hand.is_empty():
			return
		if board_manager_ref.is_open(slot):
			play_card_to_slot(hand[0], slot)
			
# used to fill open vampire slots
func play_card_to_slot(card, slot):
	$"../VampireHand".remove_card_from_hand(card)
	board_manager_ref.place_card(card, slot)
	var tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", slot.global_position, DEFAULT_CARD_MOVE_SPEED)
