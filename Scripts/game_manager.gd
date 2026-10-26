# ---------- game_manager.gd ----------
# contains state machine
extends Node2D

# ----- CONSTANTS -----
const STARTING_HAND_SIZE = 5

# signal
signal state_changed(new_state)

enum State { SETUP, DRAW, PLAYER_TURN, COMBAT, VAMPIRE_TURN, GAME_OVER}
var state: State = State.SETUP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
			pass # waiting for button implementation
		State.COMBAT:
			await enter_combat()
		State.VAMPIRE_TURN:
			await enter_vampire_turn()
		State.GAME_OVER:
			pass

# func to start the set up for the game
func enter_setup():
	# vampire lays hand first
	for i in STARTING_HAND_SIZE:
		$VampireManager.draw_card()
		# gives buffer time inbetween actions
		await get_tree().create_timer(0.5).timeout
	# then the player draws their opening hand
	for i in STARTING_HAND_SIZE:
		$PlayerDeck.draw_card()
		$PlayerDeck.drawn_card_this_turn = false
		await get_tree().create_timer(0.5).timeout
	# vampire places cards
	$VampireManager.play_turn()
	# can't draw a card on first turn
	$PlayerDeck.drawn_card_this_turn = true
	# next state would be player turn
	change_state(State.PLAYER_TURN)

# func for player to draw a card before turn
func enter_draw():
	# draw logic from deck
	# now it's player's turn
	change_state(State.PLAYER_TURN)
	
# func for when button clicked, enter combat phase
func enter_combat():
	# combat manager resolves all lanes
	await get_tree().create_timer(0.5).timeout
	change_state(State.VAMPIRE_TURN)
	
# func to start vampire turn after combat
func enter_vampire_turn():
	# vampire manager play turn goes here
	await get_tree().create_timer(0.5).timeout
	# after vampire turn, player draws
	change_state(State.DRAW)

# func to continue to combat after player's turn (called by end turn button)
func on_end_turn():
	# if it's the player's turn and they want to continue to combat
	if state == State.PLAYER_TURN:
		# continue to combat
		change_state(State.COMBAT)

# func to handle end turn button press
func _on_end_turn_button_pressed() -> void:
	# no longer player turn, move to combat
	change_state(State.COMBAT)
