extends Node

@export var resources : Array[int] = [100, 0]

func addResource(type : int, amount : int = 1):
	resources[type] += amount
	updateUI()

func substractResource(type : int, amount : int = 1):
	resources[type] -= amount
	updateUI()

func updateUI():
	print(resources)
