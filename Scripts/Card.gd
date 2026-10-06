# # ---------- card.gd ----------
# handles card movement
extends Node2D

# signals to communicate with CardManager script
signal hovered
signal hovered_off

# ----- VARIABLES -----
var starting_position
var data: CardData
var item_sprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# all cards must be a child of CardManager
	get_parent().connect_card_signals(self)
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
	# set attack and health amounts
	$Attack.text = str(data.attack)
	$Health.text = str(data.health)
	# set corresponding image
	item_sprite.texture = data.art

# build in GDScript function for hovering
func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)

# build in GDScript function for hovering
func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)
