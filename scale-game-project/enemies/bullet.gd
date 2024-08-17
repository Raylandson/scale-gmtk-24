extends Area2D

class_name Bullet

@export var speed: float = 100.0
var direction: Vector2 = Vector2.ONE
var max_distance: float = 1000

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	max_distance -= speed * delta
	
	if max_distance < 0:
		queue_free()
