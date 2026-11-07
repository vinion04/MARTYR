# # ---------- card.gd ----------
# handles card movement
extends Node2D

# ----- VARIABLES -----
var starting_position
var data: CardData
var item_sprite: Sprite2D
var current_slot = null
# store current card health
var current_health
# to see if the card can be pulled back into hand or not
var has_fought: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set scale
	self.scale = Vector2(4, 4)
	# get sprite2d
	item_sprite = get_node("ItemImage")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# used to set card data
func setup(card_data: CardData):
	data = card_data
	# stores card health from card_data
	current_health = data.health
	# set attack and health amounts
	$Attack.text = str(data.attack)
	$Health.text = str(data.health)
	# set corresponding image
	item_sprite.texture = data.art
	
# for reloading the card with saved health amount (not base health)
func restore_health(value: int):
	current_health = value
	$Health.text = str(current_health)

# used for card to take damage
func take_damage(amount):
	# take damage and update health on card
	current_health -= amount
	$Health.text = str(current_health)
