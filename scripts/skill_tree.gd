extends Control

var data = []
@onready var grid = $SkillTreeContainer
@onready var title = get_node("/root/ActionPopup/CanvasLayer/info/title")
@onready var description = get_node("/root/ActionPopup/CanvasLayer/info/description")
@onready var price2 = get_node("/root/ActionPopup/CanvasLayer/info/price2")
@onready var price = get_node("/root/ActionPopup/CanvasLayer/info/price")
@onready var info = get_node("/root/ActionPopup/CanvasLayer/info")
var current_id = 0
var dragging: bool = false
var tweening = Tween
var zoom_tween = Tween
var current_zoom = 1
@onready var offset = Vector2(0,0)
@export var line_color: Color = Color.BLUE_VIOLET
@export var locked_line_color = Color.LIGHT_STEEL_BLUE
@export var line_width: float = 5.0

func load_json_file(file_path: String) -> Variant:
	if FileAccess.file_exists(file_path):
		var data_file = FileAccess.open(file_path, FileAccess.READ)
		var parsed_data = JSON.parse_string(data_file.get_as_text())
		data_file.close()
		return parsed_data
	else:
		print("file does not exist!")
		return null

func _load_page() -> void:
	for child in grid.get_children():
		child.queue_free()
		
	data = load_json_file("res://dialogue/skill_tree.json")
	for i in range(data.size()):
		var packed = preload("res://scenes/skill_tree_ui.tscn")
		var storage_ui = packed.instantiate()
		storage_ui.index = i
		storage_ui.name = str(int(data[i]["id"]))
		grid.add_child(storage_ui) 
		storage_ui.load_data(i)
	
	# draw lines
	for i in range(data.size()):
			var item = data[i]
			if "requirements" in item and item["requirements"] is Array:
				var current_id = str(int(item["id"]))
				var current_node = grid.get_node_or_null(current_id)

				for req_id in item["requirements"]:
					var parent_id = int(req_id)
					var parent_node = grid.get_node_or_null(str(parent_id))
					var unlocked = false
					
					if parent_id in Global.skill_tree_unlocked:
						unlocked = true
					if parent_node and current_node:
						create_connection_line(parent_node, current_node, unlocked)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.show_skill.connect(_show_skill)
	SignalBus.skill_bought.connect(on_buy_pressed)
	_load_page()
	$background2.self_modulate =Color(1,1,1,0.5)

func create_connection_line(node_a: Control, node_b: Control, unlocked: bool) -> void:
	var line = Line2D.new()
	line.width = line_width
	if unlocked:
		line.default_color = line_color
		line.default_color.a = 0.6
		if node_a.name == "4" and node_b.name == "12" or node_a.name == "15" and node_b.name == "19":
			line.default_color = Color(0.371, 0.5, 0.847, 1.0)
		line.default_color.a = 0.6
	else:
		line.default_color = locked_line_color
		line.default_color.a = 0.3
		if node_a.name == "21" and node_b.name == "13" or node_a.name == "21" and node_b.name == "20":
			line.default_color = Color(0.076, 0.238, 0.366, 1.0)
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_BOX
	var start_pos = node_a.position + (node_a.size / 2.0)
	var end_pos = node_b.position + (node_b.size / 2.0)

	line.add_point(start_pos)
	line.add_point(end_pos)

	grid.add_child(line)
	grid.move_child(line, 0)
# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_close_pressed() -> void:
	info.hide()
	for child in grid.get_children():
		if !child is Line2D:
			child.hide_selected()
	

func _show_skill(data2, bought):
	for child in grid.get_children():
		if !child is Line2D:
			child.hide_selected()
	current_id = int(data2["id"])
	info.show()
	get_node("/root/ActionPopup/CanvasLayer/info/Buy").show()
	price2.show()
	price.show()
	if data2["name"] == "Locked":
		get_node("/root/ActionPopup/CanvasLayer/info/Buy").hide()
		price2.hide()
		price.hide()
	title.text = data2["name"]
	description.text = data2["desc"]
	price2.text = str(data2["price"])
	if bought:
		price2.hide()
		price.hide()
		get_node("/root/ActionPopup/CanvasLayer/info/Buy").hide()
		
	
	var selected_node = grid.get_node_or_null(str(current_id))
	if selected_node:
		center_on_node(selected_node)

func center_on_node(target_node: Control) -> void:
	var node_center = target_node.position + (target_node.size / 2.0)

	var node_scaled_center = node_center * grid.scale

	var screen_center = get_viewport_rect().size / 2.0
	var target_grid_position = screen_center - node_scaled_center
	
	var tween = create_tween()
	target_grid_position.x = clamp(target_grid_position.x, 550, 1350.0)
	tween.tween_property(grid, "position", target_grid_position/1.1, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	await tween.finished

func on_buy_pressed() -> void:
	print("ahh")
	var current_price = data[current_id]["price"]
	if Global.money >= current_price:
		Global.skill_tree_unlocked.append(current_id)
		Global.money -= current_price
		_on_close_pressed()
		_load_page()
		buy_skill(data[current_id]["effect"])
	

func buy_skill(effect):
	print(effect)
	if effect == "money_store_1":
		Global.max_investment = 200
	elif effect == "money_store_2":
		Global.max_investment = 500
	elif effect == "money_store_3":
		Global.max_investment = 10000
	elif effect == "better_interest":
		Global.interest_boost += 1.01
	elif effect == "loan_shark_1" or effect == "loan_shark_2":
		Global.loan_mult -= 0.1
	elif effect == "strong_hands":
		Inventory.player_max += 1
	elif effect == "maore_likeable":
		Global.likability_score *= 0.9
	elif effect == "shelf_upgrade_2":
		Inventory.shelf_max += 1
		Inventory.levels["shelf"] = 2
	elif effect == "shelf_upgrade_3":
		Inventory.shelf_max += 2
		Inventory.levels["shelf"] = 3
	elif effect == "shelf_upgrade_4":
		Inventory.shelf_max += 3
		Inventory.levels["shelf"] = 4	
	elif effect == "upgrade_wardrobe_2":
		Inventory.wardrobe_max += 4
		Inventory.levels["wardrobe"] = 2
	elif effect == "upgrade_wardrobe_3":
		Inventory.wardrobe_max += 4
		Inventory.levels["wardrobe"] = 3
	elif effect == "upgrade_wardrobe_4":
		Inventory.wardrobe_max += 6
		Inventory.levels["wardrobe"] = 4
	elif effect == "sleep_upgrade_2":
		Inventory.levels["bed"] = 2
		Global.sleep_mult *= 1.1
	elif effect == "sleep_upgrade_3":
		Inventory.levels["bed"] = 3
		Global.sleep_mult *= 1.1	
	elif effect == "computer_upgrade_2":
		Inventory.levels["computer"] = 2
		Global.items_computer = 15	
		Global.REFRESHTIME = 5*60 # had to make this not a constant, lol
	elif effect == "computer_upgrade_3":
		Inventory.levels["computer"] = 3
		Global.items_computer = 18
		Global.REFRESHTIME = 4*60
		Global.rent_broadband_mult *= 0.8
	elif effect == "uncommon_snatcher":
		Global.uncommon_frequency = 1.2
	elif effect == "faster_deliveries_2" or effect == "faster_deliveries_1":
		Global.delivery_speed_mult -= 0.1
									
func _on_dragging_button_button_up() -> void:
	dragging = false
	
func _on_dragging_button_button_down() -> void:
	dragging = true
	offset = get_global_mouse_position() - grid.position

func _process(delta: float) -> void:
	if dragging:
		# Update the grid container directly
		var target_pos = get_global_mouse_position() - offset
		grid.position.x = clamp(target_pos.x, 550, 1350.0)
		grid.position.y = max(target_pos.y, -3000.0)

@export var zoom_step: float = 0.25
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

func _on_zoom_out_pressed() -> void:
	_adjust_zoom(-zoom_step)

func _on_zoom_in_pressed() -> void:
	_adjust_zoom(zoom_step)

func _adjust_zoom(amount: float) -> void:
	var old_zoom = current_zoom
	current_zoom = clamp(current_zoom + amount, min_zoom, max_zoom)
	
	if old_zoom == current_zoom:
		return

	var screen_center = get_viewport_rect().size / 2.0
	var focus_offset = screen_center - grid.position
	var new_position = screen_center - (focus_offset * (current_zoom / old_zoom))

	var zoom_tween = create_tween().set_parallel(true)
	zoom_tween.tween_property(grid, "scale", Vector2(current_zoom, current_zoom), 0.25)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	zoom_tween.tween_property(grid, "position", new_position, 0.25)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
