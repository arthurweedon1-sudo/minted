extends Control

@onready var selected = %TabContainer
@onready var progress = $Button/TextureProgressBar

@onready var grids: Dictionary = {
	"All": %All/ScrollContainer/GridContainer,
	"Clothes": %Clothes/ScrollContainer/GridContainer,
	"Toys": %Toys/ScrollContainer/GridContainer,
	"Electronics": %Electronics/ScrollContainer/GridContainer,
	"Home": %Home/ScrollContainer/GridContainer,
	"BooksMedia": %BooksMedia/ScrollContainer/GridContainer,
	"Collectables": %Collectables/ScrollContainer/GridContainer,
	"Sports": %Sports/ScrollContainer/GridContainer
}

var packed = preload("res://scenes/item_ui.tscn")

func _ready() -> void:
	Global.inShelf = false
	Global.inWardrobe = false
	SignalBus.refresh_market.connect(reload_page)

func _on_button_pressed() -> void:
	var category = Inventory.current_market_type
	if category != "" and Global.refreshProgress >= 100:
		Inventory.current_ui_type = "market"
		Inventory.market_items[category] = []
		progress.value = 0
		Global.refreshProgress = 0
		Global.rent_broadband += 0.02 * Global.rent_broadband_mult
		Inventory.refresh_buyers_market(category)

		if grids.has(category):
			var grid = grids[category]
			for child in grid.get_children():
				child.queue_free()

			for i in range(Global.items_computer):
				var item_ui = packed.instantiate()
				grid.add_child(item_ui)
				item_ui.get_node("item").initialize_item(category)
				item_ui.market_type = category
				Inventory.market_items[category].append(item_ui.get_data())

func _on_tab_container_tab_selected(tab: int) -> void:
	if selected:
		Inventory.current_market_type = selected.get_tab_title(tab)
		Tooltip.hide()

func _process(_delta: float) -> void:
	if Global.refreshProgress >= 100:
		progress.hide()
	else:
		progress.show()

	progress.value = min(Global.refreshProgress, 100)

func generate_items(grid: GridContainer, category: String) -> void:
	Inventory.current_ui_type = "market"
	for child in grid.get_children():
		child.queue_free()

	if not Inventory.market_items.has(category):
		return

	for data in Inventory.market_items[category]:
		var item_ui = packed.instantiate()
		item_ui.market_type = category
		grid.add_child(item_ui)
		item_ui.get_node("item").load_data(data)

func reload_page(category) -> void:
	if grids.has(category):
		generate_items(grids[category], category)
