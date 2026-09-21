extends Control

@onready var item = $item

# Called when the node enters the scene tree for the first time.

func create_ad(inventory_index):
	item.initialize_item("Ad")
	while Inventory.ad_items.size() <= inventory_index:
		Inventory.ad_items.append({})
		
	var item_val = item.get_data()
	item_val["number"] = 0
	Inventory.ad_items[inventory_index] = item_val
	var data = item.get_data()
	var rng = RandomNumberGenerator.new()
	var ad_effect = snapped(randf_range(1.2,1.4),0.01)
	Inventory.boosted_items_news.append({"type":data["type"], "amount":ad_effect, "time":Global.time_mins})
	#print(Inventory.boosted_items_news)
	
func load_ad(inventory_index):
	if Inventory.ad_items:
		if inventory_index >= 0 and inventory_index < Inventory.ad_items.size():
			item.load_data(Inventory.ad_items[inventory_index])
	else:
		if inventory_index >= 0 and inventory_index < Inventory.ad_items.size():
			item.load_data(Inventory.ad_items[inventory_index])
