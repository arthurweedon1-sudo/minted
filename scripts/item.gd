extends Node2D

var colours: Array = ["white","yellow", "red", "green", "blue", "black", "purple", "pink", "cyan", "orange"]
var tshirt_colours: Array = ["white","yellow", "red", "green", "blue", "black", "purple", "pink", "cyan", "orange",
"apricot","turquoise","forest","coral","navy","rose","brown","burgundy","mint","lilac"]
var trouser_colours: Array = ["white", "black", "grey", "blue", "green"]
var conceal_colours: Array = ["white","red","green","pink","black","blue"]
var common_items: Array = ["tshirt","socks","trousers","shorts", "shoes","boxers", "smooth_jazz_1", "football","basketball","playing_cards","brickies_family_house", "banana_poster", "smooth_jazz_2"]
var uncommon_items: Array = ["cd_player", "puzzle_cube", "spud_poster","potion_poster", "camera", "three_jelly","conceal_shoes","flip_flops","radio","polo_shirt"]
var rare_items: Array = ["the_big_mint", "evil_pulsation", "jungle","christmas_lights","encyclopedia","sliver_ring"]
var epic_items: Array = ["beh_enclosed_shirt","red_nose_pop"]
var legendary_items: Array = ["gold_ring"]
var all_items: Array = common_items + uncommon_items + rare_items + epic_items + legendary_items
var items_with_regular_animation = ["cd_player", "puzzle_cube", "camera", "gold_ring", "radio", "the_big_mint", "smooth_jazz_1", "three_jelly", "evil_pulsation", "jungle", "red_nose_pop","encyclopedia"]
var items_that_spin = ["the_big_mint", "smooth_jazz_1", "three_jelly", "evil_pulsation", "jungle", "red_nose_pop", "smooth_jazz_2","blank_cd"]
var items_with_secondary = ["brickies_family_house"]
var cds = items_that_spin
var brands: Dictionary = {"none":100, "elemental":30,"conceal":20}
var polo_brands = {"none":100, "elemental":30}

# Categories
var clothes: Array = ["tshirt", "tshirt","tshirt","socks", "trousers", "shorts", "shoes", "beh_enclosed_shirt","boxers","conceal_shoes","flip_flops","polo_shirt"]
#var clothes = ["tshirt"]
var toys: Array = ["puzzle_cube", "football","playing_cards", "brickies_family_house"]
var home: Array = ["spud_poster","potion_poster","christmas_lights", "banana_poster"]
var electronics: Array = ["cd_player", "the_big_mint", "smooth_jazz_1", "camera", "three_jelly", "evil_pulsation", "jungle","christmas_lights","radio","red_nose_pop", "smooth_jazz_2"]
var books_and_media: Array = ["spud_poster","potion_poster", "the_big_mint", "smooth_jazz_1", "three_jelly", "evil_pulsation", "jungle","red_nose_pop","encyclopedia", "banana_poster", "smooth_jazz_2"]
var collectables: Array = ["spud_poster", "beh_enclosed_shirt","gold_ring","encyclopedia","silver_ring"]
var sports: Array = ["beh_enclosed_shirt", "football","basketball"]
var placeable_items = ["cd_player","camera","radio","calculator"]
var posters = ["spud_poster","potion_poster", "banana_poster"]
# ---------------------------------------------
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var ID = -1
var number: int = 0
var color1: String = ""
var color2: String = ""
var shippingTime: float = 0
var shippingValue: int = 0
var seller_name = ""
var seller_rating
var conditions = ["Poor", "Satisfactory", "Good", "Great", "Excellent", "Minted"]
var condition = ""
var condition_price_mult = 1
var price = 0
var default_price:float = 0
var type = ""
var last_frame: int = 0
var chosen_frame: int = 0
var sprite_image: AnimatedSprite2D
var brandmult = 1
var brand = "none"
var genre = "none"
var cd: bool
var spice_factor = 0
var selected_brand = "none"
var counter: int = 0
var hovering = false
var overlay_animation = "none"
var item_category = []
var placeable = false
var poster = false
var ad = false
var market_category = ""
var code = ""

# scamming
var scam = false
var scam_type = "none"

var rarities = {
			"common": 500,
			"uncommon": 250 * Global.uncommon_frequency,
			"rare": 100,
			"epic": 25,
			"legendary": 5
	}
	
var rarity = "common"
var pattern_type = "none"
var patterns: Dictionary = {"stripes":200,"checker":100,"polka-dot":80,"wavy":40,"zig-zag":30,"geometric":20,"hearts":20,"smiley":20}
var pattern_mult = 1
var pattern_colours: Array = ["blue","yellow", "red", "green", "white", "black", "purple", "pink", "cyan", "orange",
"apricot","turquoise","forest","coral","navy","rose","brown","burgundy","mint","lilac"]
var pattern_index: int = 0
signal rarity_ui(item_rarity: String)
var socks_shader = preload("res://shaders/color_swap_sock.gdshader")
var tshirt_shader = preload("res://shaders/color_swap_t_shirt.gdshader")
var socks_texture = preload("res://shaders/socks_colours.png")
var tshirt_texture = preload("res://shaders/tshirt_colours.png")
var trousers_texture = preload("res://shaders/trousers_colours.png")
var shorts_texture = preload("res://shaders/shorts_colours.png")
var boxers_texture = preload("res://shaders/boxers_colours.png")
var conceal_texture = preload("res://shaders/conceal_colours.png")
var pattern_texture = preload("res://shaders/pattern_colors.png")
var flip_flop_texture = preload("res://shaders/tshirt_colours.png")

@onready var sprites := {
	"tshirt": $TextureButton/tshirt,
	"socks": $TextureButton/socks,
	"trousers": $TextureButton/trousers,
	"shorts": $TextureButton/shorts,
	"shoes": $TextureButton/shoes,
	"cd_player": $TextureButton/cd_player,
	"puzzle_cube": $TextureButton/puzzle_cube,
	"spud_poster": $TextureButton/spud_poster,
	"beh_enclosed_shirt": $TextureButton/beh_enclosed_shirt,
	"potion_poster": $TextureButton/potion_poster,
	"boxers": $TextureButton/boxers,
	"the_big_mint": $TextureButton/the_big_mint,
	"smooth_jazz_1": $TextureButton/smooth_jazz_1,
	"camera": $TextureButton/camera,
	"three_jelly": $TextureButton/three_jelly,
	"evil_pulsation": $TextureButton/evil_pulsation,
	"jungle": $TextureButton/jungle,
	"football": $TextureButton/football,
	"gold_ring": $TextureButton/gold_ring,
	"conceal_shoes": $TextureButton/conceal_shoes,
	"basketball": $TextureButton/basketball,
	"playing_cards": $TextureButton/playing_cards,
	"flip_flops": $TextureButton/flip_flops,
	"christmas_lights": $TextureButton/christmas_lights,
	"radio": $TextureButton/radio,
	"red_nose_pop": $TextureButton/red_nose_pop,
	"encyclopedia": $TextureButton/encyclopedia,
	"brickies_family_house": $TextureButton/brickies_family_house,
	"banana_poster": $TextureButton/banana_poster,
	"smooth_jazz_2": $TextureButton/smooth_jazz_2,
	"polo_shirt": $TextureButton/polo_shirt,
	"silver_ring": $TextureButton/silver_ring,
	"scrap_metal": $TextureButton/scrap_metal,
	"scrap_paper": $TextureButton/scrap_paper,
	"scrap_plastic": $TextureButton/scrap_plastic,
	"scrap_fabric": $TextureButton/scrap_fabric,
	"blank_cd": $TextureButton/blank_cd,
}

@onready var market_details_ui = get_node_or_null("/root/MainUI/Mintora/VBoxContainer/Control3/TabContainer/Home/Market/VBoxContainer/Sections/Product_Details")
@onready var bidding_details_ui = get_node_or_null("/root/MainUI/Mintora/VBoxContainer/Control3/TabContainer/Bidding/Trading/Product_Details")

@onready var tshirt_logo: AnimatedSprite2D = $overlays/thsirt_logo
@onready var frame_timer = $FrameTimer
@onready var tshirt_pattern = $overlays/tshirt_pattern


func _process(delta):
	if sprite_image == null:
		return

	if hovering and type in items_that_spin:
		sprite_image.rotation_degrees += 160 * delta
	else:
		sprite_image.rotation_degrees = 0
		
func initialize_item(category := "All"):
	item_category.clear()
	color1 = ""
	color2 = ""
	poster = false
	placeable = false
	
	if ID == -1: #has not been assigned an ID
		ID = Inventory.item_id
		Inventory.item_id += 1
		
	brandmult = 1
	brand = "none"
	selected_brand = "none"
	genre = "none"
	seller_name = Global.name_generator()
	seller_rating = star_rating_bell_curve()
	if category == "Bidding":
		seller_rating = 5.0
	rng.randomize()
	scam = scam_chance(seller_rating)
	if scam:
		var roll = rng.randi_range(1,11)
		if roll <= 2:
			scam_type = "No Item"
		elif roll <= 6:
			scam_type = "Tampered"
		elif roll <= 9:
			scam_type = "Different"
		else:
			scam_type = "Wrong Code"
	market_category = category
	match category:
		"Clothes":
			type = get_random_item(clothes)
		"Toys":
			type = get_random_item(toys)
		"Home":
			type = get_random_item(home)
		"Electronics":
			type = get_random_item(electronics)
		"BooksMedia":
			type = get_random_item(books_and_media)
		"Collectables":
			type = get_random_item(collectables)
		"Sports":
			type =  get_random_item(sports)
		"Bidding":
			rarities = {
				"common": 150,
				"uncommon": 300 * Global.uncommon_frequency,
				"rare": 150,
				"epic": 50,
				"legendary": 25
			}
			type = get_random_item(all_items)
			rarities = {
				"common": 500,
				"uncommon": 300 * Global.uncommon_frequency,
				"rare": 100,
				"epic": 20,
				"legendary": 4
			}
		"Advert":
			rarities = {
				"common": 1,
				"uncommon": 2,
				"rare": 3,
				"epic": 4,
				"legendary": 5
			}
			ad = true
			type = get_random_item(all_items)
			rarities = {
				"common": 500,
				"uncommon": 250 * Global.uncommon_frequency,
				"rare": 100,
				"epic": 25,
				"legendary": 5
			}
			
		_:
			type = get_random_item(all_items)
	
	rarities = {
				"common": 500,
				"uncommon": 250 * Global.uncommon_frequency,
				"rare": 100,
				"epic": 25,
				"legendary": 5
			}
	generate_parameters(type)
	set_item_type(type)
	code = Global.create_code(0)
	if type in common_items:
		rarity = "common"
	elif type in uncommon_items:
		rarity = "uncommon"
	elif type in rare_items:
		rarity = "rare"
	elif type in epic_items:
		rarity = "epic"
	elif type in legendary_items:
		rarity = "legendary"
		
	if sprites.has(type):
		var sprite = sprites[type]
		set_node_palette(sprite, number)
		sprite_image = sprite
	
	if type == "shoes":
		selected_brand = "elemental"
		brand = "elemental"
		color1 = "grey"
	elif type == "cd_player":
		selected_brand = "C.O.M.A"
		brand = "C.O.M.A"
		color1 = "grey"
		color2 = ""
	elif type == "puzzle_cube":
		color1 = "multi"
		brand = "none"
	elif type == "spud_poster":
		color1 = "brown"
	elif type == "beh_enclosed_shirt":
		color1 = "blue"
		color2 = "cyan"
	elif type == "potion_poster":
		color1 = "purple"
		color2 = "black"
	elif type == "the_big_mint":
		color1 = "black"
		color2 = "green"
		spice_factor = 3
	elif type == "smooth_jazz_1":
		color1 = "cream"
		spice_factor = 1
	elif type == "camera":
		selected_brand = "C.O.M.A"
		brand = "C.O.M.A"
		color1 = "grey"
	elif type == "three_jelly":
		color1 = "green"
		spice_factor = 4
	elif type == "evil_pulsation":
		color1 = "grey"
		spice_factor = 5
	elif type == "jungle":
		color1 = "green"
		color2 = "black"
		spice_factor = 2
	elif type == "football":
		color1 = "black"
		color2 = "white"
	elif type == "conceal_shoes":
		color2 = ""
		brand = "conceal"	
	elif type == "gold_ring":
		color2 = ""
		color1 = "yellow"
	elif type == "basketball":
		color2 = "black"
		color1 = "orange"
	elif type == "christmas_lights":
		color1 = "multi"
	elif type == "playing_cards":
		color1 = "white"
		brand = "Scuter"
	elif type == "radio":
		color1 = "grey"
		selected_brand = "C.O.M.A"
		brand = "C.O.M.A"
	elif type == "red_nose_pop":
		spice_factor = 2
		color1 = "red"
		color2 = "white"
	elif type == "encyclopedia":
		color1 = "blue"
	elif type == "brickies_family_house":
		selected_brand = "Brickies"
		brand = "Brickies"
		color1 = "brown"
		color2 = "red"
	elif type == "banana_poster":
		color1 = "yellow"
	elif type == "smooth_jazz_2":
		color1 = "blue"
		color2 = "navy"
		spice_factor = 1
		
	if type == "tshirt":
		tshirt_logo.show()
		if pattern_type != "none":
			tshirt_pattern.animation = pattern_type
			tshirt_pattern.frame = 0
			tshirt_pattern.show()
			set_node_palette(tshirt_pattern, pattern_index)
		else:
			tshirt_pattern.hide()
	else:
		pattern_type = "none"
		tshirt_logo.hide()
		tshirt_pattern.hide()
	
	for child in get_tree().get_nodes_in_group("clothes"):
		if child.visible and child is AnimatedSprite2D and child.owner == self:
			child.frame = 0
	emit_signal("rarity_ui", rarity)

func get_random_item(pool) -> String:
	var common_items_buffer = []
	var uncommon_items_buffer = []
	var rare_items_buffer = []
	var epic_items_buffer = []
	var legendary_items_buffer = []
	
	for item in pool:
		if item in common_items:
			common_items_buffer.append(item)
		elif item in uncommon_items:
			uncommon_items_buffer.append(item)
		elif item in rare_items:
			rare_items_buffer.append(item)
		elif item in epic_items:
			epic_items_buffer.append(item)
		elif item in legendary_items:
			legendary_items_buffer.append(item)	
			
	var total_weight = 0

	if common_items_buffer.size() > 0:
		total_weight += rarities["common"]
	if uncommon_items_buffer.size() > 0:
		total_weight += rarities["uncommon"]
	if rare_items_buffer.size() > 0:
		total_weight += rarities["rare"]
	if epic_items_buffer.size() > 0:
		total_weight += rarities["epic"]
	if legendary_items_buffer.size() > 0:
		total_weight += rarities["legendary"]
		
	var roll = rng.randi_range(1, total_weight)

	if common_items_buffer.size() > 0:
		if roll <= rarities["common"]:
			return common_items_buffer.pick_random()
		roll -= rarities["common"]

	if uncommon_items_buffer.size() > 0:
		if roll <= rarities["uncommon"]:
			return uncommon_items_buffer.pick_random()
		roll -= rarities["uncommon"]

	if rare_items_buffer.size() > 0:
		if roll <= rarities["rare"]:
			return rare_items_buffer.pick_random()
		roll -= rarities["rare"]
	
	if epic_items_buffer.size() > 0:
		if roll <= rarities["epic"]:
			return epic_items_buffer.pick_random()
		roll -= rarities["epic"]
		
	return legendary_items_buffer.pick_random()
	
func get_rarity():
	rng.randomize()
	var weighted_sum = 0
	for n in rarities:
		weighted_sum += rarities[n]
	
	var rarity_selected = rng.randi_range(0,weighted_sum)
	for n in rarities:
		if rarity_selected <= rarities[n]:
			return n
		else:
			rarity_selected -= rarities[n]
			

func get_brand(pool):
	rng.randomize()
	var weighted_sum = 0
	for n in pool:
		weighted_sum += pool[n]
	
	var brand_selected = rng.randi_range(0,weighted_sum)
	for n in pool:
		if brand_selected <= pool[n]:
			return n
		else:
			brand_selected -= pool[n]
			
func get_pattern():
	rng.randomize()
	var weighted_sum = 0
	for n in patterns:
		weighted_sum += patterns[n]
	
	var brand_selected = rng.randi_range(0,weighted_sum)
	for n in patterns:
		if brand_selected <= patterns[n]:
			return n
		else:
			brand_selected -= patterns[n]
								
func logo_calculator(color1_of_shirt: String) -> void:
	selected_brand = get_brand(brands)
	if selected_brand == "elemental":
		brand = "elemental"
		brandmult = 1.5
		var rnd_outcome = [1,2].pick_random()
		if color1_of_shirt == "black" and rnd_outcome == 1:
			overlay_animation = "ele_minimalistic_white"
			brandmult = 2
		elif color1_of_shirt == "white" and rnd_outcome == 1:
			overlay_animation = "ele_minimalistic_black"
			brandmult = 2
		else:
			overlay_animation = "ele_regular"
	else:
		tshirt_logo.animation = "none"
	
	if selected_brand == "conceal":
		brand = "conceal"
		brandmult = 2.5
		overlay_animation = "conceal_shirt"
	tshirt_logo.animation = overlay_animation
	tshirt_logo.frame = 0
	tshirt_logo.stop()
	if get_details_ui() != null:
		get_details_ui().stop_logo()

func set_item_type(item_type: String) -> void:
	for sprite in sprites.values():
		sprite.hide()
	if sprites.has(item_type):
		sprites[item_type].show()
	
func _on_texture_button_mouse_entered():
	hovering = true

	if type == "encyclopedia" and sprite_image:
		sprite_image.play("default")
		sprite_image.speed_scale = 1.0
	elif type in items_with_regular_animation:
		counter = 0
	elif type in items_with_secondary and sprite_image:
		sprite_image.play("secondary")

	frame_timer.start()


func _on_texture_button_mouse_exited():
	hovering = false
	frame_timer.stop()

	if type == "encyclopedia" and sprite_image:
		sprite_image.play_backwards("default")
		return
	
	if type in items_with_secondary and sprite_image:
		sprite_image.play("default")
		return
	
	if sprite_image:
		sprite_image.rotation_degrees = 0
		sprite_image.frame = 0
		sprite_image.stop()

	tshirt_logo.frame = 0

func _on_frame_timer_timeout():
	for child in get_tree().get_nodes_in_group("clothes"):
		if child.visible and child is AnimatedSprite2D and child.owner == self and !(type in items_with_regular_animation)and !(type in items_with_secondary):
			var max_frames = child.sprite_frames.get_frame_count("default")
			var new_frame = rng.randi_range(0, max_frames - 1)
			while new_frame == child.frame and max_frames > 1:
				new_frame = rng.randi_range(0, max_frames - 1)
			child.frame = new_frame
			if type == "tshirt":
				if overlay_animation != "none":
					tshirt_logo.show()
					tshirt_logo.frame = new_frame
				else:
					tshirt_logo.hide()
				if pattern_type != "none":
					tshirt_pattern.animation = pattern_type
					tshirt_pattern.show()
					tshirt_pattern.frame = new_frame % tshirt_pattern.sprite_frames.get_frame_count(pattern_type)
				else:
					tshirt_pattern.hide()
			else:
				tshirt_logo.hide()
				tshirt_pattern.hide()
		elif child.visible and child is AnimatedSprite2D and child.owner == self and type in items_with_regular_animation and !(type in items_with_secondary):
			if not child.is_playing():
				child.play("default")
			display_fps(child.sprite_frames.get_animation_speed(child.animation))
		elif child.visible and child is AnimatedSprite2D and child.owner == self and type in items_with_secondary:
			if not child.is_playing():
				child.play("secondary")
			display_fps(child.sprite_frames.get_animation_speed(child.animation))

func button_enter():
	frame_timer.start()
	hovering = true
	
func button_exit():
	frame_timer.stop()
	for child in get_tree().get_nodes_in_group("clothes"):
		if child.owner == self and type in items_with_secondary:
			child.play("default")
		elif child.owner == self and type != "encyclopedia":
			child.frame = 0
			tshirt_logo.frame = 0
			tshirt_pattern.frame = 0
		elif child.owner == self and type == "encyclopedia":
			child.play_backwards("default")

func generate_parameters(type):
	if type in cds:
		cd = true
	else:
		cd = false
	@warning_ignore("narrowing_conversion")
	if type == "tshirt":
		number = rng.randi_range(0, tshirt_colours.size()-1)
		color1 = tshirt_colours[number]
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		logo_calculator(color1)
		pattern_type = "none"
		if brand == "none":
			var roll = rng.randi_range(1,2)
			if roll == 2:
				pattern_type = get_pattern()
		price = snapped(2.5 * condition_price_mult * rng.randf_range(0.8,1.2) * brandmult,0.01)
		default_price = 2.5
	elif type == "polo_shirt":
		number = rng.randi_range(0, tshirt_colours.size()-1)
		color1 = tshirt_colours[number]
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		logo_calculator(color1)
		price = snapped(5 * condition_price_mult * rng.randf_range(0.8,1.2) * brandmult,0.01)
		default_price = 5
		
	elif type == "socks":
		number = rng.randi_range(0, colours.size()-1)
		color1 = colours[number]
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(1.5 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 1.5
	elif type == "trousers":
		number = rng.randi_range(0, trouser_colours.size()-1)
		color1 = trouser_colours[number]
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 2
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(4.5 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 4.5
	elif type == "shorts":
		number = rng.randi_range(0, trouser_colours.size()-1)
		color1 = trouser_colours[number]
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 2
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(3.5 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 3.5
	elif type == "shoes":
		number = rng.randi_range(0, colours.size()-1)
		color1 = colours[number]
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 2
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(14 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 3
	elif type == "cd_player":
		shippingTime = rng.randi_range(2, 6.0)
		shippingValue = 3
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(10 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 10
	elif type == "puzzle_cube":
		shippingTime = rng.randi_range(1, 6.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(7 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 7
	elif type == "spud_poster":
		shippingTime = rng.randi_range(1, 6.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(7 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 7
	elif type == "beh_enclosed_shirt":
		shippingTime = rng.randi_range(3, 10.0)
		shippingValue = 4
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(23 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 23
	elif type == "potion_poster":
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(8 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 8
	elif type == "boxers":
		number = rng.randi_range(0, colours.size()-1)
		color1 = colours[number]
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(2 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 2
	elif type == "the_big_mint":
		shippingTime = rng.randi_range(1, 6.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		genre = "phonk"
		price = snapped(9 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 9
	elif type == "smooth_jazz_1":
		shippingTime = rng.randi_range(1, 6.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(7 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 7
		genre = "jazz"
	elif type == "camera":
		shippingTime = rng.randi_range(1, 6.0)
		shippingValue = 2
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(7 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 7
	elif type == "three_jelly":
		shippingTime = rng.randi_range(1, 6.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		genre = "rage"
		price = snapped(9 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 9
	elif type == "evil_pulsation":
		shippingTime = rng.randi_range(1, 6.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		genre = "noise"
		price = snapped(9 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 9
	elif type == "jungle":
		shippingTime = rng.randi_range(1, 6.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		genre = "jungle"
		price = snapped(9 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 9
	elif type == "football":
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 2
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(8 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 8
	elif type == "gold_ring":
		shippingTime = rng.randi_range(3, 8.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(120 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 120
	elif type == "conceal_shoes":
		number = rng.randi_range(0, conceal_colours.size()-1)
		color1 = conceal_colours[number]
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 2
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(19 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 19
	elif type == "basketball":
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 2
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(9 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 9
	elif type == "christmas_lights":
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 2
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(8 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 8
	elif type == "flip_flops":
		number = rng.randi_range(0, colours.size()-1)
		color1 = colours[number]
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 2
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(8 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 8
	elif type == "playing_cards":
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(4 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 4
	elif type == "radio":
		shippingValue = 3
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(15 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 15
	elif type == "red_nose_pop":
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		genre = "pop"
		price = snapped(11 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 11
	elif type == "encyclopedia":
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 2
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(25 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 25
	elif type == "smooth_jazz_2":
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		genre = "jazz"
		price = snapped(7 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 7
	elif type == "banana_poster":
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(6.50 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 6.50
	elif type == "brickies_family_house":
		shippingTime = rng.randi_range(1, 5.0)
		shippingValue = 2
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(10.50 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 10.50
	elif type == "silver_ring":
		shippingTime = rng.randi_range(3, 8.0)
		shippingValue = 1
		condition = conditions.pick_random()
		condition_price_mult = condition_mult_calc(condition)
		price = snapped(35 * condition_price_mult * rng.randf_range(0.8,1.2),0.01)
		default_price = 35	
	if ad:
		number = 0
				
	if brand != "none":
		pattern_type = "none"
		color2 = ""
	
	if pattern_type != "none":
		var new_pattern_colours = pattern_colours.duplicate()
		new_pattern_colours.erase(color1)
		pattern_index = rng.randi_range(0, new_pattern_colours.size()-1)
		color2 = new_pattern_colours[pattern_index]
		pattern_index = pattern_colours.find(color2)
			
		if pattern_type == "stripes":
			pattern_mult = 1.2
		elif pattern_type == "checker":
			pattern_mult = 1.5
		elif pattern_type == "polka-dot":
			pattern_mult = 1.5
		elif pattern_type == "wavy":
			pattern_mult = 2
		elif pattern_type == "zig-zag":
			pattern_mult = 2
		elif pattern_type == "geometric":
			pattern_mult = 2.5
		elif pattern_type == "hearts":
			pattern_mult = 3
		elif pattern_type == "smiley":
			pattern_mult = 3.5
		
		price = snapped(price*pattern_mult,0.01)
	
	for news in Inventory.boosted_items_news:
		if news["type"] == type:
			price = snapped(price * news["amount"],0.01)
			
	# bug fix (idk why this is happening lmao)
	if overlay_animation != "none" and brand == "none":
		overlay_animation = "none"
	
	if type in clothes:
		item_category.append("clothes")
	if type in toys:
		item_category.append("toys")
	if type in home:
		item_category.append("home")
	if type in electronics:
		item_category.append("electronics")
	if type in books_and_media:
		item_category.append("books_and_media")
	if type in collectables:
		item_category.append("collectables")
	if type in sports:
		item_category.append("sports")
	if type in placeable_items:
		placeable = true
	if type in posters:
		poster = true
	
	shippingTime = snapped(shippingTime/Global.delivery_speed_mult,0.1)	
	
	price = snapped(price * min((seller_rating+1)/5.5,1),0.01)	
	
	if seller_rating < 3 and not scam:
		price = snapped(price * rng.randf_range(1.0,2),0.01)
		
	# minimum price is £1
	if price < 1:
		price = 1.00
		
func condition_mult_calc(condition: String) -> float:
	if condition == "Poor":
		return 0.4
	elif condition == "Satisfactory":
		return 0.6
	elif condition == "Good":
		return 0.8
	elif condition == "Great":
		return 0.9
	else:
		return 1.0

func display_fps(fps):
	frame_timer.wait_time = 1/fps
	
func set_node_palette(target_sprite: AnimatedSprite2D, num):
	if not ad:
		if target_sprite.material == null:
			var new_mat = ShaderMaterial.new()
			target_sprite.material = new_mat
		else:
			target_sprite.material = target_sprite.material.duplicate()

		if tshirt_pattern.material == null and pattern_type != "none":
			tshirt_pattern.material = ShaderMaterial.new()
		elif tshirt_pattern.material != null:
			tshirt_pattern.material = tshirt_pattern.material.duplicate()
			
		if type == "socks":
			target_sprite.material.shader = tshirt_shader
			
			target_sprite.material.set_shader_parameter("palette_texture", socks_texture)
			target_sprite.material.set_shader_parameter("tolerance", 0.05)
			target_sprite.material.set_shader_parameter("color_count", 6)
			target_sprite.material.set_shader_parameter("palette_count", 10)
			target_sprite.material.set_shader_parameter("palette_index", num)
			
		elif type == "tshirt" or type == "polo_shirt":
			target_sprite.material.shader = tshirt_shader
			
			target_sprite.material.set_shader_parameter("palette_texture", tshirt_texture)
			target_sprite.material.set_shader_parameter("tolerance", 0.1)
			target_sprite.material.set_shader_parameter("color_count", 5)
			target_sprite.material.set_shader_parameter("palette_count", 20)
			target_sprite.material.set_shader_parameter("palette_index", num)
		elif type == "shorts":
			target_sprite.material.shader = tshirt_shader
			
			target_sprite.material.set_shader_parameter("palette_texture", shorts_texture)
			target_sprite.material.set_shader_parameter("tolerance", 0.05)
			target_sprite.material.set_shader_parameter("color_count", 4)
			target_sprite.material.set_shader_parameter("palette_count", 5)
			target_sprite.material.set_shader_parameter("palette_index", num)
		elif type == "trousers":
			target_sprite.material.shader = tshirt_shader
			
			target_sprite.material.set_shader_parameter("palette_texture", trousers_texture)
			target_sprite.material.set_shader_parameter("tolerance", 0.05)
			target_sprite.material.set_shader_parameter("color_count", 4)
			target_sprite.material.set_shader_parameter("palette_count", 5)
			target_sprite.material.set_shader_parameter("palette_index", num)
		elif type == "boxers":
			target_sprite.material.shader = tshirt_shader
			
			target_sprite.material.set_shader_parameter("palette_texture", boxers_texture)
			target_sprite.material.set_shader_parameter("tolerance", 0.02)
			target_sprite.material.set_shader_parameter("color_count", 6)
			target_sprite.material.set_shader_parameter("palette_count", 10)
			target_sprite.material.set_shader_parameter("palette_index", num)
		elif type == "conceal_shoes":
			target_sprite.material.shader = tshirt_shader
			
			target_sprite.material.set_shader_parameter("palette_texture", conceal_texture)
			target_sprite.material.set_shader_parameter("tolerance", 0.02)
			target_sprite.material.set_shader_parameter("color_count", 11)
			target_sprite.material.set_shader_parameter("palette_count", 6)
			target_sprite.material.set_shader_parameter("palette_index", num)
			
		elif type == "flip_flops":
			target_sprite.material.shader = tshirt_shader
			
			target_sprite.material.set_shader_parameter("palette_texture", flip_flop_texture)
			target_sprite.material.set_shader_parameter("tolerance", 0.1)
			target_sprite.material.set_shader_parameter("color_count", 5)
			target_sprite.material.set_shader_parameter("palette_count", 20)
			target_sprite.material.set_shader_parameter("palette_index", num)
		
		else:
			target_sprite.material.shader = null
			
		if pattern_type != "none":
			tshirt_pattern.material.shader = tshirt_shader
			
			tshirt_pattern.material.set_shader_parameter("palette_texture", pattern_texture)
			tshirt_pattern.material.set_shader_parameter("tolerance", 0.05)
			tshirt_pattern.material.set_shader_parameter("color_count", 4)
			tshirt_pattern.material.set_shader_parameter("palette_count", 20)
			tshirt_pattern.material.set_shader_parameter("palette_index", num)	
	

#------ for storage
func get_data() -> Dictionary:
	return {
		"ID": ID,
		"type": type,
		"number": number,
		"color1": color1,
		"color2": color2,
		"price": price,
		"shippingTime": shippingTime,
		"shippingValue": shippingValue,
		"condition": condition,
		"condition_price_mult": condition_price_mult,
		"brand": brand,
		"brandmult": brandmult,
		"selected_brand": selected_brand,
		"genre": genre,
		"cd": cd,
		"spice_factor": spice_factor,
		"rarity": rarity,
		"logo_animation": tshirt_logo.animation if tshirt_logo else "none",
		"default_price": default_price,
		"overlay_animation": overlay_animation,
		"pattern_type": pattern_type,
		"pattern_mult": pattern_mult,
		"pattern_index": pattern_index,
		"seller_name": seller_name,
		"seller_rating": seller_rating,
		"item_category": item_category,
		"placeable": placeable,
		"poster": poster,
		"ad": ad,
		"market_category": market_category,
		"code": code,
		"scam": scam,
		"scam_type": scam_type
	}

func load_data(data: Dictionary) -> void:
	ID = data.get("ID", -1)
	type = data.get("type", "")
	number = data.get("number", 0)
	color1 = data.get("color1", "")
	color2 = data.get("color2", "")
	price = data.get("price", 0)
	brandmult = data.get("brandmult",1) 
	shippingTime = data.get("shippingTime", 0)
	shippingValue = data.get("shippingValue",1)
	condition = data.get("condition", "")
	condition_price_mult = data.get("condition_price_mult", 1)
	brand = data.get("brand", "none")
	selected_brand = data.get("selected_brand", "none")
	genre = data.get("genre", "none")
	cd = data.get("cd", false)
	rarity = data.get("rarity", "common")
	default_price = data.get("default_price",1.00)
	overlay_animation = data.get("overlay_animation","none")
	pattern_type = data.get("pattern_type", "none")
	pattern_mult = data.get("pattern_mult",1)
	pattern_index = data.get("pattern_index",0)
	seller_name = data.get("seller_name","Unknown Seller")
	seller_rating = data.get("seller_rating", 0)
	item_category = data.get("item_category","")
	placeable = data.get("placeable",false)
	poster = data.get("poster",false)
	spice_factor = data.get("spice_factor",1)
	ad = data.get("ad",false)
	market_category = data.get("market_category","")
	code = data.get("code","NO CODE")
	scam = data.get("scam",false)
	scam_type = data.get("scam_type","none")
	set_item_type(type)

	if sprites.has(type):
		var sprite = sprites[type]
		set_node_palette(sprite, number)
		sprite_image = sprite
	
		
	if type == "tshirt" and tshirt_logo:
		tshirt_logo.animation = data.get("logo_animation", "none")
		tshirt_logo.frame = 0
		tshirt_logo.stop()
		
	if type == "tshirt" and pattern_type != "none" and tshirt_pattern:
		tshirt_pattern.animation = pattern_type
		tshirt_pattern.frame = 0
		tshirt_pattern.show()
		set_node_palette(tshirt_pattern, pattern_index)
	else:
		tshirt_pattern.hide()

	emit_signal("rarity_ui", rarity)

func get_details_ui():
	if Global.on_bidding:
		return bidding_details_ui
	return market_details_ui

func display_thing():
	get_details_ui().display_product_info(sprite_image, get_data())
	
func star_rating_bell_curve() -> float:
	var value: float
	while true:
		value = randfn(3.65, 1.0)
		if value >= 0.5 and value <= 5.0:
			break
	return round(value * 2) / 2

func scam_chance(rating):
	var scam_chance = 0
	if rating <= 0.5:
		scam_chance = 0.99
	elif rating <= 1:
		scam_chance = 0.9
	elif rating <= 1.5:
		scam_chance = 0.8
	elif rating <= 2:
		scam_chance = 0.7
	elif rating <= 2.5:
		scam_chance = 0.55
	elif rating <= 3:
		scam_chance = 0.4
	elif rating <= 3.5:
		scam_chance = 0.2
	elif rating <= 4:
		scam_chance = 0.02
	else:
		scam_chance = 0
	
	return scam_chance >= rng.randf()

func update_type():
	set_item_type(type)
	for child in get_tree().get_nodes_in_group("clothes"):
		if child.visible and child is AnimatedSprite2D and child.owner == self:
			child.frame = 0
