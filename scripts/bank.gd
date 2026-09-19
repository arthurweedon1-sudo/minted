extends Control

@onready var smallLoanButton1: TextureButton = %loanButton1
@onready var smallLoanButton2: TextureButton = %loanButton2
@onready var smallLoanButton3: TextureButton = %loanButton3

@onready var amountNumber: Label = %amountNumber
@onready var interestNumber: Label = %interestNumber
@onready var repayNumber: Label = %repayNumber

var current_popup: String = "none"

var loan_value: int = 0
var loan_interest: float = 0.0
var loan_days: int = 0
var min_rep = 0
var invest_request: float = 0.0

var selected: String = ""
var invest_selected: int = 1

var ls1 = false
var ls2 = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.bank = true

	if Global.invested:
		%investButton.disabled = true
	else:
		%investButton.disabled = false
	%loan.hide()
	%popupBack.hide()
	
	if 10 in Global.skill_tree_unlocked:
		ls1 = true
		$popup/loan/loanButtonLS1S/background/lock.hide()
		$popup/loan/loanButtonLS1L/background/lock.hide()
	else:
		ls1 = false
		$popup/loan/loanButtonLS1S/background/text.hide()
		$popup/loan/loanButtonLS1L/background/text2.hide()
	
	
	if 27 in Global.skill_tree_unlocked:
		ls2 = true
		$popup/loan/loanButtonLS2S/background/lock.hide()
		$popup/loan/loanButtonLS2L/background/lock.hide()
	else:
		ls2 = false
		$popup/loan/loanButtonLS2S/background/text2.hide()
		$popup/loan/loanButtonLS2L/background/text2.hide()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.invested and Global.future != null:
		if Global.days_until(Global.future["day"], Global.future["month"], Global.future["year"]) == 0:
			Global.invested = false
			Global.invest_claimed = false
		else:
			%investButtonLabel.text = str(Global.days_until(Global.future["day"], Global.future["month"], Global.future["year"])) + " days"
	if Global.invest_claimed == false:
		%investButtonLabel.text = "Claim"
	elif !Global.invested:
		%investButtonLabel.text = "Invest"
	if current_popup != "none":
		%popupBack.show()
		%popup.show()
	else:
		%popupBack.hide()
		%popup.hide()
	if current_popup == "loan":
		%loan.show()
		%invest.hide()
		if selected == "small":
			loan_value =  100
			loan_interest = 5.0
			loan_days = 2
			min_rep = 2
		elif selected == "medium":
			loan_value =  500
			loan_interest = 12.0
			loan_days = 5
			min_rep = 3
		elif selected == "large":
			loan_value =  2000
			loan_interest = 25.0
			loan_days = 10
			min_rep = 4
		elif selected == "ls1s":
			loan_value =  250
			loan_interest = 10.0
			loan_days = 5
			min_rep = 3
		elif selected == "ls1l":
			loan_value =  750
			loan_interest = 10.0
			loan_days = 5
			min_rep = 4
		elif selected == "ls2s":
			loan_value =  2500
			loan_interest = 20.0
			loan_days = 11
			min_rep = 3
		elif selected == "ls2l":
			loan_value =  7500
			loan_interest = 20.0
			loan_days = 11
			min_rep = 4
		else:
			loan_value =  0
			loan_interest = 0.0
			loan_days = 0
		
		amountNumber.text = "$" + str(loan_value)
		interestNumber.text = str(loan_interest) + "%"
		repayNumber.text = str(loan_days) + " rent days"
		%min_rep_number.text = str(min_rep) + " (" + str(Global.player_rating) + ")"
	elif current_popup == "invest":
		%invest.show()
		%loan.hide()
	elif current_popup == "none":
		%loan.hide()
		%invest.hide()
	
	
func _on_close_pressed() -> void:
	AudioManager.bank = false
	get_tree().change_scene_to_file("res://scenes/outside.tscn")


func _on_loan_button_1_pressed() -> void:
	selected = "small"


func _on_loan_button_1_mouse_entered() -> void:
	smallLoanButton1.modulate.a = 0.7


func _on_loan_button_1_mouse_exited() -> void:
	smallLoanButton1.modulate.a = 1.0


func _on_loan_button_2_pressed() -> void:
	selected = "medium"


func _on_loan_button_2_mouse_entered() -> void:
	smallLoanButton2.modulate.a = 0.7


func _on_loan_button_2_mouse_exited() -> void:
	smallLoanButton2.modulate.a = 1.0


func _on_loan_button_3_pressed() -> void:
	selected = "large"


func _on_loan_button_3_mouse_entered() -> void:
	smallLoanButton3.modulate.a = 0.7


func _on_loan_button_3_mouse_exited() -> void:
	smallLoanButton3.modulate.a = 1.0


func _on_confirm_button_pressed() -> void:
	if Global.loan_info == [0,0,0] and min_rep < Global.player_rating:
		Global.money += loan_value
		Global.loan_info[0] = loan_value 
		Global.loan_info[1] = loan_days
		Global.loan_info[2] = loan_interest * Global.loan_mult
		%confirmButtonLabel.text = "CONFIRMED"
		await get_tree().create_timer(3.0).timeout
		%confirmButtonLabel.text = "Confirm"
	elif min_rep < Global.player_rating:
		%landlord_text.text = "Sorry, your reputation is too low, we can't give you this loan."
		%landlord_text2.text = "Sorry, your reputation is too low, we can't give you this loan."
	else:
		%landlord_text.text = "You already have a loan in progress!"
		%landlord_text2.text = "You already have a loan in progress!"
		
func _on_confirm_button_mouse_entered() -> void:
	%confirmButton.modulate.a = 0.7


func _on_confirm_button_mouse_exited() -> void:
	%confirmButton.modulate.a = 1.0


func _on_popup_back_pressed() -> void:
	current_popup = "none"


func _on_texture_button_pressed() -> void:
	current_popup = "loan"


func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		%bars.play("1")
		invest_selected = 1
		%lv1_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv2_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv3_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv4_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv5_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv6_inv_num.add_theme_color_override("font_color", Color.html("806847"))
	elif index == 1:
		%bars.play("2")
		invest_selected = 2
		%lv1_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv2_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv3_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv4_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv5_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv6_inv_num.add_theme_color_override("font_color", Color.html("806847"))
	elif index == 2:
		%bars.play("3")
		invest_selected = 3
		%lv1_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv2_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv3_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv4_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv5_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv6_inv_num.add_theme_color_override("font_color", Color.html("806847"))
	elif index == 3:
		%bars.play("4")
		invest_selected = 4
		%lv1_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv2_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv3_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv4_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv5_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv6_inv_num.add_theme_color_override("font_color", Color.html("806847"))
	else:
		%bars.play("5")
		invest_selected = 5
		%lv1_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv2_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv3_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv4_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv5_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv6_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))

func _on_option_button_item_focused(index: int) -> void:
	if index == 0:
		%bars.play("1")
		invest_selected = 1
		%lv1_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv2_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv3_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv4_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv5_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv6_inv_num.add_theme_color_override("font_color", Color.html("806847"))
	elif index == 1:
		%bars.play("2")
		invest_selected = 2
		%lv1_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv2_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv3_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv4_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv5_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv6_inv_num.add_theme_color_override("font_color", Color.html("806847"))
	elif index == 2:
		%bars.play("3")
		invest_selected = 3
		%lv1_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv2_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv3_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv4_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv5_inv_num.add_theme_color_override("font_color", Color.html("806847"))
		%lv6_inv_num.add_theme_color_override("font_color", Color.html("806847"))
	elif index == 3:
		%bars.play("4")
		invest_selected = 4
		%lv1_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv2_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv3_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv4_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv5_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv6_inv_num.add_theme_color_override("font_color", Color.html("806847"))
	else:
		%bars.play("5")
		invest_selected = 5
		%lv1_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv2_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv3_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv4_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv5_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))
		%lv6_inv_num.add_theme_color_override("font_color", Color.html("ffffff"))

func invest_calc(money, option):
	if option == 1:
		return snapped(money * (1.025+Global.interest_boost*option), 0.001)
	elif option == 2:
		return snapped(money * (1.055+Global.interest_boost*option), 0.001)
	elif option == 3:
		return snapped(money * (1.12+Global.interest_boost*option), 0.001)
	elif option == 4:
		return snapped(money * (1.25+Global.interest_boost*option), 0.001)
	elif option == 5:
		return snapped(money * (1.40+Global.interest_boost*option), 0.001)
		

func _on_invest_money_text_changed(new_text: String) -> void:
	var regex := RegEx.new()
	regex.compile("^-?\\d*\\.?\\d{0,2}$")
	if not regex.search(new_text):
		var caret : int = %investMoney.caret_column
		%investMoney.text = new_text.substr(0, new_text.length() - 1)
		%investMoney.caret_column = caret - 1
		return

	if new_text.is_valid_float():
		var value: float = new_text.to_float()
		invest_request = new_text.to_float()
		%lv1_inv_num.text = "$" + str(value)
		%lv2_inv_num.text = "$" + str(invest_calc(value, 1))
		%lv3_inv_num.text = "$" + str(invest_calc(value, 2))
		%lv4_inv_num.text = "$" + str(invest_calc(value, 3))
		%lv5_inv_num.text = "$" + str(invest_calc(value, 4))
		%lv6_inv_num.text = "$" + str(invest_calc(value, 5))


func _on_texture_button_2_pressed() -> void:
	current_popup = "invest"

func _on_invest_button_pressed() -> void:
	if Global.money >= invest_request and Global.invest_claimed and Global.max_investment >= invest_request:
		Global.money -= invest_request
		%investButton.disabled = true
		if invest_selected == 1:
			Global.future = Global.add_to_date(7, 0)
			Global.bank_money += invest_calc(invest_request, 1)
		elif invest_selected == 2:
			Global.future = Global.add_to_date(14,0)
			Global.bank_money += invest_calc(invest_request, 2)
		elif invest_selected == 3:
			Global.future = Global.add_to_date(0,1)
			Global.bank_money += invest_calc(invest_request, 3)
		elif invest_selected == 4:
			Global.future = Global.add_to_date(0,2)
			Global.bank_money += invest_calc(invest_request, 4)
		elif invest_selected == 5:
			Global.future = Global.add_to_date(0,3)
			Global.bank_money += invest_calc(invest_request, 5)
		Global.invested = true
	
	elif Global.max_investment <= invest_request:
		%landlord_text.text = "Sorry, you can only invest a maximum of $ " + str(Global.max_investment) + ".00."
		%landlord_text2.text = "Sorry, you can only invest a maximum of $ " + str(Global.max_investment) + ".00."
		
	elif Global.invest_claimed == false:
		Global.money += Global.bank_money
		Global.bank_money = 0
		Global.invest_claimed = true


func _on_option_button_pressed() -> void:
	var texts = ["One week", "Two weeks", "One month", "Two months", "Three months"]
	for i in range(5):
		$popup/invest/OptionButton.set_item_text(i,texts[i]+" "+str(invest_calc(100,i+1)-100)+"%")


func _on_loan_button_ls_1s_pressed() -> void:
	if ls1:
		selected = "ls1s"



func _on_loan_button_ls_1l_pressed() -> void:
	if ls1:
		selected = "ls1l"


func _on_loan_button_ls_2s_pressed() -> void:
	if ls2:
		selected = "ls2s"


func _on_loan_button_ls_2l_pressed() -> void:
	if ls2:
		selected = "ls2s" 
