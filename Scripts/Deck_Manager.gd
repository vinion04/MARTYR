# # ---------- deck_manager.gd ----------
# used to randomize deck, draw cards into hand, and keep track of discards
extends Node

# ----- VARIABLES -----
# card draw speed from deck
const DRAW_SPEED = .5
# what is in the player's deck ?
var player_deck = ['Sword', 'Crossbow', 'Dagger',]
# paths
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set deck count
	$RichTextLabel.text = str(player_deck.size())
	
func draw_card():
	# take top card from deck
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	# if that was the last card of deck, disable deck
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
		# set deck text displayed to deck size
	$RichTextLabel.text = str(player_deck.size())
	# get card data from database
	var data = CardDatabase.get_card(card_drawn)
	# create card and add it to the hand
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	$"../CardManager".add_child(new_card)
	# set up this new card with matching data
	new_card.setup(data)
	$"../PlayerHand".add_card_to_hand(new_card, DRAW_SPEED)
