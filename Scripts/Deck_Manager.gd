# ---------- deck_manager.gd ----------
# used to randomize deck, draw cards into hand, and keep track of discards
extends Node

signal player_draw

# ----- VARIABLES -----
# holds player cards
var player_deck: Array = []
# one card drawn per turn
var drawn_card_this_turn = false
# draw sound to play
@onready var draw_sound: AudioStreamPlayer2D = $DrawSound

# ----- CONSTANTS -----
# what is in the player's deck ?
const DECK_LIST := {
	"Sword": 5,
	"Crossbow": 5,
	"Dagger": 5, 
	"Bandage": 5,
	"BallAndChain": 5,
	"Bloodbag": 5,
	"Bow": 5,
	"Elixer": 5,
	"Molotov": 5,
}
# card draw speed from deck
const DRAW_SPEED = .5
# paths
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_deck()
	# set deck count
	$RichTextLabel.text = str(player_deck.size())
	

# puts cards in deck, shuffles, and sets the deck count at beginning of scene
func build_deck():
	player_deck.clear()
	for id in DECK_LIST:
		for i in DECK_LIST[id]:
			player_deck.append(id)
	# shuffle() "shuffles all elements of the array in a random order
	player_deck.shuffle()
	
func draw_card(force: bool = false):
	# if this draw card is not being forced (forced during setup)
	if not force:
		# if card was already drawn this turn, do not draw a card
		if drawn_card_this_turn:
			return
		drawn_card_this_turn = true
	draw_sound.play()
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
	player_draw.emit()
	
	# get card data from database
	var data = CardDatabase.get_card(card_drawn)
	# create card and add it to the hand
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	$"../CardManager".add_child(new_card)
	# set up this new card with matching data
	new_card.setup(data)
	$"../PlayerHand".add_card_to_hand(new_card, DRAW_SPEED)
