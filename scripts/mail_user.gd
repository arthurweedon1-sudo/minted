extends Control

@onready var button: Button = $Button
@onready var title_text = $Button/PanelContainer/VBoxContainer/NamenTime
@onready var shipping_status_container = get_node("/root/MainUI/Mintora/VBoxContainer/Control3/TabContainer/Mail/Mail/VBoxContainer/Sections/MarginContainer2/Control3/ScrollContainer/Message")

static var shipping_button_group := ButtonGroup.new()

var shipping_entry = null
var estimated_hours = 0
var timer = 1

func _ready() -> void:
	title_text.text = ("SDS - Shippley Delivery Service  =  " + str(Global.hour) + ":" + str(Global.min))
	button.toggle_mode = true
	button.button_group = shipping_button_group

func _process(delta: float) -> void:
	if shipping_entry == null:
		return
	var progress = ShippingHandler.get_progress(shipping_entry)
	print(progress)
	estimated_hours = (progress["total_time"]* 24 * (1 - progress["percentage"] / 100))
	if estimated_hours <= 0 and timer > 0:
		timer -= delta
	elif estimated_hours <= 0:
		queue_free()

func find_parent_index(value) -> int:
	for i in range(ShippingHandler.mail_user_list.size()):
		if value in ShippingHandler.mail_user_list[i]:
			return i
	return -1

func _on_button_pressed() -> void:
	var parent_index := find_parent_index(self)

	if parent_index == -1:
		return

	var node_to_show = ShippingHandler.mail_user_list[parent_index][1]
	show_only(node_to_show)

func show_only(node_to_show: Control) -> void:
	for child in shipping_status_container.get_children():
		child.visible = false

	node_to_show.visible = true

	var selected_button := node_to_show.get_node_or_null("Button") as Button
	if selected_button:
		selected_button.button_pressed = true
