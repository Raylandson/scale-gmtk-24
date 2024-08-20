extends Node2D


@export var min_spawn_distance: float = 100
@export var max_spawn_distance: float = 200
@export var min_time_spawn: float = 1
@export var max_time_spawn: float = 2
@export var spawn_timer:Timer
@export var floor_height: Marker2D
@export var worm_enemy: PackedScene
@export var fly_worm: PackedScene
@export var min_enemy_wave: int = 1
@export var max_enemy_wave: int = 2
@export var time_to_spawn_fly_word: float = 200

func _ready() -> void:
	spawn_timer.start(randf_range(min_time_spawn, max_time_spawn))


func _on_spawn_timer_timeout() -> void:
	spawn_timer.start(randf_range(min_time_spawn, max_time_spawn))
	spawn_enemy(worm_enemy, floor_height.global_position.y)
	
	if time_to_spawn_fly_word < 0:
		spawn_enemy(fly_worm, -50)


func _process(delta: float) -> void:
	time_to_spawn_fly_word -= delta
	
	if time_to_spawn_fly_word < 0:
		set_process(false)


func spawn_enemy(enemy_scene: PackedScene, y_height:float):
	for a in range(randi_range(min_enemy_wave, max_enemy_wave)):
		var new_enemy: Node2D = enemy_scene.instantiate()
		var sign := 1 if randi() % 2 == 0 else -1

		new_enemy.global_position = Vector2(randf_range(min_spawn_distance,
		 max_spawn_distance) * sign + floor_height.global_position.x,
		y_height)
		
		get_tree().current_scene.add_child(new_enemy)


func _on_difficult_timer_timeout() -> void:
	min_time_spawn = max(min_time_spawn * 0.8, 4)
	max_time_spawn = max(max_time_spawn * 0.8, 7)
	
	min_enemy_wave = max(min_enemy_wave + 1, 10)
	max_enemy_wave = max(max_enemy_wave + 1, 15)
	
	min_spawn_distance = max(min_spawn_distance * 0.8, 600)
	max_spawn_distance = max(max_spawn_distance * 0.8, 800)
	
