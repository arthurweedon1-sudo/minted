extends Control

var mail_user_scene = preload("res://scenes/mail_user.tscn")
var shipping_status = preload("res://scenes/shipping_status.tscn")
@onready var user_container = $VBoxContainer/Sections/MarginContainer/ScrollContainer/Users
@onready var message_container = $VBoxContainer/Sections/MarginContainer2/Control3/ScrollContainer/Message

func _ready():
	Inventory.current_ui_type = "shipping"
	Global.create_mail.connect(_on_create_mail)
	for child in user_container.get_children():
		child.queue_free()
	for child in message_container.get_children():
		child.queue_free()
	for entry in ShippingHandler.shipping_list:
		for i in range (len(ShippingHandler.shipping_list)):
			_on_create_mail(entry, i)

func _on_create_mail(entry = null, index = 0):
	Inventory.current_ui_type = "shipping"
	if entry == null and not ShippingHandler.shipping_list.is_empty():
		entry = ShippingHandler.shipping_list[-1]
	var mail = mail_user_scene.instantiate()
	user_container.add_child(mail)
	var messages = [shipping_status.instantiate()]
	messages[index].shipping_entry = entry
	message_container.add_child(messages[index])
	ShippingHandler.mail_user_list.append([mail, messages])
