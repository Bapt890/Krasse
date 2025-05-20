extends Sprite2D

var variant : bool = false
var is_green : bool = false

func _ready():
	if !variant:
		var rand = randi_range(1, 5)
		$AudioStreamPlayer2D.stream = load("res://snd/fx/pop%d.mp3" % rand)
	else:
		var rand = randi_range(1, 6)
		$AudioStreamPlayer2D.stream = load("res://snd/fx/boom%d.mp3" % rand)
		scale = Vector2(1, 1)
	if is_green: texture = load("res://img/unit/boom/g9.png")
	$AudioStreamPlayer2D.play()


func _on_audio_stream_player_2d_finished():
	queue_free()
