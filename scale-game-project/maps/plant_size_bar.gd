extends TextureProgressBar

@export var seed : Seed


func _ready():
	pass


func _process(delta):
	if is_instance_valid(seed):
		self.value = seed.current_xp
		self.max_value = seed.xp_to_size_level
