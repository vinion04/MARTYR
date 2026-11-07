# ----- title_screen.gd -----
# handles start game button and switches scenes
extends Node


# if the save manager doesn't have a save, disable the continue game button
func _ready() -> void:
	# make sure title screen isn't frozen
	get_tree().paused = false
	_refresh_buttons()
	
func _on_continue_game_button_pressed() -> void:
	SaveManager.continue_game()


func _on_new_game_button_pressed() -> void:
	SaveManager.new_game()


func _on_delete_save_button_pressed() -> void:
	SaveManager.delete_save()
	print("game save data deleted !")
	_refresh_buttons()
	
func _refresh_buttons():
	var has_save = SaveManager.has_save()
	$ContinueGameButton.disabled = not has_save
	$DeleteSaveButton.disabled = not has_save
	print("saved game?: " + str(has_save))
