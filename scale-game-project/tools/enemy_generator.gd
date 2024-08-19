extends Node2D


@export var min_spawn_distance: float = 100
@export var max_spawn_distance: float = 200
@export var min_time_spawn: float = 1
@export var max_time_spawn: float = 2
@export var spawn_timer:Timer
@export var floor_height: Marker2D
@export var worm_enemy: PackedScene
@export var min_enemy_wave: int = 1
@export var max_enemy_wave: int = 2

func _ready() -> void:
	spawn_timer.start(randf_range(min_time_spawn, max_time_spawn))


func _on_spawn_timer_timeout() -> void:
	spawn_timer.start(randf_range(min_time_spawn, max_time_spawn))
	spawn_enemy(worm_enemy)


func spawn_enemy(enemy_scene: PackedScene):
	for a in range(randi_range(min_enemy_wave, max_enemy_wave)):
		var new_enemy: Node2D = enemy_scene.instantiate()
		var sign := 1 if randi() % 2 == 0 else -1

		new_enemy.global_position = Vector2(randf_range(min_spawn_distance,
		 max_spawn_distance) * sign + floor_height.global_position.x,
		floor_height.global_position.y)
		
		get_tree().current_scene.add_child(new_enemy)
