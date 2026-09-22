extends Sprite2D

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.hour >= 22 or Global.hour <= 5:
		$light.show()
	else:
		$light.hide()
