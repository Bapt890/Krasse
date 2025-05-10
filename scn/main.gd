extends Node2D

@onready var unit = load("res://scn/unit.tscn")

var selection_rect : Rect2
var select_start_pos : Vector2

func _ready():
	var unit_instance = unit.instantiate()
	unit_instance.position = Vector2(64, 64)
	unit_instance.tilemap = $TileMapLayer
	add_child(unit_instance)

func _process(delta):
	if Global.is_selecting:
		selection_rect = Rect2(select_start_pos, get_global_mouse_position() - select_start_pos).abs()
		$NinePatchRect.position = selection_rect.position
		$NinePatchRect.size = selection_rect.size
		$NinePatchRect/Area2D/CollisionShape2D.position = select_start_pos - (select_start_pos - get_global_mouse_position().abs())
		$NinePatchRect/Area2D/CollisionShape2D.shape.size = selection_rect.size

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Global.is_selecting = true
				select_start_pos = get_global_mouse_position()
				$NinePatchRect.position = select_start_pos
				$NinePatchRect.size = Vector2.ZERO
			else:
				if Global.is_selecting:
					Global.is_selecting = false
					$NinePatchRect.hide()
	elif event is InputEventMouseMotion:
		if Global.is_selecting:
			$NinePatchRect.visible = true if selection_rect.size.length() > 32 else false
