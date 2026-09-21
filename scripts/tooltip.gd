extends Control

signal visibility_toggled(is_visible, target)

@export var tooltip_offset := Vector2(-150, 0)
@onready var area = $mouse_hitbox
@onready var panel = $mouse_hitbox/TooltipPanel
@onready var name_label = $mouse_hitbox/TooltipPanel/container/item_name
@onready var condition_bar = $mouse_hitbox/TooltipPanel/container/condition_bar
@onready var condition_label = $mouse_hitbox/TooltipPanel/container/condition_text
@onready var brand_icon = $mouse_hitbox/TooltipPanel/container/brand/brand_icon
@onready var brand_label = $mouse_hitbox/TooltipPanel/container/brand/brand_name
@onready var brand_text = $mouse_hitbox/TooltipPanel/container/brand/brand_text
@onready var color1_tag = $mouse_hitbox/TooltipPanel/tags2/color_tag/color1_tag
@onready var color2_tag = $mouse_hitbox/TooltipPanel/tags2/color_tag/color2_tag
@onready var money_label = $mouse_hitbox/TooltipPanel/container/money/money_text
@onready var stars = $mouse_hitbox/TooltipPanel/rating/Stars
@onready var seller_label = $mouse_hitbox/TooltipPanel/rating/sellerName_text
@onready var seller_container = $mouse_hitbox/TooltipPanel/rating/seller_container
@onready var tag_info = $mouse_hitbox/TooltipPanel/tag_info
@onready var tag_text = $mouse_hitbox/TooltipPanel/tag_info/Label
@onready var tag_container = $mouse_hitbox/TooltipPanel/tags2
@onready var info_container = $mouse_hitbox/TooltipPanel/container
@onready var rating_container: Control = $mouse_hitbox/TooltipPanel/rating
@onready var money_trend = %money_trend
@onready var code = $mouse_hitbox/TooltipPanel/code/sellerName_text

var current_target = null
var initial_y = 0

var weight = ""
var extra_tag = ""
var info = ""

func _ready():
	panel.hide()
	panel.z_index = 5

func _process(_delta: float) -> void:
	update_position()

func update_position():
	if current_target == null:
		return
	if not panel.visible:
		panel.global_position.y = current_target.global_position.y
	
func show_tooltip(target):
	if current_target == target and panel.visible:
		return
		
	$mouse_hitbox/TooltipPanel/container/shipping.show()
	tag_info.hide()
	$mouse_hitbox/TooltipPanel/tags2/extra_info.show()
	$mouse_hitbox/TooltipPanel/tags2/extra_info/extra_tag.play("default")
	current_target = target
	
	var item = target.get_data()
	info = item
	code.text = item.code
	name_label.text = str(name_generator(item))
	condition_bar.play(str(item.condition).to_lower())
	condition_label.text = "Condition: " + str(item.condition)
	brand_icon.play(str(item.brand).to_lower())
	brand_label.text = str(item.brand)
	color1_tag.play(str(item.color1).to_lower())
	if str(item.color2).to_lower() == "":
		color2_tag.hide()
	else:
		color2_tag.play(str(item.color2).to_lower())
		color2_tag.show()

	money_label.text = str(item.price)
	stars.set_item(target)
	seller_label.text = str(item.seller_name)
	
	if Global.on_market:
		rating_container.show()
	else:
		rating_container.hide()
	
	if item.item_category[0]:
		$mouse_hitbox/TooltipPanel/tags2/item_type/type_tag.play(item.item_category[0].to_lower())
	if item.cd:
		$mouse_hitbox/TooltipPanel/tags2/extra_info/extra_tag.play("music")
		extra_tag = "cd"
	elif item.poster:
		$mouse_hitbox/TooltipPanel/tags2/extra_info/extra_tag.play("poster")
		extra_tag = "poster"
	elif item.placeable:
		$mouse_hitbox/TooltipPanel/tags2/extra_info/extra_tag.play("placeable")
		extra_tag = "placeable"
	elif item.item_category.size() == 2:
		$mouse_hitbox/TooltipPanel/tags2/extra_info/extra_tag.play(item.item_category[1].to_lower())
		extra_tag = item.item_category[1].to_lower()
	else:
		$mouse_hitbox/TooltipPanel/tags2/extra_info.hide()
		
	if item.shippingValue == 1:
		$mouse_hitbox/TooltipPanel/tags2/item_weight/weight_tag.play("light")
	elif item.shippingValue == 2:
		$mouse_hitbox/TooltipPanel/tags2/item_weight/weight_tag.play("medium")
	elif item.shippingValue == 3:
		$mouse_hitbox/TooltipPanel/tags2/item_weight/weight_tag.play("heavy")
	elif item.shippingValue >= 4:
		$mouse_hitbox/TooltipPanel/tags2/item_weight/weight_tag.play("xl")
		
	if item.cd:
		brand_text.text = "Genre:"
		brand_label.text = item.genre
		brand_icon.play(str(item.spice_factor))
	
	if Global.on_market:
		$mouse_hitbox/TooltipPanel/container/shipping.show()
		$mouse_hitbox/TooltipPanel/container/money.show()
		$mouse_hitbox/TooltipPanel/container/shipping/shipping_time.text = str(item.shippingTime) + " Days"
		var boosts = 0
		var overall_boost = 1
		for news in Inventory.boosted_items_news:
			if news["type"] == item["type"]:
				boosts += 1
				overall_boost *= news["amount"]
		if boosts == 0:
			money_trend.play("neutral")
		elif overall_boost >= 1.1:
			money_trend.play("upwards")
		elif overall_boost <= 0.9:
			money_trend.play("downwards")	
	else:
		$mouse_hitbox/TooltipPanel/container/shipping.hide()
		$mouse_hitbox/TooltipPanel/container/money.hide()

	panel.show()
	panel.reset_size()
	visibility_toggled.emit(true, target)

	var vp_size = get_viewport().get_visible_rect().size
	var panel_width = max(panel.size.x, panel.custom_minimum_size.x)
	if panel_width <= 0:
		panel_width = 400.0

	var pos = target.global_position + Vector2(target.size.x + tooltip_offset.x, tooltip_offset.y)

	if pos.x + panel_width > vp_size.x:
		pos.x = target.global_position.x - panel_width - tooltip_offset.x - 70
		tag_container.position = Vector2(17, 16)
		info_container.position = Vector2(168, 38)
		$mouse_hitbox/TooltipPanel/code.position = Vector2(-153,190)
	else:
		tag_container.position = Vector2(447, 12)
		info_container.position = Vector2(278, 38)
		$mouse_hitbox/TooltipPanel/code.position = Vector2(139,190)

	var panel_height = max(panel.size.y, panel.custom_minimum_size.y)
	if pos.y + panel_height > vp_size.y:
		pos.y = target.global_position.y - panel_height - tooltip_offset.y
		initial_y = pos.y

	panel.global_position = pos

func hide_tooltip(target: Control):
	panel.hide()
	visibility_toggled.emit(false, target)
	current_target = null
	
func name_generator(data) -> String:
	var brand_print = ""
	var display_color = data["color1"]
	var display_color2 = data["color2"]
	
	var display_type = data["type"]
	var brand = data["brand"]
	var type = data["type"]
	
	if brand != "none":
		brand_print = brand.capitalize() + " "
	elif brand == "none":
		display_color = display_color.capitalize()
	if type == "cd_player":
		display_type = "CD Player"
	elif type == "puzzle_cube":
		display_type = "Puzzle Cube"
		display_color = ""
	elif type == "spud_poster":
		display_type = "Spud Poster"
		display_color = ""
	elif type == "potion_poster":
		display_type = "Potion Poster"
		display_color = ""
	elif type == "beh_enclosed_shirt":
		display_type = "BEH Enclosed shirt"
		display_color = ""
	elif type == "the_big_mint":
		display_type = "The Big Mint CD"
		display_color = ""
	elif type == "smooth_jazz_1":
		display_type = "Smooth Jazz Vol.1 CD"
		display_color = ""
	elif type == "three_jelly":
		display_type = "Three Jelly CD"
		display_color = ""
	elif type == "evil_pulsation":
		display_type = "Evil Pulsation CD"
		display_color = ""
	elif type == "jungle":
		display_type = "Jungle CD"
		display_color = ""
	elif type == "conceal_shoes":
		display_type = "shoes"
	elif type == "gold_ring":
		display_color = ""
		display_type = "Gold Ring"
	elif type == "red_nose_pop":
		display_type = "Red Nose Pop CD"
		display_color = ""
		display_color2 = ""
	elif type == "encyclopedia":
		display_type = "Encyclopedia"
		display_color = ""
		display_color2 = ""
	elif type == "brickies_family_house":
		display_type = "Family House"
		display_color = ""
		display_color2 = ""
		
	if data["overlay_animation"] == "ele_minimalistic_white" or data["overlay_animation"] == "ele_minimalistic_black":
		brand_print = "elemental minimalistic "
	
	if display_color2 != "" and display_color != "" and data["pattern_type"] != "none":
		return brand_print + display_color + " & " + display_color2.capitalize() + " " +  data["pattern_type"] + " " + display_type + "."
	elif display_color2 != "" and display_color != "":
		return brand_print + display_color + " & " + display_color2.capitalize() + " " + display_type + "."
	else:
		return brand_print + display_color + " " + display_type + "."

func _on_hitbox_focus_exited() -> void:
	hide_tooltip(self)

func _on_mouse_entered() -> void:
	tag_info.show()
	if info.color2 != "":
		tag_text.text = "This item is " + info.color1 + "and " + info.color2 + "."
	else:
		tag_text.text = "This item is " + info.color1 + "."

func _on_mouse_exited() -> void:
	tag_info.hide()

func _on_color_tag_mouse_entered() -> void:
	tag_info.show()
	if info.color2 != "":
		tag_text.text = "This item is " + info.color1 + " and " + info.color2 + "."
	else:
		tag_text.text = "This item is " + info.color1 + "."

func _on_color_tag_mouse_exited() -> void:
	pass
