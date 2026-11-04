# ---------- game_manager.gd ----------
# contains state machine
extends Node2D

# signal
signal state_changed(new_state)

# ----- CONSTANTS -----
const STARTING_HAND_SIZE = 5

# ----- VARIABLES -----
enum State { SETUP, DRAW, PLAYER_TURN, COMBAT, VAMPIRE_TURN, GAME_OVER, GAME_WIN, PAUSE}
var state: State = State.SETUP
# player health reference
var player_manager_ref
# vampire health reference
var vampire_manager_ref
# to store game state before pause to restore it
var state_before: State
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
	# start setup
	change_state(State.SETUP)
	
# func to handle state changes
func change_state(new_state: State):
	state = new_state
	print("STATE: ", State.keys()[new_state])
	state_changed.emit(new_state)
	match new_state:
		State.SETUP:
			await enter_setup()
		State.DRAW:
			await enter_draw()
		State.PLAYER_TURN:
			await player_turn()
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
		
# player cannot draw on their first turn !
func player_turn():
	if state_before == State.SETUP:
		$PlayerDeck.drawn_card_this_turn = true
	else: $PlayerDeck.drawn_card_this_turn = false
	
# func for when button clicked, enter combat phase
func enter_combat():
	# combat manager resolves all lanes
	await $CombatManager.resolve_all_lanes()
	change_state(State.VAMPIRE_TURN)
	
# func to start vampire turn after combat
func enter_vampire_turn():
	# vampire draws, then plays cards
	await $VampireManager.draw_card()
	$VampireManager.play_turn()
	# small gap between next state
	await get_tree().create_timer(0.5).timeout
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
	if state == State.GAME_WIN or state == State.GAME_WIN:
		return 			# this prevents the game from ending multiple times if combat continues in the background
	change_state(State.GAME_OVER)
	
# handle vampire death and game win
func on_vampire_died():
	if state == State.GAME_WIN or state == State.GAME_WIN:
		return 			# this prevents the game from ending multiple times if combat continues in the background
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
	state_changed.emit(state)
	
# this retrieves a snapshot of current game state to be used to save game state
func build_snapshot():
	# create card array for snapshot and add cards for player
	var cards: Array = []
	var i = 0
	for c in $PlayerDeck.player_deck:
		var card_data = CardDatabase.get_card(c)
		cards.append({"owner": "player", "zone": "deck", "position": i, "slot_index": -1,
			"card_id": card_data.card_id, "current_health": card_data.health})
		i += 1
	i = 0
	for c in $PlayerHand.hand:
		cards.append({"owner": "player", "zone": "hand", "position": i, "slot_index": -1,
			"card_id": c.data.card_id, "current_health": c.data.health })
		i += 1
	# get all cards from slots on board
	for slot_data in $BoardManager.get_all_cards_in_slots():	# NEED TO MAKE THIS HELPER FUNCTION
		var card_node = slot_data["card"]
		var slot_node = slot_data["slot"]
		cards.append({"owner": slot_data["owner"], "zone": "slot", "position": 0, "slot_index": card_node.current_slot,
			"card_id": card_node.data.card_id, "current_health": card_node.data.health})
	# now vampire specific stuff
	for c in $VampireManager.vampire_deck:
		var card_data = CardDatabase.get_card(c)
		cards.append({"owner": "vampire", "zone": "deck", "position": i, "slot_index": -1,
			"card_id": card_data.card_id, "current_health": card_data.health})
		i += 1
	i = 0
	for c in $VampireHand.hand:
		cards.append({"owner": "vampire", "zone": "hand", "position": i, "slot_index": -1,
			"card_id": c.data.card_id, "current_health": c.data.health })
		i += 1
	return {
		"player_hp": $PlayerManager.hp,
		"vampire_hp": $VampireManager.hp,
		"vampire_drawn": $VampireManager.drawn_card_this_turn,
		"player_drawn": $PlayerDeck.drawn_card_this_turn,
		"cards": cards
	}
	
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
