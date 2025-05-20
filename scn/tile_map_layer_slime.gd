extends TileMapLayer

@export var bar : TextureRect
@export var purple_label : Label
@export var green_label : Label

func _ready():
	for unit : Unit in $UnitList.get_children():
		unit.explode.connect(explode)

func _process(_delta):
	for unit : Unit in $UnitList.get_children():
		if !unit.is_connected("explode", explode):
			unit.explode.connect(explode)
		if unit.timer.time_left == 0:
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
	purple_label.text = "%.02f%%" % (purple / get_used_cells().size() * 100)
	bar.material.set_shader_parameter("green_team", 1 - green/get_used_cells().size())
	green_label.text = "%.02f%%" % (green / get_used_cells().size() * 100)

func explode(pos : Vector2, team : int):
	pos = local_to_map(pos)
	for x in range(-2, 3):
			for y in range(-2, 3):
				if !(x == -2 and y == -2) and !(x == 2 and y == -2) and !(x == -2 and y == 2) and !(x == 2 and y == 2):
					if get_used_cells().has(local_to_map(Vector2(pos.x * 128 + x * 128, pos.y * 128 + y * 128))):
						set_cell(local_to_map(Vector2(pos.x * 128 + x * 128, pos.y * 128 + y * 128)), 1, Vector2(team + 1, 0))

func draw_map() -> ImageTexture:
	var size : Vector2 = Vector2(300, 120)
	var img = Image.create(300, 120, false, Image.FORMAT_RGBA8)
	for cell in get_used_cells():
		var color : Color
		match get_cell_atlas_coords(cell).x:
			0: color = Color(0.2, 0.2, 0.2, 1)
			1: color = Color("ff91ff")
			2: color = Color(0, 255, 0, 1)
		for x in range((cell.x - 1) * size.x / 50, cell.x * size.x / 50 - 1):
			for y in range((cell.y - 1) * size.y / 20, cell.y * size.y / 20 -1):
				img.set_pixel(x, y, color)
	return ImageTexture.create_from_image(img)
