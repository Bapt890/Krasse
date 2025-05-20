extends Node

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
		var minutes = total_time / 60
		var seconds = fmod(total_time, 60)
		$HUD/TextureRect/Label.text = "%02d:%02d" % [minutes, seconds]
	else:
		$HUD/TextureRect/Label.text = "00:00"
	
	if total_time <= 0 and !$HUD/EndScreen.visible:
		$HUD/EndScreen.show()
		$HUD/EndScreen/ColorRect/VBoxContainer/ColorRect/MapRect.texture = $HUD/MinimapFrame/Minimap.texture
		$HUD/EndScreen/ColorRect/VBoxContainer/HBoxContainer/LabelPurple.text = $HUD/HBoxContainer/LabelPurple.text
		$HUD/EndScreen/ColorRect/VBoxContainer/HBoxContainer/LabelGreen.text = $HUD/HBoxContainer/LabelGreen.text
		$HUD/EndScreen/ColorRect/VBoxContainer/LabelResult.text = "Vous avez gagne !" \
			if int($HUD/EndScreen/ColorRect/VBoxContainer/HBoxContainer/LabelPurple.text) > int($HUD/EndScreen/ColorRect/VBoxContainer/HBoxContainer/LabelGreen.text) \
			else "Vous avez perdu !"
		var tween = create_tween()
		tween.tween_property($HUD/EndScreen, "modulate:a", 1, 0.5)
	
func _on_menuButton_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
