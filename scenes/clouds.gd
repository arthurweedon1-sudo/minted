extends Control

const SPEED: float = 5.0

func _ready() -> void:
	for cloud in get_children():
		cloud.frame = randi_range(0,4)
		

func _process(delta: float) -> void:
	for cloud in get_children():
		cloud.position.x += SPEED * delta
		if cloud.position.x > 500:
			cloud.position.x = -100
			cloud.frame = randi_range(0,4)
		
		var current_frame = cloud.frame
		if Global.hour >= 20 or Global.hour <= 5:
			cloud.play("night")		
		else:
			cloud.play("sunny")
		
		cloud.frame = current_frame
