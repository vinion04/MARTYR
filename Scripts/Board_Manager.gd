# # ---------- board_manager.gd ----------
# used to keep track of board state (BUILD WHEN STARTING COMBAT TO KEEP TRACK OF LANES AND STUFF)
extends Node

# ----- VARIABLES -----
# store card in slot
var card_in_slot
# store card slots
var board := {}
# player hand ref for card placement
var player_hand_ref

# ----- CONSTANTS -----

func _ready() -> void:
	# set player_hand_ref
	player_hand_ref = $"../PlayerHand"

# function for letting the card go if player decides
# to move it from this slot (only possible pre-combat, 
# the first turn the card is placed)
func let_card_go():
	card_in_slot = false

# can player play in slot check
func can_player_place(slot: CardSlot) -> bool:
	return slot.slot_owner == CardSlot.Owner.PLAYER and is_open(slot)

# does this slot have a card in it ?
func is_open(slot: CardSlot):
	return not board.has(slot)
	
# places a card in specified slot
func place_card(card, slot: CardSlot):
	board[slot] = card
	card.current_slot = slot
	
# removes card from current slot
func remove_card(slot: CardSlot):
	var card = board.get(slot)
	if card:
		card.current_slot = null
	board.erase(slot)
