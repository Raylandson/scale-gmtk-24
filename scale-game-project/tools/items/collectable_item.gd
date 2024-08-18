extends RigidBody2D

class_name CollectableItem

@export_range(1000, 10000) var spawn_velocity_force: float = 3000

func _ready() -> void:
	ready()

func ready() -> void:
	var random_dir = random_direction_upwards()
	apply_central_force(random_dir*spawn_velocity_force)


func random_direction_upwards() -> Vector2:
	var angle = randf_range(-PI / 4, PI / 4) 

	return Vector2(sin(angle), -cos(angle)).normalized() 



func set_freeze(_bool: bool) -> void:
	self.freeze = _bool
