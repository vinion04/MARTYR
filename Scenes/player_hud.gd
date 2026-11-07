# ----- player_hud.gd -----
extends Panel
class_name PlayerHUD

# ----- VARIABLES -----
# text labels
@onready var p_hp_label: RichTextLabel = $PlayerHealth
@onready var v_hp_label: RichTextLabel = $VampireHealth


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_player_display_health($"../../PlayerManager".hp)
	update_vampire_display_health($"../../VampireManager".hp)
	
func update_player_display_health(hp):
	p_hp_label.text = "Player HP: " + str(hp)
	
func update_vampire_display_health(hp):
	v_hp_label.text = "Vampire HP: " + str(hp)
