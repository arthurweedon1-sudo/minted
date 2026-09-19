extends Control

@onready var ui_element = preload("res://scenes/item_ui.tscn")
@onready var tab_container = $Mintora/VBoxContainer/Control3/TabContainer


func show_page(page_name: String) -> void:
	for i in range(tab_container.get_tab_count()):
		if tab_container.get_tab_title(i) == page_name or tab_container.get_child(i).name == page_name:
			tab_container.current_tab = i
			return

func _on_button_pressed() -> void:
	show_page("Market")

func generate_items(grid: HFlowContainer, category: String, amount: int):
	Inventory.current_ui_type = "market"
	var packed = preload("res://scenes/item_ui.tscn")
	
	for child in grid.get_children():
		child.queue_free()
	
	if not Inventory.market_items.has(category):
		Inventory.market_items[category] = []
		for i in range(amount):
			var item_ui = packed.instantiate()
			grid.add_child(item_ui)
			item_ui.get_node("item").initialize_item(category)
			item_ui.market_type = category
			Inventory.market_items[category].append(item_ui.get_data())
	else:
		for data in Inventory.market_items[category]:
			var item_ui = packed.instantiate()
			item_ui.market_type = category
			grid.add_child(item_ui)
			item_ui.get_node("item").load_data(data)
			
func _ready():
	Global.mintora = true
	$Mintora/VBoxContainer/Control3/TabContainer/Selling/selling.page_requested.connect(show_page)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/All/ScrollContainer/GridContainer, "All", 12)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Clothes/ScrollContainer/GridContainer, "Clothes", 12)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Toys/ScrollContainer/GridContainer, "Toys", 12)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Home/ScrollContainer/GridContainer, "Home", 12)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Electronics/ScrollContainer/GridContainer, "Electronics", 12)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/BooksMedia/ScrollContainer/GridContainer, "BooksMedia", 12)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Collectables/ScrollContainer/GridContainer, "Collectables", 12)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Sports/ScrollContainer/GridContainer, "Sports", 12)
	
	if Inventory.bidding_items.size() == 0:
		for i in range(4):
			var packed = preload("res://scenes/item_ui.tscn")
			var item_ui = packed.instantiate()
			$".".add_child(item_ui)
			item_ui.get_node("item").initialize_item("Bidding")
			Inventory.bidding_items.append(item_ui.get_data())
			Inventory.create_bidding_details(Inventory.bidding_items.size()-1)
				
			item_ui.queue_free()
	
	if Global.articles.size() == 0:
		for i in range(2):
			var index = 0
			var packed = preload("res://scenes/article.tscn")
			var storage_ui = packed.instantiate()
			$".".add_child(storage_ui)
			storage_ui.article_index = index
			index += 1
			Global.articles.append(storage_ui.article_chosen)
			
			storage_ui.queue_free()
		
		Global.articles.append(null)
				
		var packed = preload("res://scenes/article.tscn")
		var storage_ui = packed.instantiate()
		storage_ui.article_index = 0
		add_child(storage_ui)
			
		Global.articles[0] = storage_ui.article_chosen
			
		storage_ui.queue_free()
			
	
	if Global.articles.size() >= 3:
		Global.articles.pop_at(2)
	SignalBus.articles_changed.emit()
	Global.news_interest = 1
	
func reload_market():
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/All/ScrollContainer/GridContainer, "All", 15)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Clothes/ScrollContainer/GridContainer, "Clothes", 15)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Toys/ScrollContainer/GridContainer, "Toys", 15)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Home/ScrollContainer/GridContainer, "Home", 15)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Electronics/ScrollContainer/GridContainer, "Electronics", 15)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/BooksMedia/ScrollContainer/GridContainer, "BooksMedia", 15)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Collectables/ScrollContainer/GridContainer, "Collectables", 15)
	generate_items($Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer2/VBoxContainer/Sections/Centre/TabContainer/Sports/ScrollContainer/GridContainer, "Sports", 15)
