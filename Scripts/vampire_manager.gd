# ---------- vampire_manager.gd ----------
# places vampire lord's cards in slot positions
extends Node2D

# signal for when vampire dies
signal died

# ----- VARIABLES -----
# what is in the vampire's deck ?
var vampire_deck = ['SmThrall', 'LgThrall', 'MdThrall', "MdThrall", "SmThrall", "SmThrall", "SmThrall", "MdThrall", "SmThrall", "SmThrall", "LgThrall"]
# the vampire's slots
@export var vamp_slots_container: Node2D
var vampire_slots:  Array[CardSlot] = []
# board manager
var board_manager_ref
# set max vampire hp
@export var max_hp: int = 3
var hp: int = max_hp
# did vamp draw
var drawn_card_this_turn = false

# ----- CONSTANTS -----
const DRAW_SPEED = 0.5
const STARTING_HAND_SIZE = 5
# paths
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_manager_ref = $"../BoardManager"
	vampire_deck.shuffle()
	for child in vamp_slots_container.get_children():
		if child is CardSlot:
			vampire_slots.append(child)
				
func draw_card():
	drawn_card_this_turn = true
	var data = CardDatabase.get_card(vampire_deck.pop_front())
	var card = preload(CARD_SCENE_PATH).instantiate()
	$"../CardManager".add_child(card)
	card.setup(data)
	card.name = "VampCard"
	# start at vamp hand position then slide on to board
	card.position = $"../VampireDeck".position
	$"../VampireHand".add_card_to_hand(card, DRAW_SPEED)
	# wait to play card until draw animation is done
	await get_tree().create_timer(DRAW_SPEED).timeout
	
# play the first card in hand into the first open slot
func play_turn():
	for slot in vampire_slots:
		var hand = $"../VampireHand".hand
		if hand.is_empty():
			return
		if board_manager_ref.is_open(slot):
			play_card_to_slot(hand[0], slot)
	# reset drawn card
	drawn_card_this_turn = false
			
# used to fill open vampire slots
func play_card_to_slot(card, slot):
	$"../VampireHand".remove_card_from_hand(card)
	board_manager_ref.place_card(card, slot)

# function to set vampire hp, clamping at max
func set_hp(value: int):
	hp = clampi(value, 0, max_hp)
	# if vampire health is < 0, let game know
	if hp<= 0:
		died.emit()

# decrements vampire health
func take_damage(damage):
	print("vampire health: " + str(hp))
	set_hp(hp - damage)
