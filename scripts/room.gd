extends Node2D

@onready var player = $player/Player
@onready var sleep_bar = $left_bar/sleep/sleep_bar
@onready var left_bar = $left_bar

@onready var building_label1: Label = $left_bar/rent/text/Building/price1
@onready var building_label2: Label = $left_bar/rent/text/Building/price2
@onready var electrical_label1: Label = $left_bar/rent/text/Electrical/price1
@onready var electrical_label2: Label = $left_bar/rent/text/Electrical/price2
@onready var utilities_label1: Label = $left_bar/rent/text/Utilities/price1
@onready var utilities_label2: Label = $left_bar/rent/text/Utilities/price2
@onready var maintenance_label1: Label = $left_bar/rent/text/Maintenance/price1
@onready var maintenance_label2: Label = $left_bar/rent/text/Maintenance/price2
@onready var broadband_label1: Label = $left_bar/rent/text/Broadband/price1
@onready var broadband_label2: Label = $left_bar/rent/text/Broadband/price2
@onready var total_label1: Label = $left_bar/rent/text/Total/price1
@onready var total_label2: Label = $left_bar/rent/text/Total/price2
@onready var days_1 = $left_bar/rent/text/Days/price1
@onready var days_2 = $left_bar/rent/text/Days/price2

var left = true
var total_rent = 0

func _ready() -> void:
	Inventory.current_ui_type = "player"
	player.global_position.x = Global.player_saved_x
	player.global_position.y = Global.player_saved_y
	if Global.first_room and not Global.skip_dialogue:
		Global.dialogue_ongoing = true
		await get_tree().create_timer(1.0).timeout
		SignalBus.display_dialogue.emit("find",0)
	

		
# i know this is a pants way of doing this but i cant be bothered shortening ts
# nah what is this bro. -_-
func _process(float) -> void:
	if TutorialManager.current_focus == "sleep_meter":
		%focus.show()
		%focus2.hide()
		%focus3.hide()
		%focus4.hide()
		%focus5.hide()
		%focus6.hide()
		%focus7.hide()
		%focus8.hide()
	elif TutorialManager.current_focus == "rent_slip":
		%focus.hide()
		%focus2.show()
		%focus3.hide()
		%focus4.hide()
		%focus5.hide()
		%focus6.hide()
		%focus7.hide()
		%focus8.hide()
	elif TutorialManager.current_focus == "computer":
		%focus.hide()
		%focus2.hide()
		%focus3.show()
		%focus4.hide()
		%focus5.hide()
		%focus6.hide()
		%focus7.hide()
		%focus8.hide()
	elif TutorialManager.current_focus == "storage":
		%focus.hide()
		%focus2.hide()
		%focus3.hide()
		%focus4.show()
		%focus5.hide()
		%focus6.hide()
		%focus7.hide()
		%focus8.hide()
	elif TutorialManager.current_focus == "shelf":
		%focus.hide()
		%focus2.hide()
		%focus3.hide()
		%focus4.hide()
		%focus5.show()
		%focus6.hide()
		%focus7.hide()
		%focus8.hide()
	elif TutorialManager.current_focus == "bed":
		%focus.hide()
		%focus2.hide()
		%focus3.hide()
		%focus4.hide()
		%focus5.hide()
		%focus6.show()
		%focus7.hide()
		%focus8.hide()
	elif TutorialManager.current_focus == "poster":
		%focus.hide()
		%focus2.hide()
		%focus3.hide()
		%focus4.hide()
		%focus5.hide()
		%focus6.hide()
		%focus7.show()
		%focus8.hide()
	elif TutorialManager.current_focus == "door":
		%focus.hide()
		%focus2.hide()
		%focus3.hide()
		%focus4.hide()
		%focus5.hide()
		%focus6.hide()
		%focus7.hide()
		%focus8.show()
	else:
		%focus.hide()
		%focus2.hide()
		%focus3.hide()
		%focus4.hide()
		%focus5.hide()
		%focus6.hide()
		%focus7.hide()
		%focus8.hide()
	sleep_bar.value = Global.sleep
	Global.player_saved_x = player.global_position.x
	Global.player_saved_y = player.global_position.y
	refresh_popup()
	
var tween: Tween
@onready var start_position: Vector2 = left_bar.position

func _on_slide_pressed() -> void:
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	left = !left
	$left_bar/sleep/slide.rotation_degrees += 180
	if left:
		
		var target_position = start_position 

		tween.tween_property(left_bar, "position", target_position, 1.0) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)
	else:
		var target_position = start_position + Vector2(200, 0)

		tween.tween_property(left_bar, "position", target_position, 1.0) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)
		
func refresh_popup() -> void:
	building_label1.text = "$" + "%.2f" % Global.rent_building
	building_label2.text = "$" + "%.2f" % Global.rent_building
	electrical_label1.text = "$" + "%.2f" % Global.rent_electrical
	electrical_label2.text = "$" + "%.2f" % Global.rent_electrical
	utilities_label1.text = "$" + "%.2f" % Global.rent_utilities
	utilities_label2.text = "$" + "%.2f" % Global.rent_utilities
	maintenance_label1.text = "$" + "%.2f" % Global.rent_maintenance
	maintenance_label2.text = "$" + "%.2f" % Global.rent_maintenance
	broadband_label1.text = "$" + "%.2f" % Global.rent_broadband
	broadband_label2.text = "$" + "%.2f" % Global.rent_broadband
	total_rent = Global.rent_building + Global.rent_electrical + Global.rent_utilities + Global.rent_maintenance + Global.rent_broadband
	total_label1.text = "$" + "%.2f" % total_rent
	total_label2.text = "$" + "%.2f" % total_rent
	if total_rent > Global.money:
		total_label2.add_theme_color_override("font_color", Color(1, 0, 0)) 
	else:
		total_label2.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0)) 
	days_1.text = str(Global.rent_frequency - Global.days_since_rent)
	days_2.text = str(Global.rent_frequency - Global.days_since_rent)
	if Global.rent_frequency - Global.days_since_rent == 1 and Global.hour < 12:
		days_1.text = "Today at 12PM"
		days_2.text = "Today at 12PM"
	elif Global.rent_frequency - Global.days_since_rent == 1 and Global.hour > 12:
		days_1.text = "Tomorrow at 12PM"
		days_2.text = "Tomorrow at 12PM"
