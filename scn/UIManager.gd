extends Node

@onready var label: Label = $HUD/TimerLabel
@onready var resource1 = $HUD/ResourceDisplay/Resource1
@onready var resource2 = $HUD/ResourceDisplay/Resource2

var total_time := 300.0  # 5 minutes (compte à rebours)

func _ready():
	update_display()
	ResourceManager.resources_updated.connect(update_display)

func update_display():
	resource1.text = "1: %d" % ResourceManager.get_resource(0)
	resource2.text = "2: %d" % ResourceManager.get_resource(1)

func _process(delta):
	if total_time > 0:
		total_time -= delta
		var minutes = int(total_time) / 60
		var seconds = int(total_time) % 60
		label.text = "%02d:%02d" % [minutes, seconds]
	else:
		label.text = "00:00"
	
