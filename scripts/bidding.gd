extends Control

@onready var progress = $Button/TextureProgressBar 
@onready var bidding_display = $Bidding/GridContainer
func _build_page():
	Inventory.current_ui_type = "display_bidding"
	for child in bidding_display.get_children():
		bidding_display.remove_child(child)
		child.queue_free()
	for i in range(Inventory.bidding_items.size()):
		var packed = preload("res://scenes/bidding_ui.tscn")
		var storage_ui = packed.instantiate()
		storage_ui.item_index = i
		bidding_display.add_child(storage_ui)
 
 
func _on_tree_entered() -> void:
	call_deferred("_build_page")
	Inventory.bid_done.connect(_build_page)

func _process(delta: float) -> void:
	if Global.refreshProgress >= 100:
		progress.hide()
	else:
		progress.show()

	progress.value = min(Global.refreshProgress,100)


func _on_button_pressed() -> void:
	if Global.refreshProgress >= 100:
		Global.refreshProgress = 0
		Global.rent_broadband += 0.02 * Global.rent_broadband_mult
		Inventory.bidding_items = []
		Inventory.bidding_details = [{},{},{},{}]
		Inventory.bidders = []
		
		for i in range(4):
			var packed = preload("res://scenes/item_ui.tscn")
			var item_ui = packed.instantiate()
			$".".add_child(item_ui)
			item_ui.get_node("item").initialize_item("Bidding")
			Inventory.bidding_items.append(item_ui.get_data())
			Inventory.create_bidding_details(Inventory.bidding_items.size()-1)
				
			item_ui.queue_free()
		_build_page()
