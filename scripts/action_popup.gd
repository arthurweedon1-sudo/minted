extends CanvasLayer

@onready var usernamePanel: Control = $username_change

func _ready() -> void:
	usernamePanel.hide()
	%username_field.text = Global.username
	%username_field.placeholder_text = "Enter Username"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.playing:
		$CanvasLayer/VBoxContainer.show()
	else:
		$CanvasLayer/VBoxContainer.hide()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Global.SPEED_MULT = 0
		$pause_menu.show()
		get_viewport().set_input_as_handled()

func _on_confirm_button_pressed() -> void:
	Global.username = %username_field.text
	usernamePanel.hide()


func _on_confirm_button_mouse_entered() -> void:
	%confirmButton.modulate.a = 0.7


func _on_confirm_button_mouse_exited() -> void:
	%confirmButton.modulate.a = 1


func _on_resume_pressed() -> void:
	Global.SPEED_MULT = 1
	$pause_menu.hide()


func _on_options_pressed() -> void:
	Global.SPEED_MULT = 1
	$pause_menu.hide()
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_quit_title_pressed() -> void:
	Global.SPEED_MULT = 1
	$pause_menu.hide()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_close_pressed() -> void:
	$CanvasLayer/info.hide()
