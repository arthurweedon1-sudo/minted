extends Control

func _ready() -> void:
	Global.playing = false
	AudioManager.play_music(AudioManager.background_menu_music)
	if !SaveLoad.has_save():
		$button_container/Continue_Button.hide()
	else:
		$button_container/Continue_Button.show()

func _on_play_button_pressed() -> void:
	Global.do_rent = true
	Global.playing = true
	get_tree().change_scene_to_file("res://scenes/room.tscn")
	
func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_exit_game_button_pressed() -> void:
	SaveLoad._save()
	get_tree().quit()

func _on_new_game_button_pressed() -> void:
	Global.playing = true
	if SaveLoad.has_save():
		SaveLoad._wipe()
	get_tree().change_scene_to_file("res://scenes/room.tscn")
