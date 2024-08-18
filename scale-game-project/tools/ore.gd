extends CollectableItem

@export var deceleration_rate: float = 0.98
var _frea = true

func _ready() -> void:
	ready()
	#nao sei pq mas tem que ter a area 2d pra funcionar, a vida tem muitas perguntas e poucas respostas

func _physics_process(delta):
	if abs(linear_velocity.x) > 0.1:
		linear_velocity.x *= deceleration_rate
