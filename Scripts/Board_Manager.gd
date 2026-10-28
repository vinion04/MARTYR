# # ---------- board_manager.gd ----------
# used to keep track of board state and card placement in slots
extends Node

# ----- VARIABLES -----
@export var player_slots: Array[CardSlot] = []
@export var vampire_slots: Array[CardSlot] = []
# store card in slot bool
var card_in_slot
# store card slots
var board := {}
# player hand ref for card placement
var player_hand_ref

# ----- CONSTANTS -----
# card move speed
const DEFAULT_CARD_MOVE_SPEED = 0.3

func _ready() -> void:
	# set player_hand_ref
	player_hand_ref = $"../PlayerHand"

# function for letting the card go if player decides
# to move it from this slot
func let_card_go():
	card_in_slot = false

# can player play in slot check
func can_player_place(slot: CardSlot) -> bool:
	# is this slot's owner the player and is it open ?
	return slot.slot_owner == CardSlot.Owner.PLAYER and is_open(slot)

# does this slot have a card in it ?
func is_open(slot: CardSlot):
	# returns true if open
	return not board.has(slot)
	
# places a card in specified slot
func place_card(card, slot: CardSlot):
	# just now the slot is stored in board
	# stores the card in the slot
	board[slot] = card
	# card now knows what slot it holds
	card.current_slot = slot
	var tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", slot.global_position, DEFAULT_CARD_MOVE_SPEED)

# removes card from current slot
func remove_card(slot: CardSlot):
	# get card from board slot
	var card = board.get(slot)
	if card:
		# card no longer thinks its in the slot
		card.current_slot = null
	# clears the slot from the board
	board.erase(slot)
	
# used to get the card within a slot
func get_card_in(slot: CardSlot):
	return board.get(slot)
