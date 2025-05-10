extends Node

# Items ramassables
var Item1Scene = preload("res://Scenes/item1.tscn")
var Item2Scene = preload("res://Scenes/item2.tscn")


var inventory = { #Stockage des valeurs et des objets de l'inventaire
	"Item1" : 0,
	"Item2" : 0,
}

# Fontion pour ramasser un objet et le stocker dans l'inventaire
func pick_up_item(name, quantity):
	inventory[name] = inventory[name] + quantity
	print("added to inventory " + name + " quantity " + str(quantity))
	print(name + " total " + str(inventory[name]))
	
#Fonction pour retirer un objet de l'inventaire WIP
func remove_inventory_item(item: String):
	pass

func _on_timer_timeout(): #Fonction qui ajoute les items dans la scène de façon aléatoire WIP
	var item = Item1Scene.instantiate()
	var item2 = Item2Scene.instantiate()
	item.global_position = Vector2(randf_range(0, 1000), randf_range(0, 700))
	item2.global_position = Vector2(randf_range(0, 1000), randf_range(0, 700))
	add_child(item)
	add_child(item2)
	$Timer.wait_time = randf_range(2, 5)
	

func _ready():
	pass
