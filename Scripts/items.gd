extends Area2D

@export var item_name : String

func _on_body_entered(body):
	if body.is_in_group("units"): # Vérifie si le body est dans le groupe "units"
		Inventory.pick_up_item( item_name, 1)
		queue_free() # Supprime l'objet de la scène
