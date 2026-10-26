# ---------- card_slot.gd ----------
extends Node2D
# to be found by board_manager
class_name CardSlot

enum Owner { PLAYER, VAMPIRE }

# ----- VARIABLES -----
# who owns the slot ?
@export var slot_owner: Owner
# where is it ?
@export var lane_index: int
