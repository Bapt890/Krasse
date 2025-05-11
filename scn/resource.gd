extends Area2D

class_name Item

@export var amount : int = 1
@export var type : int
@export var random_images : Array[CompressedTexture2D]

func _ready():
	randomize()
	# Si type 0, choisit une image au hasard
	if type == 0:
		var rand = randi_range(0, random_images.size()-1)
		$Sprite2D.texture = random_images[rand]
	else:
		$Sprite2D.texture = load("res://img/res/flask.png")
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.9, 1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	await tween.finished
	$AnimationPlayer.play("new_animation")

func _on_area_entered(_area):
	ResourceManager.addResource(type, amount)
	queue_free() # Supprime l'objet de la scène
