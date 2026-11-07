# ---------- card_slot.gd ----------
extends Node2D
# to be used by other scripts
class_name CardSlot

enum Owner { PLAYER, VAMPIRE }

# ----- VARIABLES -----
# who owns the slot ?
@export var slot_owner: Owner
# where is it ?
@export var slot_index: int
