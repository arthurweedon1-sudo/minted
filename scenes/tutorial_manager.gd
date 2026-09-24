extends CanvasLayer

var current_focus = "none"

func _ready() -> void:
	hide()
	SignalBus.start_tutorial.connect(main_tutorial)
	SignalBus.focus_change.connect(focus_changer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(minty_old_position, minty_position, focus):
	%minty.position = minty_old_position
	var tween = create_tween()
	tween.tween_property(%minty, "position", minty_position, 0.5)
	current_focus = focus

func main_tutorial():
	show()
	setup(Vector2(573.0,364.0), Vector2(573.0,364.0), "top_bar")

func focus_changer():
	if current_focus == "top_bar":
		setup(Vector2(573.0,364.0), Vector2(573.0,364.0), "top_bar_level")
	elif current_focus == "top_bar_level":
		setup(Vector2(573.0,364.0), Vector2(973.0,364.0), "top_bar_money")
	elif current_focus == "top_bar_money":
		setup(Vector2(573.0,364.0), Vector2(473.0,364.0), "top_bar_book")
	elif current_focus == "top_bar_book":
		setup(Vector2(473.0,364.0), Vector2(573.0,364.0), "top_bar_clock")
	elif current_focus == "top_bar_clock":
		setup(Vector2(573.0,364.0), Vector2(573.0,364.0), "none")
		hide()
