extends PopupPanel

@onready var unit1_button = $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Unit1
@onready var unit2_button = $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/Unit2
@onready var cancel_button = $VBoxContainer/HBoxContainer/Cancel

signal buy(type : int)

func _ready(): # Fonction associé aux boutons du popup
	unit1_button.pressed.connect(_on_unit1_pressed)
	unit2_button.pressed.connect(_on_unit2_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

func _process(_delta):
	$VBoxContainer/ProgressBar.value = $Timer.time_left
	$VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/HBoxContainer/Label.\
		set("theme_override_colors/font_color", Color("Red"))

func _on_unit1_pressed():
	if $Timer.time_left == 0:
		if ResourceManager.resources[0] >= 5:
			buy_unit(0, 5, 0)

func _on_unit2_pressed():
	if $Timer.time_left == 0:
		if ResourceManager.resources[0] >= 10 and ResourceManager.resources[1] >= 2:
			buy_unit(0, 10, 1)
			buy_unit(1, 2)

func _on_cancel_pressed():
	hide()

func buy_unit(unit_type : int, cost: int, article : int = -1):
	if ResourceManager.resources[unit_type] >= cost:
		$Timer.start()
		ResourceManager.substractResource(unit_type, cost)
		emit_signal("buy", article)
