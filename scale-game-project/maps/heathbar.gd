extends TextureProgressBar


@export var seed : Seed


func _ready():
	pass


func _process(delta):
	if is_instance_valid(seed):
		self.value = seed.current_life
		self.max_value = seed.max_life
