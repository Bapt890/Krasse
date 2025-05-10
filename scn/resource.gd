extends Area2D

@export var amount : int
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

func _on_area_entered(_area):
	ResourceManager.addResource(type, amount)
	queue_free() # Supprime l'objet de la scène
