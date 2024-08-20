extends Area2D
signal ended
@export var attack_damage = 10

func _on_body_entered(body):
	if body.is_in_group("enemy"):
			body.take_damage(attack_damage * Globals.damage_multi)
