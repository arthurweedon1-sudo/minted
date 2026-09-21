extends Control

var hidden_box: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.debug_enabled:
		show()
		hidden_box = false
		$TimeSpeed/timespeed.value = Global.CLOCK_SPEED
		$Timemult/timemult.value = Global.SPEED_MULT
		$rent_frequency/HSlider.value = Global.rent_frequency
		$rent/button.text = str(Global.do_rent)
		$dialogue/dialogue.text = str(!Global.skip_dialogue)
		$hitboxes/hitboxes.text = "False"
		$sleep/sleep.text = str(!Global.no_sleep)
	else:
		hide()


func _on_timespeed_value_changed(value: float) -> void:
	Global.CLOCK_SPEED = value
	$TimeSpeed/value.text = str(value)


func _on_timemult_value_changed(value: float) -> void:
	Global.SPEED_MULT = int(value)
	$Timemult/value.text = str(int(value))


func _on_h_slider_value_changed(value: float) -> void:
	Global.rent_frequency = int(value)
	$rent_frequency/value.text = str(int(value))



func _on_button_pressed() -> void:
	Global.do_rent = !Global.do_rent
	$rent/button.text = str(Global.do_rent)



func _on_sleep_pressed() -> void:
	Global.no_sleep = !Global.no_sleep
	$sleep/sleep.text = str(!Global.no_sleep)


func _process(delta: float) -> void:
	if hidden_box:
		hide()
	else:
		show()
	if Input.is_action_just_pressed("debug") and Global.debug_enabled:
		hidden_box = !hidden_box

func _on_dialogue_pressed() -> void:
	Global.skip_dialogue = !Global.skip_dialogue
	$dialogue/dialogue.text = str(!Global.skip_dialogue)



func _on_give_pressed() -> void:
	var price_written: float = 0.0
	if $Givemoney/Price.text.is_valid_float():
		price_written = snapped($Givemoney/Price.text.to_float(), 0.01)
		Global.money += price_written
	
		
	
