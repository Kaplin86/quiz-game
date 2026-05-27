extends Button

var direction = 0
var speed = 4

func _process(delta):
	global_position += Vector2(cos(direction),sin(direction)) * delta * speed
