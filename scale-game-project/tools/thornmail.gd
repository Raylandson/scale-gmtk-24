extends Area2D

@export var time_to_damage : float = 5
@export var damage: float = 50
@export var timer:Timer

func _ready() -> void:
	Globals.upgrade_thornmail.connect(enable)


func _on_timer_timeout() -> void:
	for item in self.get_overlapping_bodies():
		if is_instance_valid(item) and item.is_in_group("enemy"):
			item.take_damage(damage)
	
	timer.start(time_to_damage)


func enable() -> void:
	timer.start(time_to_damage)
	$CollisionShape2D.disabled = false
