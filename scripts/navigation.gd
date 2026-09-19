extends PanelContainer

@onready var home_screen = get_node_or_null("/root/MainUI/Home")
@onready var newspaper_screen = get_node_or_null("/root/MainUI/Newspaper")
@onready var options_screen = get_node_or_null("/root/MainUI/Skill_Tree")
@onready var mintora_screen = get_node_or_null("/root/MainUI/Mintora")

func _ready() -> void:
	print("home: ", home_screen)
	print("newspaper: ", newspaper_screen)
	print("options: ", options_screen)
	print("mintora: ", mintora_screen)
	if home_screen != null:
		home_screen.show()
		newspaper_screen.hide()
		options_screen.hide()
		mintora_screen.hide()

func _on_home_pressed() -> void:
	home_screen.show()
	newspaper_screen.hide()
	options_screen.hide()
	mintora_screen.hide()
	Global.on_market = false
	SignalBus.hide_zoom.emit()
	AudioManager.skill_tree = false
	
func _on_newspaper_pressed() -> void:
	home_screen.hide()
	newspaper_screen.show()
	options_screen.hide()
	mintora_screen.hide()
	Global.on_market = false
	SignalBus.hide_zoom.emit()
	AudioManager.skill_tree = false

func _on_mintora_pressed() -> void:
	home_screen.hide()
	newspaper_screen.hide()
	options_screen.hide()
	mintora_screen.show()
	SignalBus.hide_zoom.emit()
	AudioManager.skill_tree = false
	

func _on_exit_pressed() -> void:
	Global.mintora = false
	Global.on_computer = false
	get_tree().change_scene_to_file("res://scenes/room.tscn")
	AudioManager.skill_tree = false


func _on_skill_tree_pressed() -> void:
	home_screen.hide()
	newspaper_screen.hide()
	options_screen.show()
	mintora_screen.hide()
	SignalBus.show_zoom.emit()
	AudioManager.skill_tree = true
