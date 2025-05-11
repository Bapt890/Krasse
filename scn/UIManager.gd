extends Node

@onready var label: Label = $HUD/TimerLabel
@onready var resource1 = $HUD/ResourceDisplay/Resource1
@onready var resource2 = $HUD/ResourceDisplay/Resource2
@onready var menu_Button =$HUD/TextureRect2/MenuButton

var total_time := 300.0  # 5 minutes (compte à rebours)

func _ready():
	update_display()
	ResourceManager.resources_updated.connect(update_display)
	menu_Button.pressed.connect(_on_menuButton_pressed)

func update_display():
	$HUD/ResourceDisplay/TextureRectRes1/HBoxContainer/Label.text = "x %d" % ResourceManager.get_resource(0)
	$HUD/ResourceDisplay/TextureRectRes2/HBoxContainer/Label.text = "x %d" % ResourceManager.get_resource(1)

func _process(delta):
	if total_time > 0:
		total_time -= delta
		var minutes = int(total_time) / 60
		var seconds = int(total_time) % 60
		$HUD/TextureRect/Label.text = "%02d:%02d" % [minutes, seconds]
	else:
		$HUD/TextureRect/Label.text = "00:00"
	
func _on_menuButton_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
