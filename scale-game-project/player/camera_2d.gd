extends Camera2D

@export var player: Actor


func _process(delta: float) -> void:
	drag_vertical_enabled = not player.is_on_floor()
	
