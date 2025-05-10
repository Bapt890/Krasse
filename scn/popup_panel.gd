extends PopupPanel

@onready var unit1_button = $HBoxContainer/Unit1
@onready var unit2_button = $HBoxContainer/Unit2
@onready var cancel_button = $HBoxContainer/Cancel

func _ready(): # Fonction associé aux boutons du popup
	unit1_button.pressed.connect(_on_unit1_pressed)
	unit2_button.pressed.connect(_on_unit2_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

func _on_unit1_pressed():
	print("1 ok")

func _on_unit2_pressed():
	print("2 ok")

func _on_cancel_pressed():
	hide()
