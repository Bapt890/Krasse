extends Node

var selected_units : Array[Unit]
var is_selecting : bool = false

func deselectAll():
	for unit : Unit in selected_units:
		unit.deselect()
		selected_units.erase(unit)
