extends TileMapLayer

@export var units : Array[Unit]

func _process(_delta):
	for unit : Unit in units:
		var tile = local_to_map(unit.path_position)
		if get_cell_tile_data(tile).get_custom_data("team") != unit.team \
			and get_cell_tile_data(tile).get_custom_data("team") > -1:
			unit.hurt(1)
		set_cell(tile, 1, Vector2(unit.team + 1, 0))
