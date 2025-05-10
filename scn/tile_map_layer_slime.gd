extends TileMapLayer

@export var units : Array[Unit]
@export var bar : TextureRect

func _process(_delta):
	for unit : Unit in units:
		var tile = local_to_map(unit.path_position)
		if get_cell_tile_data(tile).get_custom_data("team") != unit.team \
			and get_cell_tile_data(tile).get_custom_data("team") > -1:
			unit.hurt(1)
		set_cell(tile, 1, Vector2(unit.team + 1, 0))
	
	var purple : float = 0
	var green : float = 0
	for cell in get_used_cells():
		match get_cell_tile_data(cell).get_custom_data("team"):
			0:
				purple += 1
			1:
				green += 1
	bar.material.set_shader_parameter("purple_team", purple/get_used_cells().size())
	bar.material.set_shader_parameter("green_team", 1 - green/get_used_cells().size())
