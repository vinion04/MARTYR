extends Node

const CLICK_SOUND = preload("res://Audio/thepixelguymaker-button-click-vintage-sound-fx-541135.mp3")

# make an audio stream player
var player := AudioStreamPlayer2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# this keeps working while game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# set the click sound to the player
	player.stream = CLICK_SOUND
	add_child(player)
	# every node in tree
	_connect_existing(get_tree().root)
	
func _connect_existing(node: Node):
	_on_node_added(node)
	# go through each node and connect them if buttons
	for child in node.get_children():
		_connect_existing(child)
		
func _on_node_added(node: Node):
	# if the node is a button
	if node is BaseButton:
		# connect the pressed to play the audio
		if not node.pressed.is_connected(_play):
			node.pressed.connect(_play)
			
func _play():
	player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
