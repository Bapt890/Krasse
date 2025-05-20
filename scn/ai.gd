extends Node

@export var spawners : Array[Vector2]
@export var tilemap : TileMapLayer
@export var tilemap_slime : TileMapLayer
@export var timer : Timer
@onready var unit_obj = load("res://scn/Unit.tscn")
@export var game_timer : Node
@export var hq : Area2D

var hq_level : int = 0

# Donne des ordres aux unités initiales
func _ready():
	$UnitGreen.pathfinding(spawners[0])
	$UnitGreen3.pathfinding(spawners[2])
	$UnitGreen4.pathfinding(spawners[3])
	$UnitGreen2.role = $UnitGreen2.role_dict["assassin"]
	$UnitGreen2.target = $Unit

func _process(_delta):
	# Indique aux récolteurs d'aller sur une autre case du spawner s'il est contesté ; Sert à tuer l'unité du joueur
	for unit : Unit in get_children():
		if unit.role != unit.role_dict["gatherer"] or unit.team == 0 or !unit.is_idle: continue
		if unit.path_position == spawners[0] and get_spawners_state()[0] == 3: unit.pathfinding(spawners[1])
		elif unit.path_position == spawners[1] and get_spawners_state()[1] == 3: unit.pathfinding(spawners[0])
		elif unit.path_position == spawners[4] and get_spawners_state()[4] == 3: unit.pathfinding(spawners[5])
		elif unit.path_position == spawners[5] and get_spawners_state()[5] == 3: unit.pathfinding(spawners[6])
		elif unit.path_position == spawners[6] and get_spawners_state()[6] == 3: unit.pathfinding(spawners[7])
		elif unit.path_position == spawners[7] and get_spawners_state()[7] == 3: unit.pathfinding(spawners[4])
		elif unit.path_position == spawners[10] and get_spawners_state()[10] == 3: unit.pathfinding(spawners[11])
		elif unit.path_position == spawners[11] and get_spawners_state()[11] == 3: unit.pathfinding(spawners[10])
	for unit : Unit in get_children():
		if unit.role == unit.role_dict["boomer"] and unit.team == 1:
			for i in range(spawners.size()):
				if get_spawners_state()[i] == 1: unit.pathfinding(spawners[i])
	if game_timer.total_time <= 180 and hq_level == 0: 
		hq_level = 1
		hq.get_node("Sprite2D").texture = load("res://img/building/two_green.png")
	if game_timer.total_time <= 60 and hq_level == 1: 
		hq_level = 2
		hq.get_node("Sprite2D").texture = load("res://img/building/three_green.png")

# Place une unité
func create_unit():
	var spawner_array = get_spawners_state()
	var spawn_count : Array[int] = [spawner_array.count(1), spawner_array.count(2)]
	
	var npc : Unit = unit_obj.instantiate()
	npc.team = 1
	npc.init_pos = Vector2(6208, 1408)
	npc.tilemap = tilemap
	npc.tilemap_slime = tilemap_slime
	npc.position = Vector2(64, 64)
	npc.hq_level = hq_level
	
	var random = 0
	if spawn_count[1] >= 3 and spawn_count[1] < 5: random = 4
	elif spawn_count[1] >= 5: random = 2
	if random > 0 and randi_range(0, random) == random: npc.variant = true
	
	npc.role = npc.role_dict[unit_role(spawn_count, npc.variant)]
	if npc.role == npc.role_dict["assassin"]:
		while npc.target == null:
			for unit : Unit in get_children():
				if unit.variant:
					if randi_range(0, 3) < 3:
						npc.target = unit
				else:
					if randi_range(0, 3) == 3:
						npc.target = unit
	add_child(npc)
	# Déplace le récolteur sur un spawner inoccupé.
	# Les spawners dans les if vont du plus éloigné au plus proche, pour favoriser que l'unité aille sur le plus proche
	if npc.role == npc.role_dict["gatherer"]:
		if get_spawners_state()[10] != 2 and get_spawners_state()[11] != 2: npc.pathfinding(spawners[randi_range(10, 11)])
		if get_spawners_state()[9] != 2: npc.pathfinding(spawners[9])
		if get_spawners_state()[8] != 2: npc.pathfinding(spawners[8])
		if get_spawners_state()[4] != 2 and get_spawners_state()[5] != 2 and \
			get_spawners_state()[6] != 2 and get_spawners_state()[7] != 2: npc.pathfinding(spawners[randi_range(4, 7)])
		if get_spawners_state()[3] != 2: npc.pathfinding(spawners[3])
		if get_spawners_state()[2] != 2: npc.pathfinding(spawners[2])
		if get_spawners_state()[0] != 2 and get_spawners_state()[1] != 2: npc.pathfinding(spawners[randi_range(0, 1)])

# Place une unité
func create_unit_player(pos : Vector2, variant : bool = false):
	var npc : Unit = unit_obj.instantiate()
	npc.team = 0
	npc.init_pos = Vector2(448, 1408)
	npc.tilemap = tilemap
	npc.tilemap_slime = tilemap_slime
	npc.position = Vector2(64, 64)
	npc.hq_level = hq_level
	npc.variant = variant
	add_child(npc)
	npc.pathfinding(pos)

# Assigne un rôle à l'unité selon les spawners occupé et si c'est un boom
func unit_role(spawn_count : Array[int], variant : bool = false) :
	var random = [0, 0]
	if !variant:
		if spawn_count[1] < 3: random[0] = 7
		elif spawn_count[1] == 3 or spawn_count[1] == 4: random[0] = 5
		elif spawn_count[1] >= 5: random[0] = 2
		random[1] = 10 - random[0]
		if random[0] > random[1]:
			if randi_range(random[1], random[0]) == random[0]:
				return "scout"
		else:
			if randi_range(random[0], random[1]) == random[1]:
				return "scout"
	else:
		if spawn_count[0] >= 5: return "boomer"
		elif spawn_count[0] == 1 or spawn_count[0] == 2: random[1] = 4
		elif spawn_count[0] == 3 or spawn_count[0] == 4: random[1] = 1
		if random[1] > 0 and randi_range(0, random[1]) == random[1]: return "boomer"
		else: return "assassin"
	return "gatherer"

# Indique si les spawners sont libres (0), occupés par le joueur (1) ou par l'IA (2) (de droite à gauche)
func get_spawners_state() -> Array[int]:
	var pos_array : Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	for unit : Unit in get_children():
		var index = 0
		for spawner_pos in spawners:
			if unit.path_position != spawner_pos:
				index += 1
				continue
			pos_array[index] = unit.team + 1
			index += 1
	# Indique si les spawners sont contestés
	if pos_array[0] == 2 and pos_array[1] == 1: pos_array[0] = 3
	if pos_array[0] == 1 and pos_array[1] == 2: pos_array[1] = 3
	if pos_array[4] == 2 and (pos_array[5] == 1 or pos_array[6] == 1 or pos_array[7] == 1): pos_array[4] = 3
	if pos_array[5] == 2 and (pos_array[4] == 1 or pos_array[6] == 1 or pos_array[7] == 1): pos_array[5] = 3
	if pos_array[6] == 2 and (pos_array[4] == 1 or pos_array[5] == 1 or pos_array[7] == 1): pos_array[6] = 3
	if pos_array[7] == 2 and (pos_array[4] == 1 or pos_array[5] == 1 or pos_array[6] == 1): pos_array[7] = 3
	if pos_array[10] == 2 and pos_array[11] == 1: pos_array[10] = 3
	if pos_array[10] == 1 and pos_array[11] == 2: pos_array[11] = 3
	return pos_array

func _on_timer_respawn_unit_timeout():
	create_unit()
	get_parent().get_node("TimerRespawnUnit").start(7-hq_level)
