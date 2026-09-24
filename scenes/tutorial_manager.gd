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
	setup(Vector2(673.0,364.0), Vector2(673.0,364.0), "top_bar")

func focus_changer():
	if current_focus == "top_bar":
		setup(Vector2(673.0,364.0), Vector2(473.0,364.0), "top_bar_level")
	elif current_focus == "top_bar_level":
		setup(Vector2(473.0,364.0), Vector2(473.0,364.0), "top_bar_money")
	elif current_focus == "top_bar_money":
		setup(Vector2(473.0,364.0), Vector2(473.0,364.0), "top_bar_book")
	elif current_focus == "top_bar_book":
		setup(Vector2(473.0,364.0), Vector2(833.0,364.0), "top_bar_clock")
	elif current_focus == "top_bar_clock":
		setup(Vector2(833.0,364.0), Vector2(700.0,550.0), "sleep_meter")
	elif current_focus == "sleep_meter":
		setup(Vector2(700.0,500.0), Vector2(673.0,364.0), "rent_slip")
	elif current_focus == "rent_slip":
		setup(Vector2(673.0,364.0), Vector2(973.0,464.0), "computer")
	elif current_focus == "computer":
		setup(Vector2(973.0,464.0), Vector2(273.0,364.0), "storage")
	elif current_focus == "storage":
		setup(Vector2(273.0,464.0), Vector2(573.0,364.0), "shelf")
	elif current_focus == "shelf":
		setup(Vector2(573.0,464.0), Vector2(373.0,564.0), "bed")
	elif current_focus == "bed":
		setup(Vector2(373.0,464.0), Vector2(773.0,364.0), "poster")
	elif current_focus == "poster":
		setup(Vector2(773.0,464.0), Vector2(900.0,364.0), "door")
	elif current_focus == "door":
		setup(Vector2(900.0,464.0), Vector2(873.0,364.0), "none")
		hide()
	
