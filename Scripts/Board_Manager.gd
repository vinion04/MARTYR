# # ---------- board_manager.gd ----------
# used to keep track of board state
extends Node2D

# ----- VARIABLES -----
# store card in slot
var card_in_slot

# function for letting the card go if player decides
# to move it from this slot (only possible pre-combat, 
# the first turn the card is placed)
func let_card_go():
	card_in_slot = false
