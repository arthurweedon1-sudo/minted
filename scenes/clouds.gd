extends Control

const SPEED: float = 5.0

func _ready() -> void:
	for cloud in get_children():
		cloud.play(str(randi_range(1, 3)))


func _process(delta: float) -> void:
	for cloud in get_children():
		cloud.position.x += SPEED * delta
		if cloud.position.x > 500:
			cloud.position.x = -100
