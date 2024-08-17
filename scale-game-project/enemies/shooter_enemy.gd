extends Node2D

@export var bullet: PackedScene
@export var player: CharacterBody2D
@export var timer: Timer


func shoot() -> void:
	timer.start(randf_range(1, 2))
	var bullet_direction = self.global_position.direction_to(
		player.global_position)
	
	var new_bullet: Bullet = bullet.instantiate()
	new_bullet.global_position = self.global_position
	new_bullet.direction = bullet_direction
	get_tree().current_scene.add_child(new_bullet)
