# ---------- save_manager.gd ----------
# save, load, and delete game state
# Claude AI helped with formatting what I should have in my tables
extends Node

# ----- VARIABLES
var database: SQLite
# store snapshot to survive scene change and load correctly
var pending_snapshot: Dictionary = {}

func _ready() -> void:
	# create a database and open it
	database = SQLite.new()
	database.path = "user://martyr_save"
	# check if the database can be opened
	if not database.open_db():
		push_error("SaveManager: could not open DB: " + database.error_message)
		return
	create_tables()
	
# create tables needed to save game
func create_tables():
	# create a game state table to save game specifics (health)
	database.create_table("game_state", {
		"id": {"data_type": "int", "primary_key": true, "not_null": true},
		"player_hp": {"data_type": "int", "not_null": true},
		"vampire_hp": {"data_type": "int", "not_null": true},
		"player_drawn": {"data_type": "bool", "not_null": true}
	})
	# create a cards table to keep track of what cards are on the board and their health
	database.create_table("cards", {
		"id": {"data_type": "int", "primary_key": true, "auto_increment": true, "not_null": true},
		"owner": {"data_type": "text", "not_null": true},       # "player" or "vampire"
		"zone": {"data_type": "text", "not_null": true},        # "deck", "hand", or "slot"
		"position": {"data_type": "int", "not_null": true},     # order within deck or hand (0 = top/leftmost)
		"slot_index": {"data_type": "int", "not_null": true},   # which board slot, or -1 if not on the board
		"card_id": {"data_type": "text", "not_null": true},     # which card definition this is
		"current_health": {"data_type": "int", "not_null": true},
		"has_fought": {"data_type": "int", "not_null": true}
	})

# save the current game state
func save_game(snapshot):
	# implement all or nothing so there are no half saves if a crash happens (using a transaction)
	# delete data from game_state and cards to save new data
	database.query("BEGIN TRANSACTION;")
	database.query("DELETE FROM game_state;")
	database.query("DELETE FROM cards;")
	# insert game state data
	database.insert_row("game_state", {
		"id": 1,
		"player_hp": snapshot.player_hp,
		"vampire_hp": snapshot.vampire_hp,
		"player_drawn": snapshot.player_drawn
	})
	# for every card in game
	for card in snapshot.cards:
		database.insert_row("cards", {
			"owner": card.owner, "zone": card.zone, "position": card.position, "slot_index": card.slot_index,
			"card_id": card.card_id, "current_health": card.current_health, "has_fought": int(card.get("has_fought", 0))})
	var ok := database.query("COMMIT;")
	# if it didn't work
	if not ok:
		database.query("ROLLBACK;")
		push_error("SaveManager: save failed: " + database.error_message)
	return ok
	
# check if save exists
func has_save():
	database.query("SELECT id FROM game_state WHERE id = 1;")
	return database.query_result.size() > 0
	
# load existing save data
func load_game():
	# check if there is a save
	if not has_save():
		return{}
	database.query("SELECT * FROM game_state WHERE id = 1;")
	# grab the game state data
	var data: Dictionary = database.query_result[0]
	# create the snapshot of the loaded data
	var snapshot := {
		"player_hp": data.player_hp,
		"vampire_hp": data.vampire_hp,
		"player_drawn": data.player_drawn,
		"cards": []
	}
	# save cards as new copies
	database.query("SELECT * FROM cards ORDER BY zone, position;")
	snapshot.cards = database.query_result.duplicate(true)
	return snapshot
	
# for use on continue game button
func continue_game():
	var snapshot = load_game()
	# if there is no game save to load
	if snapshot.is_empty():
		return
	pending_snapshot = snapshot
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	
# for use on new game button
func new_game():
	pending_snapshot = {}
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	
# deletes the save
func delete_save():
	database.query("DELETE FROM game_state;")
	database.query("DELETE FROM cards;")
