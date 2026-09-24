extends Control

var dialogue_data =  {}
var option_selected = 0
var next_dialogue = ""
var current_dialgoue_type = ""
var current_choices = []
var dialgoue_speed = 0.02
var timer = 0
var active_tween: Tween = null
var dialgoue_length = 0
var tween_time = 0
var raw_text_string = ""
var text_timer = 0
var pause_timer = 0
var is_typing = false
var play_animation = true
var animation_playing = ""



@onready var portrait = $portrait
@onready var text_display = $ColorRect/RichTextLabel
@onready var choiceA = $ColorRect/choices/choiceA
@onready var choiceB = $ColorRect/choices/choiceB

func load_json_file(file_path: String) -> Variant:
	if FileAccess.file_exists(file_path):
		var data_file = FileAccess.open(file_path, FileAccess.READ)
		var parsed_data = JSON.parse_string(data_file.get_as_text())
		data_file.close()
		return parsed_data
	else:
		print("file does not exist!")
		return null


func get_dialogue_by_id(data:Array, to_find):
	for dialogue in data:
		if dialogue.get("id") == str(to_find):
			return dialogue
	return null

func display_portrait(speaker, face):
	if speaker == "margaret":
		var animation_name = speaker + "_" + face
		portrait.play(animation_name)
	elif speaker == "landlord":
		var animation_name = speaker + "_" + face
		portrait.play(animation_name)		
	else:
		portrait.play("none")
func _display_dialogue(data, id):
	visible = true
	Global.paused = true
	Global.dialogue_ongoing = true
	if data is not Array:
		if data == "find":
			data = dialogue_data
	var dict_display = get_dialogue_by_id(data, id)
	var type = dict_display.get("type")
	var speaker = dict_display.get("speaker")
	var face = dict_display.get("face")
	display_portrait(speaker,face)
	choiceA.text = ""
	choiceB.text = ""
	text_display.text = ""
	option_selected = 0
	current_dialgoue_type = type
	play_animation = true
	
	if type == "line":
		raw_text_string = dict_display.get("text")
		text_display.text = dict_display.get("text")
		var next = dict_display.get("next_id")
		if next != null:
			next_dialogue = str(next)
		else:
			next_dialogue = ""
		dialgoue_length = len(dict_display.get("text"))
		display_type_dialogue(dialgoue_length)
	elif type == "end":
		raw_text_string = dict_display.get("text")
		current_dialgoue_type = "delete"
		text_display.text = dict_display.get("text")
		next_dialogue = "end"
		dialgoue_length = len(dict_display.get("text"))
		display_type_dialogue(dialgoue_length)
	elif type == "choice":
		var choices = dict_display.get("choices")
		current_choices = []
		for i in choices:
			current_choices.append(i.get("next_id"))
		if choices.size() == 2:
			choiceA.text = choices[0].get("text")
			choiceB.text = choices[1].get("text")

func display_type_dialogue(length):
	var regex = RegEx.new()
	regex.compile("<p[0-9.]*>|<at>|<af>|<st>")
	text_display.text = regex.sub(raw_text_string, "", true)
	text_display.visible_characters = 0
	text_timer = 0.0
	pause_timer = 0.0
	is_typing = true


func process_dialogic(delta: float): #dialogue logic	
	if not is_typing:
		return
	
	if pause_timer > 0:
		pause_timer -= delta
		return
	
	text_timer += delta
	if text_timer >= dialgoue_speed:
		var current_visible = text_display.visible_characters
		var total_visible = text_display.get_parsed_text().length()
		
		if current_visible < total_visible:

			text_timer = 0
			var index = get_text_pos(current_visible)
			if raw_text_string.substr(index,4) == "<p1>":
				pause_timer = 1
			elif raw_text_string.substr(index,6) == "<p0.5>":
				pause_timer = 0.5
			elif raw_text_string.substr(index,4) == "<at>":
				play_animation = true
			elif raw_text_string.substr(index,4) == "<af>":
				play_animation = false
			elif raw_text_string.substr(index,4) == "<st>":
				display_portrait("margaret","tsun_speak")
			text_display.visible_characters += 1
		else:
			is_typing = false

func get_text_pos(id):
	var visible_count = 0
	var i = 0
	while i < raw_text_string.length() and visible_count < id:
		if visible_count == id: 
				break
		if raw_text_string.substr(i,4) == "<p1>" or raw_text_string.substr(i,4) == "<at>" or raw_text_string.substr(i,4) == "<af>" :
			i += 4
			continue
		elif raw_text_string.substr(i,6) == "<p0.5>":
			i += 6
			continue
		elif raw_text_string[i] == "[":
			while i < raw_text_string.length() and raw_text_string[i] != "]":
				i += 1
				continue
		else:
			i += 1
			visible_count += 1
	return i
func highlight_text():
	if option_selected == 0:
		choiceA.self_modulate = Color.MEDIUM_SPRING_GREEN
		choiceB.self_modulate = Color.WHITE
	elif option_selected == 1:
		choiceB.self_modulate = Color.MEDIUM_SPRING_GREEN
		choiceA.self_modulate = Color.WHITE
				
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.display_dialogue.connect(_display_dialogue)
	dialogue_data = load_json_file("res://dialogue/test.json")
	#_display_dialogue(dialogue_data,17)
	choiceA.text = ""
	choiceB.text = ""
	$ColorRect/RichTextLabel.text = ""
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if TutorialManager.current_focus != "none" or not Global.dialogue_ongoing:
		hide()
	else:
		show()
	if is_typing:
		if portrait.animation == "margaret_tsun" and portrait.frame == 5:
			portrait.frame = 5
		else:
			portrait.play() 
	else:
		portrait.stop() 
		portrait.frame = 0
	if not play_animation:
		portrait.stop() 
		portrait.frame = 0
	if Input.is_action_just_pressed("interact"):
		if is_typing:
			is_typing = false
			pause_timer = 0.0
			text_display.visible_characters = text_display.get_parsed_text().length()
			return
		if current_dialgoue_type == "line" or current_dialgoue_type == "end": 
			_display_dialogue(dialogue_data,next_dialogue)
			SignalBus.focus_change.emit()
		elif current_dialgoue_type == "choice":
			if option_selected < current_choices.size():
				next_dialogue = current_choices[option_selected]
				_display_dialogue(dialogue_data,next_dialogue)		
			else:
				next_dialogue = 0
		elif next_dialogue == "end":
			Global.dialogue_ongoing = false
			visible = false
			Global.paused = false
			SignalBus.dialogue_finished.emit()
			SignalBus.focus_change.emit()
			if not Global.tutorial_done:
				SignalBus.emit_signal("start_tutorial")
				Global.tutorial_done = true
	
	#highlight stuff
	if Input.is_action_just_pressed("up"):
		option_selected -= 1
		if option_selected < 0:
			option_selected = current_choices.size()-1
	if Input.is_action_just_pressed("down"):
		option_selected += 1
		if option_selected > current_choices.size()-1:
			option_selected = 0
	
	timer += delta
	if timer > dialgoue_speed:
		pass
		timer = 0
	highlight_text()
	process_dialogic(delta)

func sleep_mode():
	$ColorRect.color = Color(0.0,0.0,0.0,0.0)
	$ColorRect/RichTextLabel.custom_minimum_size = Vector2(600, 300)
	$ColorRect/RichTextLabel.add_theme_font_size_override("normal_font_size",70)
