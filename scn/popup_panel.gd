extends PopupPanel

@onready var unit1_button = $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Unit1
@onready var unit2_button = $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/Unit2
@onready var cancel_button = $HBoxContainer/Cancel

@export var amount : int
@export var type : int

func _ready(): # Fonction associé aux boutons du popup
	unit1_button.pressed.connect(_on_unit1_pressed)
	unit2_button.pressed.connect(_on_unit2_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

func _on_unit1_pressed():
	if ResourceManager.resources[0] >= 5:
		buy_unit(0, 5)

func _on_unit2_pressed():
	if ResourceManager.resources[0] >= 10 and ResourceManager.resources[1] >= 2:
		buy_unit(0, 10)
		buy_unit(1, 2)

func _on_cancel_pressed():
	hide()

func buy_unit(type : int, cost: int):
	if ResourceManager.resources[type] >= cost:
		ResourceManager.substractResource(type, cost)
