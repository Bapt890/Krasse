extends Node2D

@onready var return_button = $CanvasLayer/Retour

func _ready():
	return_button.pressed.connect(_on_return_pressed)
	
func _on_return_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
