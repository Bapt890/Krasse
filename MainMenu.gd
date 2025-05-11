extends Node2D

@onready var play_button = $CanvasLayer/HBoxContainer/Jouer
@onready var quit_button = $CanvasLayer/HBoxContainer/Quitter
@onready var credits_button = $CanvasLayer/HBoxContainer/Credits

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scn/Main.tscn") #Remplace le Menu par le Main
	
func _on_quit_pressed():
	get_tree().quit()

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Credits.tscn")
