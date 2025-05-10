extends Node2D

class_name Unit

var tilemap : TileMapLayer

var mouse_hover : bool = false
var is_selected : bool = false

var astar = AStarGrid2D.new()
var speed : float = 5.0

func _ready():
	# Empêche le déplacement de boucler
	$Path2D/PathFollow2D.loop = false
	# Initialiseze astar, l'objet qui gère le pathfinding
	astar.region = Rect2i(0, 0, 9, 5)
	astar.cell_size = Vector2i(128, 128)
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	# Indique à astar les tiles qui sont des obstacles
	for cell in tilemap.get_used_cells():
		if tilemap.get_cell_tile_data(cell).get_custom_data("is_solid"):
			astar.set_point_solid(cell, true)

func _process(delta):
	# Sélectionne l'unité si la souris est sur lui et clic gauche relâché
	if Input.is_action_just_released("select") and mouse_hover:
		select()
	$Path2D/PathFollow2D.progress += speed + delta

func _on_mouse_entered():
	mouse_hover = true

func _on_mouse_exited():
	mouse_hover = false

# Si sélectionné et clic droit, déplacement
func _unhandled_input(event):
	if event is InputEventMouseButton:
		# Si Clic droit relâché, est sélectionné, et pas en train de clic gauche (pour la sélection)
		if event.button_index == MOUSE_BUTTON_RIGHT and is_selected and \
		event.is_released() and !Input.is_action_pressed("select"):
			pathfinding()

# Créer un chemin en utilisant astar. Place les points du Path2D.
func pathfinding():
	$Path2D.curve.clear_points()
	var path = astar.get_id_path(tilemap.local_to_map($Path2D/PathFollow2D.position), \
		tilemap.local_to_map(get_global_mouse_position()))
	var index = 0
	for pos in path:
		if index == 0:
			$Path2D.curve.add_point($Path2D/PathFollow2D.position)
		else:
			$Path2D.curve.add_point(pos * tilemap.tile_set.tile_size)
		index += 1
	# Si le path a plus de 1 point (1 point si clic droit au même endroit), le NPC commence au début du chemin
	if $Path2D.curve.get_baked_length() > 0:
		$Path2D/PathFollow2D.progress_ratio = 0

func select():
	is_selected = true
	UnitManager.selected_units.append(self)
	$AnimationPlayer.play("selector_ring")

func deselect():
	is_selected = false
	UnitManager.selected_units.erase(self)
	$AnimationPlayer.stop()
	$Path2D/PathFollow2D/SpriteSelector.hide()

func _on_area_2d_area_entered(area):
	if area.is_in_group("selector") and Global.is_selecting:
		select()

func _on_area_2d_area_exited(area):
	if area.is_in_group("selector") and Global.is_selecting:
		deselect()
