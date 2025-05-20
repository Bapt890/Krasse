extends Sprite2D

var resource = load("res://scn/Resource.tscn")
var current_res : Item

func _ready():
	_on_timer_timeout()

func _on_timer_timeout():
	var res : Item = resource.instantiate()
	res.type = 1 if randi_range(1, 10) == 10 else 0
	add_child(res)
	await res.child_exiting_tree
	$Timer.start()
