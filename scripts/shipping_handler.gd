extends Node

var shipping_list: Array = []
var shipping_value: int = 0
var delivered_list: Array = []
var mail_user_list: Array = []
var locker_list: Array = []

func _process(delta: float) -> void:
	#Inventory.current_ui_type = "shipping"
	for i in shipping_list:
		var data = i
		var entry = data[0]
		var progress = get_progress(data)
		if progress["percentage"] >= 100.0:
			if entry["scam"]:
				if entry["scam_type"] == "Tampered":
					var conditions  = ["Poor", "Satisfactory", "Good", "Great", "Excellent", "Minted"]
					var index = conditions.find(entry["condition"])
					if index == 0:
						entry["scam_type"] == "Different"
					entry["condition"] = conditions[max(0,index-randi_range(1,4))]
					entry["condition_price_mult"] = condition_mult_calc(entry["condition"])
					
				elif entry["scam_type"] == "Different":
					var type = entry["type"]
					var clothes: Array = ["tshirt", "tshirt","tshirt","socks", "trousers", "shorts", "shoes", "beh_enclosed_shirt","boxers","conceal_shoes","flip_flops","polo_shirt"]
					var cds = ["the_big_mint", "smooth_jazz_1", "three_jelly", "evil_pulsation", "jungle", "red_nose_pop", "smooth_jazz_2"]
					var posters = ["spud_poster","potion_poster", "banana_poster"]
					
					
					if type == "gold_ring":
						entry["type"] = "silver_ring"
						entry["default_price"] = 35
						entry["color1"] = "grey"
						entry["color2"] = ""
						entry["rarity"] = "rare"
						
					elif type == "tshirt" or type == "polo_shirt":
						entry["brand"] = "none"
						entry["pattern"] = "none"
						entry["brandmult"] = 1
						entry["pattern_mult"] = 1
						entry["logo_animation"] = "none"
						entry["overlay_animation"] = "none"
					elif type in cds:
						entry["type"] = "blank_cd"
						entry["default_price"] = 2
						entry["color1"] = "grey"
						entry["color2"] = ""
						entry["rarity"] = "common"
					elif type == "encyclopedia" or type == "playing_cards" or type in posters:
						entry["type"] = "scrap_paper"
						entry["default_price"] = 1
						entry["color1"] = "white"
						entry["color2"] = ""
						entry["rarity"] = "common"
					elif type == "silver_ring":
						entry["type"] = "scrap_metal"
						entry["default_price"] = 3
						entry["color1"] = "grey"
						entry["color2"] = ""
						entry["rarity"] = "common"
					elif type in clothes:
						entry["type"] = "scrap_fabric"
						entry["default_price"] = 1.80
						entry["color1"] = "white"
						entry["color2"] = ""
						entry["rarity"] = "common"
					else:
						entry["type"] = "scrap_plastic"
						entry["default_price"] = 1.50
						entry["color1"] = "white"
						entry["color2"] = ""
						entry["rarity"] = "common"
						
				if entry["scam_type"] == "Wrong Code":
					entry["code"] = Global.create_code(0)
					Global.suspicion += 0.15
			
			data[0] = entry
			if entry["scam_type"] == "No Item":
				shipping_list.erase(i)
			else:			
				shipping_list.erase(i)
				delivered_list.append([data,entry["shippingValue"]])

func get_progress(entry: Array) -> Dictionary:
	var total_time = entry[0]["shippingTime"]
	var elapsed = Global.time_mins - entry[1]
	var percentage = clamp((elapsed / (total_time * 1440)) * 100.0, 0.0, 100.0)

	var status = "Preparing"
	var stage_image = 0
	if percentage >= 100.0:
		status = "Delivered"
		stage_image = 4
	elif percentage >= 75.0:
		status = "Out for Delivery"
		stage_image = 3
	elif percentage >= 50.0:
		status = "In Transit"
		stage_image = 2
	elif percentage >= 25.0:
		status = "Packed"
		stage_image = 1

	return {
		"status": status,
		"stage_image": stage_image,
		"total_time": total_time,
		"percentage": percentage,
	}

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

func push_new_message(old_node, new_node) -> void:
	for entry in mail_user_list:
		var idx = entry[1].find(old_node)
		if idx != -1:
			entry[1].append(new_node)
			return
