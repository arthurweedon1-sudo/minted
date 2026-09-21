extends Control
@onready var grid = $items/ScrollContainer/GridContainer
var previous_delivered_size = 0
var previous_inventory_size = 0

func _ready() -> void:
	$Outside/CanvasLayer.hide()
	Global.inShelf = false
	Global.inWardrobe = true
	Global.inLocker = true
	load_list_objects()
	previous_delivered_size = ShippingHandler.locker_list.size()
	previous_inventory_size = Inventory.player_inventory.size()

func _process(_delta: float) -> void:
	if ShippingHandler.locker_list.size() != previous_delivered_size or Inventory.player_inventory.size() != previous_inventory_size:
		previous_delivered_size = ShippingHandler.locker_list.size()
		previous_inventory_size = Inventory.player_inventory.size()
		load_list_objects()

func _on_close_pressed() -> void:
	Global.inWardrobe = false
	Global.inLocker = false
	get_tree().change_scene_to_file("res://scenes/outside.tscn")

func load_list_objects() -> void:
	for child in grid.get_children():
		child.queue_free()
	await get_tree().process_frame
	Inventory.current_ui_type = "parcel"
	for i in range(ShippingHandler.locker_list.size()):
		var storage_ui = preload("res://scenes/item_ui.tscn").instantiate()
		storage_ui.inventory_index = i
		storage_ui.update_type()
		storage_ui.is_parcel = true
		grid.add_child(storage_ui)
