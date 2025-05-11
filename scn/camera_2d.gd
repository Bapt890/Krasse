extends Camera2D

var speed = 800

var edge_margin = 20

func _process(delta):
	var direction = Vector2.ZERO

# Déplacement avec clavier (ZQSD)
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1	
# Déplacement avec souris

	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size

	if mouse_pos.x <= edge_margin:
		direction.x -=1
	elif mouse_pos.x >= screen_size.x - edge_margin:
		direction.x +=1
	
	if mouse_pos.y <= edge_margin:
		direction.y -= 1
	elif mouse_pos.y >= screen_size.y - edge_margin:
		direction.y += 1
	
	# Appliquer le mouvement
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		global_position += direction * speed * delta
		

# Zoom de la caméra
var zoom_speed := 0.1
var min_zoom := 0.5
var max_zoom := 2.0

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_camera(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_camera(-zoom_speed)

func _zoom_camera(amount):
	zoom += Vector2(amount, amount)
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)
