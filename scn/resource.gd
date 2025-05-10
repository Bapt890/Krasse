extends Area2D

@export var amount : int
@export var type : int
@export var sprite : Sprite2D

func _on_area_entered(area):
	ResourceManager.addResource(type, amount)
	queue_free() # Supprime l'objet de la scène
