extends Node2D

class_name Unit

@export var tilemap : TileMapLayer
var astar = AStarGrid2D.new()

var mouse_hover : bool = false
var is_selected : bool = false

@export var init_pos : Vector2
@export var speed : float = 5.0
@export var team : int = 0
@export var hp : int = 10:
	set(value):
		hp = value
		$Path2D/PathFollow2D/ProgressBarHP.show()
		$Path2D/PathFollow2D/ProgressBarHP.value = value
		if value <= 0:
			die()
var path_position : Vector2

func _ready():
	# Empêche le déplacement de boucler
	$Path2D/PathFollow2D.loop = false
	# Initialiseze astar, l'objet qui gère le pathfinding
	var rect = Rect2i(0, 0, 52, 22)
	astar.region = rect
	astar.cell_size = Vector2i(128, 128)
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	# Indique à astar les tiles qui sont des obstacles
	for cell in tilemap.get_used_cells():
		if tilemap.get_cell_tile_data(cell).get_custom_data("is_solid"):
			astar.set_point_solid(cell, true)
	# HP setup
	$Path2D/PathFollow2D/ProgressBarHP.max_value = hp
	# Team
	$Path2D/PathFollow2D/SpriteSelector.modulate = Color("B51963") if team == 0 else Color("5BA300")
	$Path2D/PathFollow2D/ProgressBarHP.modulate = Color("Pink") if team == 0 else Color("Green")
	if team == 1: 
		$Path2D/PathFollow2D/SpriteUnit.texture = load("res://img/unit/standard_green.png")
		$Path2D/PathFollow2D/Area2DCollider.add_to_group("green")
	$Path2D/PathFollow2D.global_position = init_pos

func _process(delta):
	if  path_position.x - $Path2D/PathFollow2D.global_position.x > 0:
		$Path2D/PathFollow2D/SpriteUnit.flip_h = false
	elif path_position.x - $Path2D/PathFollow2D.global_position.x < 0:
		$Path2D/PathFollow2D/SpriteUnit.flip_h = true
	path_position = $Path2D/PathFollow2D.global_position
	# Sélectionne l'unité si la souris est sur lui et clic gauche relâché
	#if Input.is_action_just_released("select") and mouse_hover:
	#	select()
	$Path2D/PathFollow2D.progress += speed + delta

func _on_mouse_entered():
	mouse_hover = true

func _on_mouse_exited():
	mouse_hover = false

# Créer un chemin en utilisant astar. Place les points du Path2D.
func pathfinding():
	$Path2D.curve.clear_points()
	# Snap la position sur la grille pour éviter des mouvements en diagonale
	$Path2D/PathFollow2D.global_position = tilemap.local_to_map($Path2D/PathFollow2D.global_position) * Vector2i(128, 128) + Vector2i(64, 64)
	var path = astar.get_id_path(tilemap.local_to_map($Path2D/PathFollow2D.global_position), \
		tilemap.local_to_map(get_global_mouse_position()))
	var index = 0
	for pos in path:
		var point_pos = $Path2D/PathFollow2D.global_position - Vector2(64, 64) if index == 0 \
			else pos * tilemap.tile_set.tile_size
		$Path2D.curve.add_point(point_pos)
		index += 1
	# Si le path a plus de 1 point (1 point si clic droit au même endroit), le NPC commence au début du chemin
	if $Path2D.curve.get_baked_length() > 0:
		$Path2D/PathFollow2D.progress_ratio = 0
	

func select_animation():
	$Path2D/PathFollow2D/SpriteSelector.show()
	var tween = create_tween().set_loops()
	tween.tween_property($Path2D/PathFollow2D/SpriteSelector, "modulate:a", 0.75, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Path2D/PathFollow2D/SpriteSelector, "modulate:a", 1, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)

# S'ajoute ou se supprime des unités sélectionnées
func select():
	is_selected = true
	UnitManager.selected_units.append(self)
	select_animation()

func deselect():
	is_selected = false
	UnitManager.selected_units.erase(self)
	$Path2D/PathFollow2D/SpriteSelector.hide()

func hurt(amount : int):
	if $Timer.time_left == 0:
		hp -= amount

func die():
	UnitManager.selected_units.erase(self)
	queue_free()

func _on_area_2d_area_entered(_area):
	if UnitManager.is_selecting:
		select()

func _on_area_2d_area_exited(_area):
	if UnitManager.is_selecting:
		deselect()

# Si l'unité rentre dans l'espace intime d'une autre, elle s'arrête et considère sa case comme solide
# pendant X secondes
func _on_area_2d_collider_area_entered(area : Area2D):
	if area.is_in_group("purple") and team == 1 or area.is_in_group("green") and team == 0:
		die()
	var area_pos = area.global_position
	$Path2D.curve.clear_points()
	astar.set_point_solid(tilemap.local_to_map(area_pos), true)
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout
	astar.set_point_solid(tilemap.local_to_map(area_pos), false)
