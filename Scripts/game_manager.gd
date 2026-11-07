# ---------- game_manager.gd ----------
# contains state machine
extends Node2D
class_name GameManager

# ----- CONSTANTS -----
const STARTING_HAND_SIZE = 5
# to reload card
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

# ----- VARIABLES -----
enum State { SETUP, DRAW, PLAYER_TURN, COMBAT, VAMPIRE_TURN, GAME_OVER, GAME_WIN, PAUSE}
var state: State = State.SETUP
# player health reference
var player_manager_ref
# vampire health reference
var vampire_manager_ref
# to store game state before pause to restore it
var state_before: State
# store the save button to disable/enable
@onready var save_button: Button = $HUDLayer/PausePanel/SaveGameButton
# win/lose panels
@onready var lose_panel: Control = $HUDLayer/LosePanel
@onready var win_panel: Control = $HUDLayer/WinPanel
@onready var pause_panel: Control = $HUDLayer/PausePanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect deck drawn signal
	$PlayerDeck.connect("player_draw", on_player_card_drawn)
	# set player health reference and connect to signal
	player_manager_ref = $PlayerManager
	player_manager_ref.died.connect(on_player_died)
	# set vampire health reference and connect to signal
	vampire_manager_ref = $VampireManager
	vampire_manager_ref.died.connect(on_vampire_died)
	# hide panels
	lose_panel.hide()
	win_panel.hide()
	pause_panel.hide()
	# start setup or load saved game (applying the snapshot grabbed)
	if SaveManager.pending_snapshot.is_empty():
		change_state(State.SETUP)
	else:
		apply_snapshot(SaveManager.pending_snapshot)
		SaveManager.pending_snapshot = {}
	
# func to handle state changes
func change_state(new_state: State):
	state = new_state
	print("STATE: ", State.keys()[new_state])
	match new_state:
		State.SETUP:
			await enter_setup()
		State.DRAW:
			await enter_draw()
		State.PLAYER_TURN:
			pass
		State.COMBAT:
			await enter_combat()
		State.VAMPIRE_TURN:
			await enter_vampire_turn()
		State.GAME_OVER:
			await show_game_over()
		State.GAME_WIN:
			await show_game_win()
		State.PAUSE:
			await enter_pause()

# func to start the set up for the game
func enter_setup():
	# player can't draw a card on first turn
	$PlayerDeck.drawn_card_this_turn = true
	# vampire lays hand first
	for i in STARTING_HAND_SIZE:
		$VampireManager.draw_card()
		# gives buffer time inbetween actions
		await get_tree().create_timer(0.5, false).timeout
	# then the player draws their opening hand
	for i in STARTING_HAND_SIZE:
		$PlayerDeck.draw_card(true)
		await get_tree().create_timer(0.5, false).timeout
	# vampire places cards
	$VampireManager.play_turn()
	# save the state before turning to first player turn so player can't draw right away
	state_before = state
	# next state would be player turn
	change_state(State.PLAYER_TURN)

# func for player to draw a card before turn
func enter_draw():
	# now player can draw, must draw before playing cards
	$PlayerDeck.drawn_card_this_turn = false

# after signal is received for card drawn, move to player turn
func on_player_card_drawn():
	if state == State.DRAW:
		change_state(State.PLAYER_TURN)
	
# func for when button clicked, enter combat phase
func enter_combat():
	# every card on the board now fights, so lock it in place
	for card in $BoardManager.get_player_cards():
		card.has_fought = true
	# combat manager resolves all lanes
	await $CombatManager.resolve_all_lanes()
	change_state(State.VAMPIRE_TURN)
	
# func to start vampire turn after combat
func enter_vampire_turn():
	# vampire draws, then plays cards
	await $VampireManager.draw_card()
	$VampireManager.play_turn()
	# small gap between next state
	await get_tree().create_timer(0.5, false).timeout
	# after vampire turn, player draws
	change_state(State.DRAW)

# func to continue to combat after player's turn (called by end turn button)
func on_end_turn():
	# if it's the player's turn and they want to continue to combat
	if state == State.PLAYER_TURN:
		# continue to combat
		change_state(State.COMBAT)
	
# handle player death and game over
func on_player_died():
	if state == State.GAME_WIN or state == State.GAME_OVER:
		return 			# this prevents the game from ending multiple times if combat continues in the background
	change_state(State.GAME_OVER)
	
# handle vampire death and game win
func on_vampire_died():
	if state == State.GAME_WIN or state == State.GAME_WIN:
		return 			# this prevents the game from ending multiple times incase combat continues in the background
	change_state(State.GAME_WIN)
	
# presents game over screen (player died)
func show_game_over():
	# show panel
	lose_panel.show()
	get_tree().paused = true
	
# presents game win screen (vampire died)
func show_game_win():
	# show panel
	win_panel.show()
	get_tree().paused = true
	
# handle pause
func enter_pause():
	get_tree().paused = true
	pause_panel.show()

# exit pause
func exit_pause():
	print("unpaused!")
	get_tree().paused = false
	pause_panel.hide()
	# dont just change state because then setup can repeat
	state = state_before
	
# this retrieves a snapshot of current game state to be used to save game state
func build_snapshot():
	print("build_snapshot called")
	# create card array for snapshot and add cards for player
	var cards: Array = []
	var i = 0
	for c in $PlayerDeck.player_deck:
		var card_data = CardDatabase.get_card(c)
		cards.append({"owner": "player", "zone": "deck", "position": i, "slot_index": -1,
			"card_id": card_data.card_id, "current_health": card_data.health, "has_fought": 0})
		i += 1
	i = 0
	for c in $PlayerHand.hand:
		cards.append({"owner": "player", "zone": "hand", "position": i, "slot_index": -1,
			"card_id": c.data.card_id, "current_health": c.data.health, "has_fought": 0 })
		i += 1
	# get all cards from slots on board
	for slot_data in $BoardManager.get_all_cards_in_slots():
		var card_node = slot_data["card"]
		var slot_node = slot_data["slot"]
		cards.append({"owner": slot_data["owner"], "zone": "slot", "position": 0, "slot_index": card_node.current_slot.slot_index,
			"card_id": card_node.data.card_id, "current_health": card_node.current_health, "has_fought": int(card_node.has_fought)})
	i = 0
	for c in $VampireHand.hand:
		cards.append({"owner": "vampire", "zone": "hand", "position": i, "slot_index": -1,
			"card_id": c.data.card_id, "current_health": c.data.health })
		i += 1
	return {
		"player_hp": $PlayerManager.hp,
		"vampire_hp": $VampireManager.hp,
		"player_drawn": $PlayerDeck.drawn_card_this_turn,
		"cards": cards
	}

# load the game if a snapshot is detected
func apply_snapshot(snap: Dictionary):
	# clear the deck 
	$PlayerDeck.player_deck.clear()
	$PlayerManager.set_hp(snap.player_hp)
	$VampireManager.set_hp(snap.vampire_hp)
	$PlayerDeck.drawn_card_this_turn = bool(snap.player_drawn)
	var p_hand_rows: Array = []
	var v_hand_rows: Array = []
	# one row in the cards table
	for row in snap.cards:
		# get the data of the card
		var data: CardData = CardDatabase.get_card(row.card_id)
		if data == null:
			return
		# where was this card positioned when saved ?
		match row.zone:
			"deck":
				# save card back into player deck
				if row.owner == "player":
					$PlayerDeck.player_deck.append(row.card_id)
			"hand":
				# save rows associated to vampire or player
				if row.owner == "vampire":
					v_hand_rows.append(row)
				else: p_hand_rows.append(row)
			"slot":
				# figure out if this will go in player or vampire slot
				var slots = $BoardManager.player_slots if row.owner == "player" else $BoardManager.vampire_slots
				# grab the slot by index
				var slot: CardSlot = slots[row.slot_index]
				var card = preload(CARD_SCENE_PATH).instantiate()
				$CardManager.add_child(card)
				card.setup(data)
				# restore changed health value (not base health)
				card.restore_health(row.current_health)
				# is the card able to be moved
				card.has_fought = bool(row.has_fought)
				# set position (no sliding in)
				card.global_position = slot.global_position
				# sets card in slot
				$BoardManager.place_card(card, slot)
	# use load_hand helper functions to sort through rows of cards and put it into the correct hand
	$PlayerHand.load_hand(p_hand_rows)
	$VampireManager.load_hand(v_hand_rows)
	# refresh the deck count
	var deck_size = $PlayerDeck.player_deck.size()
	$PlayerDeck/RichTextLabel.text = str(deck_size)
	if deck_size == 0:
		$PlayerDeck/Area2D/CollisionShape2D.disabled = true
		$PlayerDeck/Sprite2D.visible = false
		$PlayerDeck/RichTextLabel.visible = false
	change_state(State.PLAYER_TURN)
	
# func to handle end turn button press
func _on_end_turn_button_pressed() -> void:
	# if player turn, move to combat
	if state != State.PLAYER_TURN:
		return
	change_state(State.COMBAT)

# func to handle pause button press
func _on_pause_button_pressed() -> void:
	# save state to restore on unpause
	state_before = state
	# if player paused, change state to paused
	change_state(State.PAUSE)

# func to handle un-pausing
func _on_unpause_button_pressed() -> void:
	exit_pause()

# returns to main menu
func _on_main_menu_button_pressed() -> void:
	# unpause so title screen works
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Title.tscn")
	
func _on_save_game_button_pressed() -> void:
	# if it's not the player's turn, disable save
	if state_before != State.PLAYER_TURN:
		print("cannot save game unless it's the player's turn")
		return
	SaveManager.save_game(build_snapshot())
	print("game saved!")
