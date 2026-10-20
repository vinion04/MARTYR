# ---------- game_manager.gd ----------
# contains start game mechanics, and saves state
extends Node2D

# ----- CONSTANTS -----
const STARTING_HAND_SIZE = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()


func start_game():
	# vampire lays hand first
	for i in STARTING_HAND_SIZE:
		$VampireManager.draw_card()
		await get_tree().create_timer(0.5).timeout
	# then the player draws their opening hand
	for i in STARTING_HAND_SIZE:
		$PlayerDeck.draw_card()
		$PlayerDeck.drawn_card_this_turn = false
		await get_tree().create_timer(0.5).timeout
	$VampireManager.play_turn()
