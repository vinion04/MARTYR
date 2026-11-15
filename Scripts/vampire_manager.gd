# ---------- vampire_manager.gd ----------
# places vampire lord's cards in slot positions
extends Node2D

# signal for when vampire dies
signal died

# ----- VARIABLES -----
# chance weights for each thrall to be drawn
var thrall_weights := {"SmThrall": 40, "MdThrall": 30, "LgThrall": 30}
# board manager
@onready var board_manager_ref = $"../BoardManager"
# player hud reference
@onready var player_hud_ref = $"../HUDLayer/PlayerHUD"
# set max vampire hp
@export var max_hp: int = 3
var hp: int = max_hp

# ----- CONSTANTS -----
const DRAW_SPEED = 0.5
# paths
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# picks a thrall at random (using the weights)
func pick_thrall():
	var total = 0
	# adds all the weighted values into total
	for w in thrall_weights.values():
		total += w
	# picks an number between 1 and total
	var roll = randi_range(1, total)
	# for all 3 thrall categories, (if roll = 95)
	for id in thrall_weights:
		# SmThrall: 95 - 40 = 55
		# MdThrall: 55 - 30 = 25
		# LgThrall: 25 - 30 = -5, LgThrall wins 
		roll -= thrall_weights[id]
		if roll <= 0:
			return id
	return thrall_weights.keys()[0]		# should never hit this

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
		
# used on setup to place a card into every slot, not just one
func setup():
	var hand = $"../VampireHand".hand
	var vampire_slots = board_manager_ref.vampire_slots
	for lane in vampire_slots.size():
		play_card_to_slot(hand[0], vampire_slots[lane])
	
	
# play the first card in hand into the first open slot
# OR highest damaging player card
func play_turn():
	# store hand and board slots
	var hand = $"../VampireHand".hand
	var player_slots = board_manager_ref.player_slots
	var vampire_slots = board_manager_ref.vampire_slots
	# find the open vampire lane facing the player's heaviest attacker
	var best_lane := -1
	var best_threat := -1
	for lane in player_slots.size():
		# if the vampire slot is filled, skip lane
		if not board_manager_ref.is_open(vampire_slots[lane]):
			continue
		# get the player card and store how much attack damage it has
		var p_card = board_manager_ref.get_card_in(player_slots[lane])
		var threat = p_card.data.attack if p_card else -1
		# first open lane is the fallback, then a higher threat replaces it
		if best_lane == -1 or threat > best_threat:
			best_lane = lane
			best_threat = threat
	# no open lanes
	if best_lane == -1:
		return
	# send a thrall to protect that lane
	play_card_to_slot(hand[0], vampire_slots[best_lane])
			
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
