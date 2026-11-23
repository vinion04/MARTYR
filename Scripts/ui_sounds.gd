extends Node

const CLICK_SOUND = preload("res://Audio/thepixelguymaker-button-click-vintage-sound-fx-541135.mp3")

# make an audio stream player
var player := AudioStreamPlayer2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# keeps working while paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# sets audio player click sound
	player.stream = CLICK_SOUND
	add_child(player)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# find what the mouse is clicking on
		var hovered = get_viewport().gui_get_hovered_control()
		# if it's a button, play sound !
		if hovered is BaseButton and not hovered.disabled:
			player.play()
