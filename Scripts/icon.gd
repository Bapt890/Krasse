extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	#print("position of camera : ")
	print( position)
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		position.x = position.x + 10;
	if Input.is_action_pressed("ui_left") or  Input.is_key_pressed(KEY_Q):
		position.x = position.x - 10;
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_Z):
		position.y = position.y - 10;
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		position.y = position.y + 10;

	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
