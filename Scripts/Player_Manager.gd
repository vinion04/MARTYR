# ---------- player_manager.gd ----------
# used to hold player health, curses/modifiers, and a win/loss check
extends Node
class_name PlayerManager

signal died

# ----- VARIABLES -----
# set max player hp
@export var max_hp: int = 20
var hp: int = max_hp

# function to set player hp, clamping at max
func set_hp(value: int):
	hp = clampi(value, 0, max_hp)
	# if player health is < 0, let game know
	if hp<= 0:
		died.emit()

# decrements player health
func take_damage(damage):
	print("player health: " + str(hp))
	set_hp(hp - damage)
