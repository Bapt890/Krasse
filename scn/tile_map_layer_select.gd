extends TileMapLayer

func _process(_delta):
	# Si une unité est sélectionnée, met le tile de sélection sur l'emplacement 
	# de la souris en respectant la grille. Efface les sélections précédentes.
	for cell in get_used_cells():
		erase_cell(cell)
	if UnitManager.selected_units.size() >= 1 and !UnitManager.is_selecting:
		var tile = local_to_map(get_global_mouse_position())
		set_cell(tile, 2, Vector2i(0, 0))
