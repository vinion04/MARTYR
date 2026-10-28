# # ---------- player_manager.gd ----------
# used to hold player health, curses/modifiers, and a win/loss check
extends Node

# ----- VARIABLES -----
# health
var player_health = 50

func take_damage(damage):
	player_health -= damage
	print("player health: " + str(player_health))
