extends Control

@onready var small_locker = [
	$"doors/5", $"doors/6", $"doors/7", $"doors/8",
	$"doors/9", $"doors/10", $"doors/11", $"doors/12",
	$"doors/13", $"doors/14", $"doors/15", $"doors/16",
	$"doors/17", $"doors/18", $"doors/19", $"doors/20",
	$"doors/21", $"doors/22", $"doors/23", $"doors/25"
]

@onready var medium_locker = [
	$"doors/24", $"doors/26", $"doors/27", $"doors/28"
]

@onready var large_locker = [
	$"doors/1", $"doors/2", $"doors/3", $"doors/4",
	$"doors/29", $"doors/30", $"doors/32"
]

@onready var extralarge_locker = [
	$"doors/31"
]

@onready var locker_parcels = {
	$"doors/1": $"parcels/parcel_1",
	$"doors/2": $"parcels/parcel_2",
	$"doors/3": $"parcels/parcel_3",
	$"doors/4": $"parcels/parcel_4",
	$"doors/5": $"parcels/parcel_5",
	$"doors/6": $"parcels/parcel_6",
	$"doors/7": $"parcels/parcel_7",
	$"doors/8": $"parcels/parcel_8",
	$"doors/9": $"parcels/parcel_9",
	$"doors/10": $"parcels/parcel_10",
	$"doors/11": $"parcels/parcel_11",
	$"doors/12": $"parcels/parcel_12",
	$"doors/13": $"parcels/parcel_13",
	$"doors/14": $"parcels/parcel_14",
	$"doors/15": $"parcels/parcel_15",
	$"doors/16": $"parcels/parcel_16",
	$"doors/17": $"parcels/parcel_17",
	$"doors/18": $"parcels/parcel_18",
	$"doors/19": $"parcels/parcel_19",
	$"doors/20": $"parcels/parcel_20",
	$"doors/21": $"parcels/parcel_21",
	$"doors/22": $"parcels/parcel_22",
	$"doors/23": $"parcels/parcel_23",
	$"doors/24": $"parcels/parcel_24",
	$"doors/25": $"parcels/parcel_25",
	$"doors/26": $"parcels/parcel_26",
	$"doors/27": $"parcels/parcel_27",
	$"doors/28": $"parcels/parcel_28",
	$"doors/29": $"parcels/parcel_29",
	$"doors/30": $"parcels/parcel_30",
	$"doors/31": $"parcels/parcel_31",
	$"doors/32": $"parcels/parcel_32"
}

@onready var label: Control = $InteractionPrompt
var label_shown = false

var chosen_locker

func _ready() -> void:
	label_shown = false
	fill_lockers(ShippingHandler.delivered_list)
	label.hide()


func _process(delta: float) -> void:
	if label_shown and Input.is_action_just_pressed("interact"):
		if ShippingHandler.locker_list.size() > 0:
			Global.first_room = false
			#Global.outside_saved_position = Vector2(100,100)
			get_tree().change_scene_to_file("res://scenes/parcel.tscn")
		else:
			print("No delivered items to collect")

func fill_lockers(list):
	for i in range(list.size() - 1, -1, -1):
		var item = list[i]
				
		if item[1] == 1 or item[1] == 2:
			chosen_locker = small_locker.pick_random()
			ShippingHandler.locker_list.append([item, chosen_locker, item[1]])
		elif item[1] == 3:
			chosen_locker = medium_locker.pick_random()
			ShippingHandler.locker_list.append([item, chosen_locker, item[1]])
		elif item[1] == 4 or item[1] == 5:
			chosen_locker = large_locker.pick_random()
			ShippingHandler.locker_list.append([item, chosen_locker, item[1]])
		elif item[1] > 6:
			chosen_locker = extralarge_locker.pick_random()
			ShippingHandler.locker_list.append([item, chosen_locker, item[1]])
		
		
		list.remove_at(i)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "Player_Detector":
		label_shown = true
		label.show()
		for i in range(ShippingHandler.locker_list.size()):
			if is_instance_valid(ShippingHandler.locker_list[i][1]):
				ShippingHandler.locker_list[i][1].play("default")
				locker_parcels[ShippingHandler.locker_list[i][1]].display_parcel(ShippingHandler.locker_list[i][2])

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.name == "Player_Detector":
		label_shown = false
		label.hide()
		for i in range(ShippingHandler.locker_list.size()):
			if is_instance_valid(ShippingHandler.locker_list[i][1]):
				ShippingHandler.locker_list[i][1].play_backwards("default")
