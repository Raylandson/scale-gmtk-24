extends RigidBody2D


@export var max_random_force: float = 10000


func _ready() -> void:
	var random_mass: float = randf_range(-10, 10)
	self.center_of_mass = Vector2(random_mass, 0)
	
	var random_force: Vector2 = Vector2(randf_range(-max_random_force, max_random_force), 
	randf_range(-max_random_force, max_random_force))
	
	apply_central_force(random_force)
	
	#await get_tree().create_timer(0.2).timeout
	#self.freeze = true


func set_freeze(_bool: bool):
	self.freeze = _bool
