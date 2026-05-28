extends Button

var direction = 0
var speed = 4
var dirSpeed = 1

func _ready():
	get_child(1).play("spin")

func _process(delta):
	global_position += Vector2(cos(direction),sin(direction)) * delta * speed
	direction += dirSpeed * delta
	speed += delta * 0.2 * speed

func explode():
	disabled = true
	var new = create_tween()
	new.set_parallel()
	new.tween_property(self,"scale",Vector2(3,3),0.5)
	new.tween_property(self,"modulate",Color.TRANSPARENT,0.5)
	await new.finished
	queue_free()

func absorb():
	speed = 0
	dirSpeed = 0
	var new = create_tween()
	new.set_parallel()
	new.tween_property(self,"global_position",Vector2(33,577),0.6)
	new.tween_property(self,"modulate",Color.TRANSPARENT,0.5)
	await new.finished
	queue_free()
