# ---------- vampire_manager.gd ----------
# places vampire lord's cards in slot positions
extends Node2D

# signal for when vampire dies
signal died

# ----- VARIABLES -----
# chance weights for each thrall to be drawn
var thrall_weights := {"SmThrall": 50, "MdThrall": 30, "LgThrall": 20}
# board manager
@onready var board_manager_ref = $"../BoardManager"
# player hud reference
@onready var player_hud_ref = $"../HUDLayer/PlayerHUD"
# set max vampire hp
@export var max_hp: int = 3
var hp: int = max_hp

# ----- CONSTANTS -----
const DRAW_SPEED = 0.5
const STARTING_HAND_SIZE = 5
# paths
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# picks a thrall at random (using the weights)
# CLAUDE BUILT THIS FUNCTION
func pick_thrall():
	var total = 0
	for w in thrall_weights.values():
		total += w
	var roll = randi_range(1, total)
	for id in thrall_weights:
		roll -= thrall_weights[id]
		if roll <= 0:
			return id
	return thrall_weights.keys()[0]
				
func draw_card():
	var data = CardDatabase.get_card(pick_thrall())
	var card = preload(CARD_SCENE_PATH).instantiate()
	$"../CardManager".add_child(card)
	card.setup(data)
	card.name = "VampCard"
	# start at vamp hand position then slide on to board
	card.position = $"../VampireDeck".position
	$"../VampireHand".add_card_to_hand(card, DRAW_SPEED)
	# wait to play card until draw animation is done
	await get_tree().create_timer(DRAW_SPEED, false).timeout
	
# on game save, load hand
func load_hand(rows: Array):
	var card_scene = preload(CARD_SCENE_PATH)
	for row in rows:
		var data = CardDatabase.get_card(row.card_id)
		var card = card_scene.instantiate()
		$"../CardManager".add_child(card)
		card.setup(data)
		$"../VampireHand".add_card_to_hand(card, 0.0)
	
	
# play the first card in hand into the first open slot
func play_turn():
	for slot in $"../BoardManager".vampire_slots:
		var hand = $"../VampireHand".hand
		if hand.is_empty():
			return
		if board_manager_ref.is_open(slot):
			play_card_to_slot(hand[0], slot)
			
# used to fill open vampire slots
func play_card_to_slot(card, slot):
	$"../VampireHand".remove_card_from_hand(card)
	board_manager_ref.place_card(card, slot)

# function to set vampire hp, clamping at max
func set_hp(value: int):
	hp = clampi(value, 0, max_hp)
	player_hud_ref.update_vampire_display_health(hp)
	# if vampire health is < 0, let game know
	if hp<= 0:
		died.emit()

# decrements vampire health
func take_damage(damage):
	print("vampire health: " + str(hp))
	set_hp(hp - damage)
