# ---------- vampire_manager.gd ----------
# places vampire lord's cards in slot positions
extends Node2D

# ----- VARIABLES -----
# what is in the vampire's deck ?
var lord_deck = ['SmThrall', 'LgThrall', 'MdThrall', "MdThrall", "SmThrall"]
# the vampire's slots
@export var vamp_slots_container: Node2D
var vampire_slots:  Array[Node2D] = []

# ----- CONSTANTS -----
# card move speed
const DEFAULT_CARD_MOVE_SPEED = 0.3
const DRAW_SPEED = 0.5
const STARTING_HAND_SIZE = 5
# paths
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# shuffle the vampire lord's deck
	lord_deck.shuffle()
	for child in vamp_slots_container.get_children():
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
		if not slot.card_in_slot:
			play_card_to_slot(hand[0], slot)
			
# used to fill open vampire slots
func play_card_to_slot(card, slot):
	$"../VampireHand".remove_card_from_hand(card)
	card.current_slot = slot
	slot.card_in_slot = true
	var tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", slot.global_position, DEFAULT_CARD_MOVE_SPEED)
	
# create a vampire card and put it in the open slot
func place_card(card_name: String, slot: Node2D):
	var data = CardDatabase.get_card(card_name)
	var card = preload("res://Cards/thrall.tres").instantiate()
	$"../CardManager".add_child(card)
	card.setup(data)
	card.name = "VampCard"
	card.current_slot = slot
	slot.card_in_slot = true
	# start at vamp hand position then slide on to board
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", slot.position, DEFAULT_CARD_MOVE_SPEED)
