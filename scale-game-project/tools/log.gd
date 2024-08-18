extends CollectableItem


func _ready() -> void:
	ready()
	var random_mass: float = randf_range(-10, 10)
	self.center_of_mass = Vector2(random_mass, 0)
