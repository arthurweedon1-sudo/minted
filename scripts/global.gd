extends Node

var gooning: bool = true

var money: float = 50.00
var bank_money: float = 0.0
var username: String = "margthehagler34"
var current_money: float = money
var xp: int = 0
var rank: String = "Seller"
var storage_capacity: int = 10
var inWardrobe: bool = false
var inShelf: bool = false
var outside: bool = false
var inLocker: bool = false
var scene_loading = false
var now_playing: String = ""
var music_volume: int = -10
var sfx_volume: int = -5
var camera_quality = "Good"
var refreshProgress = 100
var player_saved_x = 0
var player_saved_y = 0
var outside_saved_position = Vector2(0,0)

var first_room = true
var dialogue_ongoing = false
var bidding_index_selected = -1
var buffer_text = ""
var on_bidding = false
var scroll_value = 0
var vehicle_queue_left: Array = []
var vehicle_queue_right: Array = []
var Tooltip
signal pause_toggled(is_paused: bool)
signal eject
signal create_mail
signal update_time

# --- CLOCK --- #
var min = 0
var hour = 6
var day = 1
var month = 7
var year = 2026
var time_mins = 0

var days_since_rent: int = 0
var rent_triggered: bool = false

var clock_timer = 0.0
var paused = false
var skip_dialogue = false
var no_sleep = true
var current_interactable = null
var sleep = 90
var action_just_pressed = false
var radio_on = false
var radio_playing = "none"
var cd_paused = false
var on_market = false

# Rent
var rent_building: float = 2.0
var rent_electrical: float = 1
var rent_utilities: float = 0.5
var rent_maintenance: float = 1.0
var rent_broadband: float = 0
var rent_broadband_mult: float = 1.0
var on_computer = false
var mins_on_computer = 0
var rent_frequency = 10
var rent_ready = false
var total_rent = 0
var loan_info: Array = [0, 0, 0] # money, days left, interest
var loan_mult = 1
var do_rent = false

var frequency = 150
# clock
# try 0.2 as default
var CLOCK_SPEED = 0.2 # ---> The lower, the faster jsuk rohan for testing
var SPEED_MULT = 1 # just makes time even faster, default to 1.
const months_31 = [1,3,5,7,8,10,12]
const months_30 = [4,6,9,11]
var REFRESHTIME: float = 6*60 # 6 in game hours
var MARKUPCOOLDOWN = 24*60*3  # 3 in game days
var markup_progress = 0

# newspaper
var last_article = -1
var articles = []
var news_interest = 1
var daily_change = 0.2
const refresh_news_1_at = 10
const refresh_news_2_at = 16

# player
var player_pos = Vector2(0,0)

# Debug
var debug_enabled: bool = false
# Skill Tree
var skill_tree_unlocked = [0]

# values changed with skill tree
var invested: bool = false
var future
var invest_claimed = true
var max_investment = 100
var interest_boost = 0
var likability_score = 1
var sleep_mult = 1
var items_computer = 12
var uncommon_frequency = 1
var delivery_speed_mult = 1

signal playing_changed(value: bool)

var playing: bool = false:
	set(value):
		if playing == value:
			return
		playing = value
		playing_changed.emit(value)
var mintora = false

# item codes
var codes = []
var suspicion = 1

func _process(delta):
	if money != current_money:
		SaveLoad._save()
	if rent_triggered and do_rent:
		RentPopup.visible = true
		paused = true
	else:
		RentPopup.visible = false
		paused = false
	
	player_rating = snapped(mean(player_ratings), 0.5)
	
	if Input.is_action_just_released("interact"):
		action_just_pressed = false
	clock_timer += delta
	if clock_timer >= CLOCK_SPEED and not paused and not dialogue_ongoing and not scene_loading:
		refreshProgress += 100/REFRESHTIME
		markup_progress += 100/MARKUPCOOLDOWN
		
		clock_timer -= CLOCK_SPEED
		new_time_calc(SPEED_MULT)
	elif dialogue_ongoing or paused or scene_loading:
		clock_timer = 0
		
func new_time_calc(min_added: int) -> void:
	update_time.emit()
	min += min_added 
	time_mins += min_added 
	if on_computer:
		mins_on_computer += min_added
	
	var news_index = 0
	for news in Inventory.boosted_items_news:
		if time_mins - news["time"]  >= 24*60:
			Inventory.boosted_items_news[news_index]["time"] = time_mins
			Inventory.boosted_items_news[news_index]["amount"] -= 0.1
			
			if Inventory.boosted_items_news[news_index]["amount"] < 1:
				Inventory.boosted_items_news.pop_at(news_index)
			
		news_index += 1
			
			
			
	daily_change = abs(1-news_interest) + 0.05
	var change = daily_change / 1440
	if news_interest > 1 and change > 0.0000001:
		news_interest -= change
	elif news_interest < 1 and change > 0.0000001:
		news_interest += change
		
	if not no_sleep:
		sleep -= float(min_added) / 28
		if sleep <= 10:
			sleep += float(min_added) / 60 # 50% slower
		elif sleep <= 40:
			sleep += float(min_added) / 120 # 25% slower
	
	if mins_on_computer >= 60:
		mins_on_computer = 0
		rent_broadband += 0.04 * rent_broadband_mult
			
	if min >= 60:
		min -= 60
		hour += 1
		
		if hour == 12:
			days_since_rent += 1
			if days_since_rent >= rent_frequency:
				rent_ready = true
				days_since_rent = 0
		if hour == 12 and rent_ready:
			rent_triggered = true
		if hour == refresh_news_1_at:
			while articles.size() < 2:
				articles.append(null)
				
			var packed = preload("res://scenes/article.tscn")
			var storage_ui = packed.instantiate()
			storage_ui.article_index = 0
			add_child(storage_ui)
			Inventory.ad_items[0] = {}
			articles[0] = storage_ui.article_chosen
			
			storage_ui.queue_free()
			SignalBus.articles_changed.emit()
			
		# --- REFRESH SLOT 1 (16:00) --- #
		elif hour == refresh_news_2_at:
			while articles.size() < 2:
				articles.append(null)
				
			var packed = preload("res://scenes/article.tscn")
			var storage_ui = packed.instantiate()
			storage_ui.article_index = 1
			add_child(storage_ui)
			
			Inventory.ad_items[1] = {}
			articles[1] = storage_ui.article_chosen
			
			storage_ui.queue_free()
			SignalBus.articles_changed.emit()
			
	if hour >= 24:
		hour -= 24
		day += 1
		suspicion -= 0.03
		suspicion = max(1,suspicion)

		var days_in_month = calc_days_in_month(month, year)
	
		if day > days_in_month:
			day = 1
			month += 1

			if month > 12:
				month = 1
				year += 1
		
	
	total_rent = rent_broadband + rent_building + rent_electrical + rent_maintenance + rent_utilities
func get_time_text() -> String:
	return format_time(hour) + ":" + format_time(min)

func get_date_text() -> String:
	return format_time(day) + "/" + format_time(month) + "/" + format_time(year)


func calc_days_in_month(month, year) -> int:
	if month in months_31:
		return 31
	elif month in months_30:
		return 30
	elif is_leap_year(year):
		return 29
	else:
		return 28

func is_leap_year(year) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

func format_time(time) -> String:
	var t = str(time)
	if t.length() == 1:
		t = "0" + t
	return t

func goto_scene(path: String) -> void:
	scene_loading = true
	clock_timer = 0
	get_tree().change_scene_to_file(path)
	#await get_tree().process_frame
	scene_loading = false
	
# --- END Clock --- #

func name_generator():
	var first_names_m = ["oliver","tom","max","arthur","rohan","william","kai","jerry","mac","gabe","rick","peter","chris","daniel","jack","james","morty","kasper"]
	var first_names_f = ["olivia","liz","tal","sophie","maya","margaret","eileen","noelle","susie","lois","linda","vic"]
	
	var prefixes = ["green","awesome","webbed","death","crazy","pink","wizardy","lucky","spiky","jungle","massive"]
	var gender= randi_range(1,2)
	if gender == 1:
		return prefixes.pick_random() + first_names_m.pick_random() + str(randi_range(1,100))
	if gender == 2:
		return prefixes.pick_random() + first_names_f.pick_random() + str(randi_range(1,100))

func item_name_generator(data) -> String:
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
	elif type == "silver_ring":
		display_color = ""
		display_type = "Silver Ring"
	elif type == "red_nose_pop":
		display_type = "Red Nose Pop CD"
		display_color = ""
	elif type == "red_nose_pop":
		display_type = "Red Nose Pop CD"
		display_color = ""
			
	if data["overlay_animation"] == "ele_minimalistic_white" or data["overlay_animation"] == "ele_minimalistic_black":
		brand_print = "elemental minimalistic "
	
	if display_color2 != "" and display_color != "" and data["pattern_type"] != "none":
		return brand_print + display_color + " & " + display_color2.capitalize() + " " +  data["pattern_type"] + " " + display_type + "."
	elif display_color2 != "" and display_color != "":
		return brand_print + display_color + " & " + display_color2.capitalize() + " " + display_type + "."
	else:
		return brand_print + display_color + " " + display_type + "."
		
func begin():
	pass	

# Player Star
var player_ratings: Array = [5.0]
var player_rating: float
func mean(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var sum = 0.0
	for v in values:
		sum += v
	return sum / values.size()


func get_month(month):
	match month:
		1:
			return "January"
		2:
			return "February"
		3:
			return "March"
		4:
			return "April"
		5:
			return "May"
		6:
			return "June"
		7:
			return "July"
		8:
			return "August"
		9:
			return "September"
		10:
			return "October"
		11:
			return "November"
		12:
			return "December"
		0:
			return "December"

func place_generator():
	var places = ["Leafsville","Stally","Bamber Bridge","Allomin","Verton","Floofsville","Hopesfield","Chipplesea","Tripletee","Mezzanone","Hustleville","Crankylank"]
	return places.pick_random()

func place_generatorB():
	var places = ["Stally","Bamber Bridge","Allomin","Verton","Floofsville","Hopesfield","Chipplesea","Tripletee","Mezzanone","Hustleville","Crankylank"]
	return places.pick_random()

func full_name_generator():
	var forenames = ["richard","sam","oliver","tom","max","arthur","rohan","william","kai","jerry","mac","gabe","rick","peter","chris","daniel","jack","james","morty","kasper","olivia","elizabeth","tal","sophie","maya","eileen","noelle","susie","lois","linda","victoria","seren","otto"]
	var surnames = ["D James", "Pearl", "Smith", "Thomson","Misiurski","Weedon","Hall","Wiggum","Simpson","Cenat","Macenzie","Griffith","Walker","Simons","Digby-Dysart"]
	return (forenames.pick_random()).capitalize() + " " + surnames.pick_random()

# got the big gpt to make this one cos its repetitive and boring
func add_to_date(add_days: int = 0, add_months: int = 0, from_day: int = day, from_month: int = month, from_year: int = year) -> Dictionary:
	var d = from_day
	var m = from_month
	var y = from_year

	m += add_months
	while m > 12:
		m -= 12
		y += 1
	while m < 1:
		m += 12
		y -= 1

	var days_in_new_month = calc_days_in_month(m, y)
	if d > days_in_new_month:
		d = days_in_new_month

	d += add_days
	var days_in_month = calc_days_in_month(m, y)
	while d > days_in_month:
		d -= days_in_month
		m += 1
		if m > 12:
			m = 1
			y += 1
		days_in_month = calc_days_in_month(m, y)
	while d < 1:
		m -= 1
		if m < 1:
			m = 12
			y -= 1
		d += calc_days_in_month(m, y)

	return {"day": d, "month": m, "year": y}


func date_to_absolute_days(d: int, m: int, y: int) -> int:
	var total_days = 0
	for yr in range(0, y):
		total_days += 366 if is_leap_year(yr) else 365
	for mo in range(1, m):
		total_days += calc_days_in_month(mo, y)
	total_days += d
	return total_days

func days_between(d1: int, m1: int, y1: int, d2: int, m2: int, y2: int) -> int:
	return date_to_absolute_days(d2, m2, y2) - date_to_absolute_days(d1, m1, y1)

func days_until(target_day: int, target_month: int, target_year: int) -> int:
	return days_between(day, month, year, target_day, target_month, target_year)

func months_until(target_day: int, target_month: int, target_year: int) -> float:	return days_until(target_day, target_month, target_year) / 30.44

func get_save_data() -> Dictionary:
	return {
		"money": money,
		"bank_money": bank_money,
		"username": username,
		"xp": xp,
		"rank": rank,
		"storage_capacity": storage_capacity,
		"inWardrobe": inWardrobe,
		"inShelf": inShelf,
		"outside": outside,
		"inLocker": inLocker,
		"now_playing": now_playing,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"camera_quality": camera_quality,
		"refreshProgress": refreshProgress,
		"player_saved_x": player_saved_x,
		"player_saved_y": player_saved_y,
		"first_room": first_room,
		"bidding_index_selected": bidding_index_selected,
		"vehicle_queue_left": vehicle_queue_left,
		"vehicle_queue_right": vehicle_queue_right,

		"min": min,
		"hour": hour,
		"day": day,
		"month": month,
		"year": year,
		"time_mins": time_mins,

		"days_since_rent": days_since_rent,
		"rent_triggered": rent_triggered,
		"no_sleep": no_sleep,
		"sleep": sleep,
		"radio_on": radio_on,
		"radio_playing": radio_playing,
		"on_market": on_market,

		"rent_building": rent_building,
		"rent_electrical": rent_electrical,
		"rent_utilities": rent_utilities,
		"rent_maintenance": rent_maintenance,
		"rent_broadband": rent_broadband,
		"rent_broadband_mult": rent_broadband_mult,
		"mins_on_computer": mins_on_computer,
		"rent_frequency": rent_frequency,
		"rent_ready": rent_ready,
		"total_rent": total_rent,
		"loan_info": loan_info,

		"frequency": frequency,

		"last_article": last_article,
		"articles": articles,
		"news_interest": news_interest,
		"daily_change": daily_change,
		"do_rent": do_rent,
		"player_pos": player_pos,
		"player_ratings": player_ratings,
		"player_rating": player_rating,
		"skill_tree_unlocked":skill_tree_unlocked,
		"invested": invested,
		"future": future,
		"debug_enabled": debug_enabled,
		"invest_claimed": invest_claimed,
		"markup_progress": markup_progress,
		"max_investment": max_investment,
		"interest_boost": interest_boost,
		"likability_score": likability_score,
		"sleep_mult": sleep_mult,
		"items_computer": items_computer,
		"uncommon_frequency": uncommon_frequency,
		"delivery_speed_mult": delivery_speed_mult,
		"suspicion": suspicion
	}

func load_save_data(data: Dictionary) -> void:
	money = data.get("money", money)
	bank_money = data.get("bank_money", bank_money)
	username = data.get("username", username)
	xp = data.get("xp", xp)
	rank = data.get("rank", rank)
	storage_capacity = data.get("storage_capacity", storage_capacity)
	inWardrobe = data.get("inWardrobe", inWardrobe)
	inShelf = data.get("inShelf", inShelf)
	outside = data.get("outside", outside)
	inLocker = data.get("inLocker", inLocker)
	now_playing = data.get("now_playing", now_playing)
	music_volume = data.get("music_volume", music_volume)
	sfx_volume = data.get("sfx_volume", sfx_volume)
	camera_quality = data.get("camera_quality", camera_quality)
	refreshProgress = data.get("refreshProgress", refreshProgress)
	player_saved_x = data.get("player_saved_x", player_saved_x)
	player_saved_y = data.get("player_saved_y", player_saved_y)
	first_room = data.get("first_room", first_room)
	bidding_index_selected = data.get("bidding_index_selected", bidding_index_selected)
	vehicle_queue_left = data.get("vehicle_queue_left", vehicle_queue_left)
	vehicle_queue_right = data.get("vehicle_queue_right", vehicle_queue_right)
	do_rent = data.get("do_rent",true)
	skill_tree_unlocked = data.get("skill_tree_unlocked",[0])
	min = data.get("min", min)
	hour = data.get("hour", hour)
	day = data.get("day", day)
	month = data.get("month", month)
	year = data.get("year", year)
	time_mins = data.get("time_mins", time_mins)

	days_since_rent = data.get("days_since_rent", days_since_rent)
	rent_triggered = data.get("rent_triggered", rent_triggered)
	no_sleep = data.get("no_sleep", no_sleep)
	sleep = data.get("sleep", sleep)
	radio_on = data.get("radio_on", radio_on)
	radio_playing = data.get("radio_playing", radio_playing)
	on_market = data.get("on_market", on_market)

	rent_building = data.get("rent_building", rent_building)
	rent_electrical = data.get("rent_electrical", rent_electrical)
	rent_utilities = data.get("rent_utilities", rent_utilities)
	rent_maintenance = data.get("rent_maintenance", rent_maintenance)
	rent_broadband = data.get("rent_broadband", rent_broadband)
	rent_broadband_mult = data.get("rent_broadband_mult", rent_broadband_mult)
	mins_on_computer = data.get("mins_on_computer", mins_on_computer)
	rent_frequency = data.get("rent_frequency", rent_frequency)
	rent_ready = data.get("rent_ready", rent_ready)
	total_rent = data.get("total_rent", total_rent)
	loan_info = data.get("loan_info", loan_info)

	frequency = data.get("frequency", frequency)

	last_article = data.get("last_article", last_article)
	articles = data.get("articles", articles)
	news_interest = data.get("news_interest", news_interest)
	daily_change = data.get("daily_change", daily_change)

	player_pos = data.get("player_pos", player_pos)
	player_ratings = data.get("player_ratings", player_ratings)
	player_rating = data.get("player_rating", player_rating)
	
	debug_enabled = data.get("debug_enabled", debug_enabled)
	
	invested = data.get("invested", invested)
	future = data.get("future", future)
	invest_claimed = data.get("invest_claimed", invest_claimed)
	
	markup_progress = data.get("markup_progress",markup_progress)
	max_investment = data.get("max_investment",max_investment)
	sleep_mult = data.get("sleep_mult",sleep_mult)
	suspicion = data.get("suspicion",suspicion)
	interest_boost = data.get("interest_boost",interest_boost)
	likability_score = data.get("likability_score",likability_score)
	uncommon_frequency = data.get("uncommon_frequency",uncommon_frequency)
	delivery_speed_mult  = data.get("delivery_speed_mult",delivery_speed_mult)

func reset_to_defaults() -> void:
	money = 50.00
	bank_money = 0.0
	username = "margthehagler34"
	xp = 0
	rank = "Seller"
	storage_capacity = 10
	inWardrobe = false
	inShelf = false
	outside = false
	inLocker = false
	now_playing = ""
	music_volume = -10
	sfx_volume = -5
	camera_quality = "Good"
	refreshProgress = 100
	player_saved_x = 0
	player_saved_y = 0
	first_room = true
	bidding_index_selected = -1
	vehicle_queue_left = []
	vehicle_queue_right = []

	min = 0
	hour = 6
	day = 1
	month = 7
	year = 2026
	time_mins = 0

	days_since_rent = 0
	rent_triggered = false
	no_sleep = false
	skip_dialogue = false
	sleep = 90
	radio_on = false
	radio_playing = "none"
	on_market = false

	rent_building = 2.0
	rent_electrical = 1
	rent_utilities = 0.5
	rent_maintenance = 1.0
	rent_broadband = 0
	rent_broadband_mult = 1.0
	mins_on_computer = 0
	rent_frequency = 10
	rent_ready = false
	total_rent = 0
	loan_info = [0,0,0]

	frequency = 150

	last_article = -1
	articles = []
	news_interest = 1
	daily_change = 0.2
	skill_tree_unlocked = [0]
	player_pos = Vector2(0,0)
	player_ratings = [3.5]
	player_rating = 0.0
	MARKUPCOOLDOWN = 24*60*3  # 3 in game days
	markup_progress = 0
	debug_enabled = false
	
	invested = false
	future
	invest_claimed = true
	
	var player_pos = Vector2(0,0)

	var codes = []
	var suspicion = 1
	
	playing = true
	

func create_code(tries):
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	var current_code = ""
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(6):
		var num = rng.randi_range(0,chars.length())
		current_code = current_code + chars[num-1]
	
	if current_code in codes:
		if tries < 10:
			return create_code(tries + 1)
		else:
			codes= []
			return create_code(0)
	else:
		codes.append(current_code)
		return current_code
