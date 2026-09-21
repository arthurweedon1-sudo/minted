class_name SellItemForm
extends Control

signal sell_requested(item_data: Dictionary)

signal page_requested(page_name: String)

const ITEM_UI_SCENE := preload("res://scenes/item_ui.tscn")


const CONDITION_PRICE_MULTIPLIERS := {
	"Poor": 0.4,
	"Satisfactory": 0.6,
	"Good": 0.8,
	"Great": 0.9,
	"Minted": 1.05,
}

var colors: Array = ["black", "grey", "white", "cream", "beige", "apricot", "orange", "coral", "red", "burgundy", "pink", "rose", "purple", "lilac", "light_blue", "blue", "navy", "turquoise", "mint", "green", "dark_green", "khaki", "brown", "mustard", "yellow", "silver", "gold", "multi", "clear"]

var current_condition_text: String = ""
var markup = false

#we can use % for scene unique nodes this is awesome.
@onready var inventory_grid: GridContainer = %InventoryGrid
@onready var item_display: Control = %ItemDisplay
@onready var name_edit: LineEdit = %NameEdit
@onready var type_edit: LineEdit = %TypeEdit
@onready var condition_option: OptionButton = %ConditionOption
@onready var brand_edit: LineEdit = %BrandEdit
@onready var price_edit: LineEdit = %PriceEdit
@onready var description_edit: TextEdit = %DescriptionEdit
@onready var error_label: Label = %ErrorLabel
@onready var color_buttons: Array[Button] = [%ColorButton0, %ColorButton1, %ColorButton2]
@onready var sell_button: Button = %SellButton
@onready var suggest_price_button: Button = %SuggestPriceButton
@onready var stinge_slider: HSlider = %stinge_slider
@onready var stinge_label: Label = %stinge_label

var markup_percentages = [-0.50,-0.20, -0.10, 0.0, 0.10, 0.20,0.50]
var markup_texts = ["-50% (Bargain)", "-20% (Discount)", "-10% (Offer)", "0% (Normal)", "+10% (Markup)", "+20% (Stingy)", "+50% (Greed)"]
var current_markup = 0.0

func _ready() -> void:
	Inventory.item_sold.connect(rebuild_inventory)
	sell_button.pressed.connect(_on_sell_button_pressed)
	suggest_price_button.pressed.connect(_on_suggest_price_pressed)
	condition_option.item_selected.connect(_on_condition_item_selected)
	for button in color_buttons:
		button.toggled.connect(_on_color_button_toggled.bind(button))
	rebuild_inventory()
	if 13 in Global.skill_tree_unlocked:
		%MarkupButton.show()
	else:
		%MarkupButton.hide()


func rebuild_inventory() -> void:
	for child in inventory_grid.get_children():
		child.queue_free()
	for child in item_display.get_children():
		child.queue_free()

	Inventory.current_ui_type = "selling"
	for i in range(Inventory.player_inventory.size()):
		var item_ui = ITEM_UI_SCENE.instantiate()
		item_ui.inventory_index = i
		item_ui.page_requested.connect(_on_item_page_requested)
		inventory_grid.add_child(item_ui)

	Inventory.current_ui_type = "display"
	for i in range(Inventory.display_item.size()):
		var item_ui = ITEM_UI_SCENE.instantiate()
		item_ui.inventory_index = i
		item_ui.page_requested.connect(_on_item_page_requested)
		item_display.add_child(item_ui)


func clear_form() -> void:
	name_edit.clear()
	type_edit.clear()
	brand_edit.clear()
	condition_option.select(-1)
	price_edit.clear()
	description_edit.clear()
	stinge_slider.value = 4.0
	stinge_label.text = "Markup: 0% (Normal)"
	for button in color_buttons:
		button.button_pressed = false
	error_label.text = ""
	current_condition_text = ""
	Inventory.display_item.clear()


func _on_item_page_requested(page_name: String) -> void:
	rebuild_inventory()
	load_uploaded_item_info()
	page_requested.emit(page_name)


func load_uploaded_item_info() -> void:
	if Inventory.display_item.is_empty():
		return

	var item_data: Dictionary = Inventory.display_item[0]
	price_edit.text = ""
	var display_name: String = item_data.get("type", "").replace("_", " ").capitalize()
	name_edit.text = display_name
	type_edit.text = display_name

	var correct_place := randi_range(0, color_buttons.size() - 1)
	for i in range(color_buttons.size()):
		var button := color_buttons[i]
		if i == correct_place:
			button.text = item_data.get("color1", "").capitalize()
		else:
			button.text = str(colors.pick_random()).capitalize()

	if item_data.get("selected_brand", "none") != "none":
		brand_edit.text = item_data.get("selected_brand", "")
	else:
		brand_edit.text = item_data.get("brand", "")


func _on_color_button_toggled(_pressed: bool, active_button: Button) -> void:
	for button in color_buttons:
		if button != active_button:
			button.button_pressed = false


func _on_condition_item_selected(index: int) -> void:
	current_condition_text = condition_option.get_item_text(index)


func _on_suggest_price_pressed() -> void:
	price_edit.text = ""
	if Inventory.display_item.is_empty():
		error_label.text = "Please upload a picture."
		return

	var item: Dictionary = Inventory.display_item[0]
	var condition: String = condition_option.text if condition_option.selected != -1 else item["condition"]
	var price_mult: float = CONDITION_PRICE_MULTIPLIERS.get(condition, 1.0)
	
	var estimate: float = snapped(0.95 * item["brandmult"] * item["pattern_mult"] * price_mult * item["default_price"], 0.01)
	var modifier = 1.0 + markup_percentages[int(stinge_slider.value)]
	estimate = max(snapped(modifier*estimate,0.01),1.00)
	price_edit.text = str(estimate)


func _get_selected_color() -> String:
	for button in color_buttons:
		if button.button_pressed:
			return button.text
	return color_buttons[-1].text


func _on_sell_button_pressed() -> void:
	var price_written: float = 0.0
	if price_edit.text.is_valid_float():
		price_written = snapped(price_edit.text.to_float(), 0.01)

	if name_edit.text == "":
		error_label.text = "Need a name!"
	elif not price_edit.text.is_valid_float():
		error_label.text = "Price is not valid (do not include $)."
	elif price_written < 1:
		error_label.text = "Price must be at least $1."
	elif price_written >= 10000:
		error_label.text = "Price must be under $10,000."
	elif condition_option.selected == -1:
		error_label.text = "Please select a condition."
	elif Inventory.display_item.is_empty():
		error_label.text = "Please upload a picture."
	elif Inventory.player_selling.size() >= 10:
		error_label.text = "Cannot sell any more items."
	else:
		_submit_listing(price_written)


func _submit_listing(price_written: float) -> void:
	if current_condition_text == "":
		current_condition_text = condition_option.get_item_text(condition_option.selected)

	var color = _get_selected_color()
	var color1 = ""
	var color2 = ""
	var color_parts := color.split(" ")
	if color_parts.size() >= 3:
		for part in color_parts.duplicate():
			if part == "+" or part == "&" or part.to_lower() == "and":
				color_parts.erase(part)
	if color_parts.size() == 2:
		color1 = color_parts[0]
		color2 = color_parts[1]
	elif color_parts.size() == 1:
		color1 = color_parts[0]
		color2 = "none"

	var item_data: Dictionary = {
		"name": name_edit.text,
		"type": type_edit.text,
		"condition": current_condition_text,
		"color": color,
		"color1": color1,
		"color2": color2,
		"price": price_written,
		"brand": brand_edit.text,
		"description": description_edit.text,
		"markup": markup
	}
	
	if markup:
		markup = false
		Global.markup_progress = 0 
		%MarkupButton.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		
	sell_requested.emit(item_data)


func _on_stinge_slider_value_changed(value: float) -> void:
	var index = int(value)
	stinge_label.text = "Markup: " + markup_texts[index]
	
	if Inventory.display_item.size() >= 1:
		_on_suggest_price_pressed()

func _process(_delta: float) -> void:
	%ProgressBar.value = min(Global.markup_progress,100)
	if Global.markup_progress < 100:
		%MarkupButton.text = ""
		%ProgressBar.show()
	else:
		%ProgressBar.hide()
		%MarkupButton.text = "Markup"
	
	if 13 in Global.skill_tree_unlocked:
		%MarkupButton.show()
	else:
		%MarkupButton.hide()


func _on_markup_button_pressed() -> void:
	if Global.markup_progress >= 100:
		markup = !markup
		
		if markup:
			%MarkupButton.self_modulate = Color(0.953, 0.949, 0.286, 1.0)
		else:
			%MarkupButton.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	
