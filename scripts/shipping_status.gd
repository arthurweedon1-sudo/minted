extends Control

@onready var info_label = $PanelContainer/VBoxContainer/Info/Status_text
@onready var stages_image = $PanelContainer/VBoxContainer/Stages_image
@onready var estimate = $PanelContainer/VBoxContainer/Estimate/Estimate_text
@onready var container = $PanelContainer
@onready var item_display = $item_UI
var estimated_hours = 0
var timer = 3
var shipping_entry = null

func _ready() -> void:
	visible = false
	if shipping_entry:
		item_display.code = shipping_entry[0]["code"]
		item_display.load_data(shipping_entry[0])

func _process(delta: float) -> void:
	if shipping_entry == null:
		return
	var progress = ShippingHandler.get_progress(shipping_entry)
	info_label.text = "Your parcel is " + progress["status"]
	stages_image.frame = progress["stage_image"]
	estimated_hours = progress["total_time"] * 24 * (1 - progress["percentage"] / 100)
	if estimated_hours > 0:
		estimate.text = "Estimated delivery time - " + str(int(round(estimated_hours))) + " hours"
	elif estimated_hours > -1 and timer > 0:
		timer -= delta
		estimate.text = "Parcel has delivered."
	else:
		pass

func show_only(node_to_show: Control):
	for child in $Container.get_children():
		child.visible = false

	node_to_show.visible = true
