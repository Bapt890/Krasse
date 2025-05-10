extends StaticBody2D

@onready var popup = get_node("/root/Node2D/PopupPanel")

@export var faction : int = Factions.FACTION_PLAYER

func _input_event(viewport, event, shape_idx): #Fonction créant un popup sur clic gauche d'un batiment
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		popup.position = Vector2(500, 500) #Position du popup
		popup.popup()
