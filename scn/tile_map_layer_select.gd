extends TileMapLayer

var hq_summon_pos : Vector2 = Vector2.ZERO

func _process(_delta):
	# Si une unité est sélectionnée, met le tile de sélection sur l'emplacement 
	# de la souris en respectant la grille. Efface les sélections précédentes.
	for cell in get_used_cells():
		erase_cell(cell)
	if (UnitManager.selected_units.size() >= 1 or UnitManager.hq_selected) and !UnitManager.is_selecting:
		set_cell(local_to_map(get_global_mouse_position()), 2, Vector2i(0, 0))
	if UnitManager.hq_selected: set_cell(local_to_map(hq_summon_pos), 2, Vector2i(0, 0))
