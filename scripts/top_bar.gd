extends PanelContainer

@onready var money_ui: Label = $back_nodes/CenterContainer/money_container/VBoxContainer/HBoxContainer/Control/Label
@onready var time_ui = $Right/Time_Container/HBoxContainer/Control/Time
@onready var date_ui = $Right/Time_Container/HBoxContainer/Date
@onready var level_display: MarginContainer = $Left/Level_Display
@onready var level_rank_label: Label = $Left/MarginContainer/VBoxContainer/VBoxContainer2/MarginContainer/Label
@onready var stars: Control = $Left/MarginContainer/VBoxContainer/VBoxContainer2/MarginContainer/Stars

var money_string: String = ""


func _process(delta):
	if Global.mintora:
		%background_mintora.show()
		%background.hide()
	else:
		%background_mintora.hide()
		%background.show()
	
	money_string = " "
	money_string += format_with_commas(Global.money)
	
	%Username.text = Global.username
	
	money_ui.text = money_string
	time_ui.text = Global.get_time_text()
	date_ui.text = Global.get_date_text()
	
	# Level/Rank text (i need to start commenting more so I know where everything is bruh)
	level_rank_label.text = "Level " + str(level_display.level_calculator(Global.xp)) + " " + str(Global.rank)
	
	# Stars
	stars.star_calc(Global.player_rating)
	
func format_with_commas(number: float) -> String:
	# kinda just asked the big gpt for this cos this is confusing :0
	var is_negative = number < 0
	number = abs(number)
	var rounded = snapped(number, 0.01)
	var int_part = int(rounded)
	var decimal_part = round((rounded - int_part) * 100)
	if decimal_part >= 100:
		int_part += 1
		decimal_part -= 100
	var s = str(int_part)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
	var decimal_str = str(int(decimal_part))
	if decimal_str.length() < 2:
		decimal_str = "0" + decimal_str
	var final_result = result + "." + decimal_str
	if is_negative:
		final_result = "-" + final_result
	return final_result

func _on_book_button_mouse_entered() -> void:
	$back_nodes/CenterContainer/book_node/book_sprite.play("default")



func _on_book_button_mouse_exited() -> void:
	$back_nodes/CenterContainer/book_node/book_sprite.play_backwards("default")


func _on_texture_button_pressed() -> void:
	ActionPopup.usernamePanel.show()
