extends PopupPanel

@onready var unit1_button = $HBoxContainer/Unit1
@onready var unit2_button = $HBoxContainer/Unit2
@onready var cancel_button = $HBoxContainer/Cancel

@export var amount : int
@export var type : int

func _ready(): # Fonction associé aux boutons du popup
	unit1_button.pressed.connect(_on_unit1_pressed)
	unit2_button.pressed.connect(_on_unit2_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

func _on_unit1_pressed():
	var cost = 3
	type = 0
	buy_unit(type, cost)

func _on_unit2_pressed():
	var cost = 3
	type = 1
	buy_unit(type, cost)

func _on_cancel_pressed():
	hide()

func buy_unit(type : int, cost: int):
	if ResourceManager.resources[type] >= cost:
		ResourceManager.substractResource(type, cost)
