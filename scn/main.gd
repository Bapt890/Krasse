extends Node2D

@onready var unit = load("res://scn/unit.tscn")

var selection_rect : Rect2
var select_start_pos : Vector2
var queue : Array[int] = []
var progressbar_hide : bool = false
var hq_advancement : int = 0
var hq_summon_pos : Vector2 = Vector2(1472, 1408)

var hover_detonate : bool = false

func _ready():
	$Base.select.connect(showShop)

func _process(_delta):
	# Si le joueur est en train de sélectionné, dessine le rectangle de sélection et ajuste sa collision
	if UnitManager.is_selecting:
		selection_rect = Rect2(select_start_pos, get_global_mouse_position() - select_start_pos).abs()
		$NinePatchRect.global_position = selection_rect.position
		$NinePatchRect.size = selection_rect.size
		$NinePatchRect/Area2D/CollisionShape2D.global_position = get_global_mouse_position() - (get_global_mouse_position() - select_start_pos) / 2
		$NinePatchRect/Area2D/CollisionShape2D.shape.size = selection_rect.size
	# Met à jour le timer de la barre de tâche
	$UIManager/HUD/PopupShop/VBoxContainerShop/ProgressBarCreationTime.value = \
		$UIManager/HUD/PopupShop/VBoxContainerShop/ProgressBarCreationTime/TimerCreation.time_left if !progressbar_hide else 0
	# Met à jour la file d'attente visuelle
	update_queue_visual()
	shopTextColor()
	UnitManager.hq_selected = true if $UIManager/HUD/PopupShop.visible else false
	$TileMapLayerSelect.hq_summon_pos = hq_summon_pos
	if Input.is_action_just_released("right_click") and UnitManager.hq_selected: hq_summon_pos = get_global_mouse_position()
	
	$UIManager/HUD/MinimapFrame/Minimap.texture = $TileMapLayerSlime.draw_map()
	
	var found_any : bool = false
	for unit in UnitManager.selected_units:
		if unit.variant and unit.hp > 0 and !UnitManager.is_selecting: found_any = true
	if found_any: showBoom()
	else: $UIManager/HUD/ButtonDetonate.hide()

func _input(event):
	# Si clic gauche, arrête la sélection de toutes les unités et indique l'emplacement de la racine du
	# rect de sélection
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and !hover_detonate:
			UnitManager.is_selecting = true
			select_start_pos = get_global_mouse_position()
			$NinePatchRect.position = select_start_pos
			$NinePatchRect.size = Vector2.ZERO
			UnitManager.deselect_all()
		else:
			if UnitManager.is_selecting:
				UnitManager.is_selecting = false
				$NinePatchRect.hide()
	# Si déplacement de la souris alors qu'on est en sélection, affiche le rectangle s'il est suffisament grand
	elif event is InputEventMouseMotion and UnitManager.is_selecting:
		$NinePatchRect.visible = true if selection_rect.size.length() > 5 else false

# Montre la barre de tâche du bâtiment
func showShop():
	$UIManager/HUD/PopupShop.popup()
	$UIManager/HUD/PopupShop.position = Vector2(694, 600)

func showBoom():
	$UIManager/HUD/ButtonDetonate.show()
	$UIManager/HUD/ButtonDetonate.position = Vector2(860, 860)

# Met le texte en rouge si la condition n'est pas remplie, sinon la met en blanc
func shopTextColor():
	var color : Color
	color = setColor(0, 5)
	$UIManager/HUD/PopupShop/VBoxContainerShop/HBoxContainerButtons/VBoxContainerStandard/HBoxContainer/Label.\
		set("theme_override_colors/font_color", color)
	color = setColor(0, 10)
	$UIManager/HUD/PopupShop/VBoxContainerShop/HBoxContainerButtons/VBoxContainerBoom/HBoxContainer/Label.\
		set("theme_override_colors/font_color", color)
	color = setColor(1, 2)
	$UIManager/HUD/PopupShop/VBoxContainerShop/HBoxContainerButtons/VBoxContainerBoom/HBoxContainer2/Label.\
		set("theme_override_colors/font_color", color)
	color = setColor(0, 20)
	$UIManager/HUD/PopupShop/VBoxContainerShop/HBoxContainerButtons/VBoxContainerUpgrade1/HBoxContainer/Label.\
		set("theme_override_colors/font_color", color)
	color = setColor(1, 10)
	$UIManager/HUD/PopupShop/VBoxContainerShop/HBoxContainerButtons/VBoxContainerUpgrade1/HBoxContainer2/Label.\
		set("theme_override_colors/font_color", color)
	color = setColor(0, 50)
	$UIManager/HUD/PopupShop/VBoxContainerShop/HBoxContainerButtons/VBoxContainerUpgrade2/HBoxContainer/Label.\
		set("theme_override_colors/font_color", color)
	color = setColor(1, 25)
	$UIManager/HUD/PopupShop/VBoxContainerShop/HBoxContainerButtons/VBoxContainerUpgrade2/HBoxContainer2/Label.\
		set("theme_override_colors/font_color", color)

func setColor(type : int, comparator : int) -> Color:
	return Color("Red") if ResourceManager.get_resource(type) < comparator else Color("White")

# Place une unité
func create_unit(variant : bool = false):
	var npc : Unit = unit.instantiate()
	npc.team = 0
	npc.init_pos = Vector2(448, 1408)
	npc.tilemap = $TileMapLayer
	npc.tilemap_slime = $TileMapLayerSlime
	npc.position = Vector2(64, 64)
	npc.hq_level = hq_advancement
	npc.variant = variant
	$TileMapLayerSlime/UnitList.add_child(npc)
	npc.pathfinding(hq_summon_pos)

# Relance le timer de la file d'attente
func set_timer(time : int):
	$UIManager/HUD/PopupShop/VBoxContainerShop/ProgressBarCreationTime/TimerCreation.wait_time = time if time != -1 else 0
	$UIManager/HUD/PopupShop/VBoxContainerShop/ProgressBarCreationTime/TimerCreation.start()
	$UIManager/HUD/PopupShop/VBoxContainerShop/ProgressBarCreationTime.max_value = time

# Ajoute un élément à la file d'attente
func queue_add(type : int, time : int):
	if queue.size() >= 10: return
	progressbar_hide = false
	if queue.size() == 0: set_timer(time)
	queue.append(type)

# Met à jour le visuel de la file d'attente
func update_queue_visual():
	var index = 0
	var node : TextureButton
	# Itère tous les objets dans la file d'attente et met la bonne texture sur le bouton correspondant
	for obj in queue:
		index += 1
		node = get_node_or_null("UIManager/HUD/PopupShop/VBoxContainerShop/VBoxContainerQueue/HBoxContainerQueue%s/TextureRectIcon%d" % \
					["" if index < 6 else "2", index - 5 if index >= 6 else index])
		match obj:
			0:
				node.texture_normal = load("res://img/unit/standard_purple.png")
			1:
				node.texture_normal = load("res://img/unit/boom_purple.png")
			2:
				node.texture_normal = load("res://img/building/two_purple.png")
			3:
				node.texture_normal = load("res://img/building/three_purple.png")
	# Tous les boutons non-utilisés prennent la texture de base
	for obj in range(queue.size() + 1, 11):
		node = get_node_or_null("UIManager/HUD/PopupShop/VBoxContainerShop/VBoxContainerQueue/HBoxContainerQueue%s/TextureRectIcon%d" % \
					["" if obj < 6 else "2", obj - 5 if obj >= 6 else obj])
		node.texture_normal = load("res://img/ui/placeholder_queue.png")

# Redonne de la ressource si cliqué. Supprime la position indiquée de la file d'attente.
func update_queue(pos : int = 0, clicked : bool = true):
	if queue.size() > 0 and clicked:
		match queue[pos]:
			0: ResourceManager.addResource(0, 5)
			1: 
				ResourceManager.addResource(0, 10)
				ResourceManager.addResource(1, 2)
			2: 
				ResourceManager.addResource(0, 20)
				ResourceManager.addResource(1, 10)
			3: 
				ResourceManager.addResource(0, 50)
				ResourceManager.addResource(1, 25)
	if queue.size() > pos: 
		queue.remove_at(pos)
		if pos == 0:
			restart_timer()

# Relance le timer selon le prochain objet de la file d'attente. Cache le timer si la file est vide.
func restart_timer():
	if queue.size() > 0:
		match queue[0]:
			0: set_timer(5 - hq_advancement)
			1: set_timer(8 - hq_advancement * 2)
			2: set_timer(15)
			3: set_timer(30)
	else: progressbar_hide = true

# Lorsque le timer s'achève, l'objet correspondant se résoud, il est supprimé de la file, et relance le timer
func _on_timer_timeout():
	if queue.size() > 0:
		match queue[0]:
			0: $TileMapLayerSlime/UnitList.create_unit_player(hq_summon_pos)
			1: $TileMapLayerSlime/UnitList.create_unit_player(hq_summon_pos, true)
			2: 
				hq_advancement = 1
				$Base/Sprite2D.texture = load("res://img/building/two_purple.png")
			3: 
				hq_advancement = 2
				$Base/Sprite2D.texture = load("res://img/building/three_purple.png")
		update_queue(0, false)
		restart_timer()

func _on_button_standard_pressed():
	if ResourceManager.get_resource(0) >= 5 and queue.size() <= 10:
		ResourceManager.substractResource(0, 5)
		queue_add(0, 5 - hq_advancement)

func _on_button_boom_pressed():
	if ResourceManager.get_resource(0) >= 10 and ResourceManager.get_resource(1) >= 2 and queue.size() <= 10:
		ResourceManager.substractResource(0, 10)
		ResourceManager.substractResource(1, 2)
		queue_add(1, 8 - hq_advancement * 2)

func _on_button_upgrade1_pressed():
	if ResourceManager.get_resource(0) >= 20 and ResourceManager.get_resource(1) >= 10 and queue.size() <= 10 \
		and hq_advancement == 0:
		ResourceManager.substractResource(0, 20)
		ResourceManager.substractResource(1, 10)
		queue_add(2, 20)

func _on_button_upgrade2_pressed():
	if ResourceManager.get_resource(0) >= 50 and ResourceManager.get_resource(1) >= 20 and queue.size() <= 10 \
		and hq_advancement == 1:
		ResourceManager.substractResource(0, 50)
		ResourceManager.substractResource(1, 25)
		queue_add(3, 30)

func _on_button_detonate_pressed():
	$UIManager/HUD/ButtonDetonate.hide()
	for unit in UnitManager.selected_units:
		if unit.variant and unit.hp > 0: unit.hp = 0

func _on_texture_button_restart_pressed():
	get_tree().reload_current_scene()

func _on_texture_button_menu_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_button_detonate_mouse_entered():
	hover_detonate = true

func _on_button_detonate_mouse_exited():
	hover_detonate = false
