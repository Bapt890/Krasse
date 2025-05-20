extends Node2D

class_name Unit

@export var tilemap : TileMapLayer
var tilemap_slime : TileMapLayer
var astar = AStarGrid2D.new()
var puddle_object = load("res://scn/death_puddle.tscn")
var idle_pos : Vector2 = Vector2.ZERO

var mouse_hover : bool = false
var is_selected : bool = false

@export var init_pos : Vector2
@export var speed : float = 5.0
@export var team : int = 0
@export var hp : int = 10:
	set(value):
		hp = value
		$Path2D/PathFollow2D/ProgressBarHP.value = value
		if value <= 0:
			die()
var path_position : Vector2
@export var variant : bool = false
var hq_level : int = 0

@onready var timer = $Timer

signal explode(pos : Vector2, team : int)

#AI var
var role_dict : Dictionary = {"gatherer" : 0, "scout" : 1, "infect" : 2, "boomer" : 3, "assassin" : 4}
var role : int = 0
var is_idle : bool = true
var target : Unit

func _ready():
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
	$Path2D/PathFollow2D/ProgressBarHP.max_value = hp + hq_level * hp
	# Team
	$Path2D/PathFollow2D/SpriteSelector.modulate = Color("B51963") if team == 0 else Color("5BA300")
	$Path2D/PathFollow2D/ProgressBarHP.modulate = Color("Pink") if team == 0 else Color("Green")
	if team == 1: 
		$Path2D/PathFollow2D/SpriteUnit.texture = load("res://img/unit/standard_green.png")
		if variant: $Path2D/PathFollow2D/SpriteUnit.texture = load("res://img/unit/boom_green.png")
		$Path2D/PathFollow2D/Area2DCollider.add_to_group("green")
	elif team == 0:
		if variant: $Path2D/PathFollow2D/SpriteUnit.texture = load("res://img/unit/boom_purple.png")
		$Path2D/PathFollow2D/Area2DCollider.add_to_group("purple")
	$Path2D/PathFollow2D.global_position = init_pos
	if variant:
		speed = 4
		hp = 20
		$Path2D/PathFollow2D/ProgressBarHP.max_value = 20
	speed += hq_level
	hp += hq_level * hp

func _process(delta):
	if path_position.x - $Path2D/PathFollow2D.global_position.x > 0:
		$Path2D/PathFollow2D/SpriteUnit.flip_h = false
	elif path_position.x - $Path2D/PathFollow2D.global_position.x < 0:
		$Path2D/PathFollow2D/SpriteUnit.flip_h = true
	if path_position.x == idle_pos.x: is_idle = true
	else: is_idle = false
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
func pathfinding(target_pos : Vector2 = Vector2.ZERO):
	is_idle = false
	var new_target = target_pos if target_pos != Vector2.ZERO else get_global_mouse_position()
	$Path2D.curve.clear_points()
	# Snap la position sur la grille pour éviter des mouvements en diagonale
	$Path2D/PathFollow2D.global_position = tilemap.local_to_map($Path2D/PathFollow2D.global_position) * Vector2i(128, 128) + Vector2i(64, 64)
	var path = astar.get_id_path(tilemap.local_to_map($Path2D/PathFollow2D.global_position), \
		tilemap.local_to_map(new_target))
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
	if team == 0:
		is_selected = true
		UnitManager.selected_units.append(self)
		select_animation()

func deselect():
	is_selected = false
	UnitManager.selected_units.erase(self)
	$Path2D/PathFollow2D/SpriteSelector.hide()

func hurt(amount : int):
	if timer.time_left == 0:
		hp -= amount
		$Path2D/PathFollow2D/ProgressBarHP.show()

func die():
	var puddle = puddle_object.instantiate()
	if variant:
		puddle.variant = true
		$Path2D/PathFollow2D/Area2DCollider.add_to_group("purple")
		$Path2D/PathFollow2D/Area2DCollider.add_to_group("green")
		if team == 0:
			$Path2D/PathFollow2D/SpriteUnit/AnimationPlayer.play("explode")
		else:
			$Path2D/PathFollow2D/SpriteUnit/AnimationPlayer.play("explode_g")
		await $Path2D/PathFollow2D/SpriteUnit/AnimationPlayer.animation_finished
		emit_signal("explode", path_position, team)
	if team == 1: puddle.is_green = true
	puddle.position = path_position
	get_parent().get_parent().add_child(puddle)
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
# Si l'unité rencontrée est dans l'autre team, ELLE MEURT
func _on_area_2d_collider_area_entered(area : Area2D):
	if area.is_in_group("purple") and team == 1 or area.is_in_group("green") and team == 0:
		hp = 0
	var area_pos = area.global_position
	$Path2D.curve.clear_points()
	astar.set_point_solid(tilemap.local_to_map(area_pos), true)
	var time = Timer.new()
	time.wait_time = 3.0
	time.one_shot = true
	add_child(time)
	time.start()
	await time.timeout
	astar.set_point_solid(tilemap.local_to_map(area_pos), false)

func _on_timer_update_role_timeout():
	idle_pos = path_position
	if role == role_dict["assassin"] and target != null and !is_idle: pathfinding(target.path_position)
	elif role == role_dict["assassin"]:
		if target == null:
			for unit : Unit in get_parent().get_children():
				if unit.team == 0:
					if unit.variant:
						if randi_range(0, 3) < 3:
							target = unit
					else:
						if randi_range(0, 3) == 3:
							target = unit
	if role == role_dict["scout"] and is_idle:
		var cell = tilemap_slime.get_used_cells()[randi_range(0, tilemap_slime.get_used_cells().size() - 1)]
		if tilemap_slime.get_cell_tile_data(cell).get_custom_data("team") != 1: 
			pathfinding(Vector2(cell.x * 128, cell.y * 128))
