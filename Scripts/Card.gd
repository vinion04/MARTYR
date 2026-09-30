# # ---------- card.gd ----------
# handles card movement
extends Node2D

# signals to communicate with CardManager script
signal hovered
signal hovered_off

# ----- VARIABLES -----
var starting_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# all cards must be a child of CardManager
	get_parent().connect_card_signals(self)
	# set scale
	self.scale = Vector2(4, 4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# build in GDScript function for hovering
func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)

# build in GDScript function for hovering
func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)
