extends Node

signal resources_updated

@export var resources : Array[int] = [100, 0]

func get_resource(type : int):
	return resources[type]

func addResource(type : int, amount : int = 1):
	resources[type] += amount
	updateUI()

func substractResource(type : int, amount : int = 1):
	resources[type] -= amount
	updateUI()

func updateUI():
	emit_signal("resources_updated")
	print(resources)
