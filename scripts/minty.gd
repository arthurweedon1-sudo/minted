extends Control

@onready var sprite = $sprite
var movement = 10
var total = 0
var speed = 2

var floating = true
var current_y = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.start_tutorial.connect(show_tutorial_dialogue)
	current_y = sprite.position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if floating:
		total += delta*speed
		var total_truncated = total
		sprite.position.y = sin(total_truncated) * movement
	else:
		sprite.position.y = current_y

func _on_button_pressed() -> void:
	SignalBus.display_dialogue.emit("find", 15)
	movement = 5
	sprite.position.y = current_y

func show_tutorial_dialogue():
	SignalBus.display_dialogue.emit("find", "t0")
	movement = 5
	sprite.position.y = current_y
