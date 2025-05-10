extends CharacterBody2D

var move_speed = 200 # Vitesse de déplacement
var target_position = null # Position désirée

func _ready():
	pass

func _input(event): # Fonction de déplacement avec clic-droit
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			target_position = get_global_mouse_position()

func _physics_process(delta):
	if target_position:
		var direction = target_position - global_position
		var distance = direction.length()
		
		if distance > 1:
			var move_distance = move_speed * delta
			if move_distance > distance:
				move_distance = distance
			var movement = direction.normalized() * move_distance
			move_and_collide(movement)
		else:
			target_position = null
