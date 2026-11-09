# ---------- player_manager.gd ----------
# used to hold player health, curses/modifiers, and a win/loss check
extends Node
class_name PlayerManager

signal died

# ----- VARIABLES -----
# set max player hp
@export var max_hp: int = 50
var hp: int = 20
@onready var player_hud_ref = $"../HUDLayer/PlayerHUD"

# function to set player hp, clamping at max
func set_hp(value: int):
	hp = clampi(value, 0, max_hp)
	player_hud_ref.update_player_display_health(hp)
	# if player health is < 0, let game know
	if hp<= 0:
		died.emit()

# decrements player health
func take_damage(damage):
	set_hp(hp - damage)
	
# increments player health
func get_heals(heal_amount):
	set_hp(hp + heal_amount)
