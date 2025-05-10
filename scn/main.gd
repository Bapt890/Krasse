extends Node2D

@onready var unit = load("res://scn/unit.tscn")

var selection_rect : Rect2
var select_start_pos : Vector2

func _process(_delta):
	# Si le joueur est en train de sélectionné, dessine le rectangle de sélection et ajuste sa collision
	if UnitManager.is_selecting:
		selection_rect = Rect2(select_start_pos, get_global_mouse_position() - select_start_pos).abs()
		$NinePatchRect.global_position = selection_rect.position
		$NinePatchRect.size = selection_rect.size
		$NinePatchRect/Area2D/CollisionShape2D.global_position = get_global_mouse_position() - (get_global_mouse_position() - select_start_pos) / 2
		$NinePatchRect/Area2D/CollisionShape2D.shape.size = selection_rect.size
		

func _input(event):
	# Si clic gauche, arrête la sélection de toutes les unités et indique l'emplacement de la racine du
	# rect de sélection
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			UnitManager.is_selecting = true
			UnitManager.deselect_all()
			select_start_pos = get_global_mouse_position()
			$NinePatchRect.position = select_start_pos
			$NinePatchRect.size = Vector2.ZERO
		else:
			if UnitManager.is_selecting:
				UnitManager.is_selecting = false
				$NinePatchRect.hide()
	# Si déplacement de la souris alors qu'on est en sélection, affiche le rectangle s'il est suffisament grand
	elif event is InputEventMouseMotion and UnitManager.is_selecting:
		$NinePatchRect.visible = true if selection_rect.size.length() > 5 else false
