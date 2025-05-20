extends Node

var selected_units : Array[Unit]
var hq_selected : bool = false
var is_selecting : bool = false

# Pour chaque unité, la "déselectionne" et la supprime du tableau d'unités
func deselect_all():
	for unit : Unit in selected_units:
		unit.deselect()
		selected_units.erase(unit)

# Si le clic droit relâché + pas de clic gauche en cours (pour éviter d'être en mode rectangle de sélection),
# utilise le pathfinding de chaque unité sélectionné
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and \
		event.is_released() and !Input.is_action_pressed("select"):
		for unit : Unit in selected_units:
			if unit.is_selected: 
				unit.pathfinding()
