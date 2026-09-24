extends Control

@onready var time_ui = $sleep/timer/Time
@onready var slider = $HSlider
@onready var sleep_bar = $sleep/sleep_bar
@onready var sleep_needed = $sleep/sleep_needed
@onready var sleep_gained = $sleep/sleep_gained
var sleep_duration = 8
@onready var sleep_text = $Sleep_duration
@onready var not_tired = $not_tired
@onready var fade_overlay = $PanelContainer2
var sleep_needed_int = 0
var sleep_gained_int = 0

@onready var sleep_track = preload("res://audio/sleep_ambience.mp3")
@onready var themey = preload("res://audio/background_menu.mp3")
var sleep_name = "Sleep"
var sleep_vals = [8,10,12,14,16,18,20,22,25,28,31,35,41,46,50]
var sleep_amounts = [20,25,30,33,36,40,42,46,48,50,52,54,57,61,65]

func _ready() -> void:
	var original_image = Image.load_from_file("res://assets/os/icons/sleep.png")	
	original_image.resize(32, 32, Image.INTERPOLATE_LANCZOS)
	sleep_text.grow_horizontal = Control.GROW_DIRECTION_BOTH
	var small_tex = ImageTexture.create_from_image(original_image)
	
	# Apply the resized texture to the theme overrides
	slider.add_theme_icon_override("grabber", small_tex)
	slider.add_theme_icon_override("grabber_highlight", small_tex)
	sleep_needed.value = 0
	sleep_bar.value = Global.sleep
	get_sleep_text(8.0)
	_on_h_slider_value_changed(8)
	
func _process(delta:float) -> void:
	sleep_bar.value = Global.sleep
	sleep_needed_int = sleep_vals[slider.value-2]
	if Global.hour >= 6 and Global.hour <= 10:
		sleep_needed_int += 20
	elif Global.hour >= 7 and Global.hour <= 18:
		sleep_needed_int += 30
	elif Global.hour >= 18 and Global.hour <= 22:
		sleep_needed_int += 10
	sleep_needed.value = sleep_needed_int
	sleep_gained.value = round(min(sleep_gained_int*Global.sleep_mult,sleep_gained_int*Global.sleep_mult-(sleep_gained_int+Global.sleep-100)))
	#time_ui.text = Global.get_time_text()
	sleep_gained.rotation_degrees = Global.sleep * 3.6
	
	var time = slider.value
	if (Global.hour + int(time)) %24 < 10:
		var hour = (Global.hour + int(time)) %24
		var min = Global.min
		if min < 10:
			time_ui.text = "0" + str(hour) + ":" + "0" + str(min)
		else:
			time_ui.text = "0" + str(hour) + ":" + str(min)
	else:
		var hour = (Global.hour + int(time)) %24
		var min = Global.min
		if min < 10:
			time_ui.text = str(hour) + ":" + "0" + str(min)
		else:
			time_ui.text = str(hour) + ":" + str(min)
			
func get_sleep_text(time):
	var format_string = "(%s hours)"
	sleep_text.text = sleep_name + " " + format_string % time
	$text2.text = "Gaining " + str(sleep_gained_int) +"% sleep"
	if (Global.hour + int(time)) %24 < 10:
		var hour = (Global.hour + int(time)) %24
		var min = Global.min
		if min < 10:
			time_ui.text = "0" + str(hour) + ":" + "0" + str(min)
		else:
			time_ui.text = "0" + str(hour) + ":" + str(min)
	else:
		var hour = (Global.hour + int(time)) %24
		var min = Global.min
		if min < 10:
			time_ui.text = str(hour) + ":" + "0" + str(min)
		else:
			time_ui.text = str(hour) + ":" + str(min)
		
func _on_h_slider_value_changed(value: float) -> void:
	if slider.value == 16:
		sleep_name = "Hibernate"
	elif slider.value >= 10:
		sleep_name = "Deep Sleep"
	elif slider.value >= 6:
		sleep_name = "Sleep"
	elif slider.value >= 4:
		sleep_name = "Rest"
	else:
		sleep_name = "Nap"
	 
	sleep_needed.value = sleep_needed_int
	sleep_needed_int = sleep_vals[slider.value-2]
	sleep_gained_int = sleep_amounts[slider.value-2]

	if Global.hour >= 6 and Global.hour <= 10:
		sleep_needed_int += 20
	elif Global.hour >= 7 and Global.hour <= 18:
		sleep_needed_int += 30
	elif Global.hour >= 18 and Global.hour <= 22:
		sleep_needed_int += 10
	get_sleep_text(slider.value)

func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/room.tscn")

func fade_to_black(duration: float = 1.0) -> void:
	fade_overlay.show() 
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate", Color(1, 1, 1, 1), duration)
	await tween.finished

func fade_from_black(duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate", Color(1, 1, 1, 0), duration)
	await tween.finished
	fade_overlay.hide() 

func simulate_sleep(hours_to_sleep: int) -> Dictionary:
	var hours_slept = 0
	var sleep_percent: float = 0
	var rent_due = false
	for i in range(hours_to_sleep):
		Global.hour += 1
		hours_slept += 1
		sleep_percent += 1.0/float(hours_to_sleep)
 
		if Global.hour == 12:
			Global.days_since_rent += 1
			if Global.days_since_rent >= Global.rent_frequency:
				Global.rent_ready = true
				Global.days_since_rent = 0
			if Global.rent_ready:
				rent_due = true
 
		if Global.hour >= 24:
			Global.hour -= 24
			Global.day += 1
			var days_in_month = Global.calc_days_in_month(Global.month, Global.year)
			if Global.day > days_in_month:
				Global.day = 1
				Global.month += 1
				if Global.month > 12:
					Global.month = 1
					Global.year += 1
 
		if rent_due:
			break
 
	return {"hours_slept": hours_slept, "rent_due": rent_due, "sleep_percent":sleep_percent}
			
func _on_sleep_button_pressed() -> void:
	if float(sleep_needed_int) + Global.sleep > 100:
		not_tired.text = "Not Tired Enough..."
	else:
		Global.current_interactable = null
		Global.dialogue_ongoing = true
		AudioManager.pause(true)
		fade_overlay.modulate = Color(1, 1, 1, 0)
		await fade_to_black(1.5)
		
		$dialogue.sleep_mode()
		$sleep_screen.show()		
		var sleep_tween = create_tween()
		$sleep_screen.fade_out_black_screen()
		sleep_tween.tween_property($sleep_screen, "modulate", Color(1, 1, 1, 1), 2.0)
		await sleep_tween.finished
		
		AudioManager.play_music(sleep_track)
		var requested_hours = int(slider.value)
		var sleep_result = simulate_sleep(requested_hours)
		var hours_slept = sleep_result["hours_slept"]
		var rent_due = sleep_result["rent_due"]
		var sleep_ratio = sleep_result["sleep_percent"]
		
		if rent_due:
			SignalBus.display_dialogue.emit("find", 11)
		else:
			SignalBus.display_dialogue.emit("find", 9)
		await SignalBus.dialogue_finished
 
		
		Global.sleep += min(float(sleep_gained_int) * sleep_ratio, 100)
		Global.time_mins = (Global.time_mins + hours_slept * 60) % 60
		get_sleep_text(8.0)
		_on_h_slider_value_changed(8)

		$sleep_screen.hide()
		AudioManager.pause(false)
		Global.goto_scene("res://scenes/room.tscn")
		Global.dialogue_ongoing = false
		AudioManager.play_music(themey)
		if rent_due:
			Global.rent_triggered = true
