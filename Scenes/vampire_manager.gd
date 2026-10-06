# ---------- vampire_manager.gd ----------
# places vampire lord's cards in slot positions
extends Node2D

# ----- VARIABLES -----
# what is in the vampire's deck ?
var lord_deck = ['SmThrall', 'LgThrall', 'MdThrall', "MdThrall", "SmThrall"]
# card move speed
const DEFAULT_CARD_MOVE_SPEED = 0.1
# paths
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# shuffle the vampire lord's deck
	lord_deck.shuffle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
