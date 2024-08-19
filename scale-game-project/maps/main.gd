extends Node2D

@export var tile_map: TileMapLayer
@export var initial_pos: Marker2D
@export var min_distance_to_spawn: float = 600
@export var min_blocks_between_resources: int = 2
@export var max_blocks_between_resources: int = 3
@export_range(0.0, 1.0) var chance_to_spawn_ore: float = 0.5
@export_range(0.0, 1.0) var chance_to_spawn_tree: float = 0.25
@export_range(0.0, 1.0) var chance_to_spawn_well: float = 0.25
@export var tree_scene: PackedScene
@export var well_scene: PackedScene

func _ready() -> void:
	var next_spawn_distance := randi_range(min_blocks_between_resources, max_blocks_between_resources)
	var current_distance := 0
	
	for cell in tile_map.get_used_cells_by_id(3):
		var current_pos := tile_map.map_to_local(cell)
		
		if current_pos.distance_to(initial_pos.global_position) < min_distance_to_spawn:
			continue
		
		if current_distance >= next_spawn_distance:
			var resource_choice := randf()
			
			if resource_choice < chance_to_spawn_ore:
				tile_map.set_cell(cell, 4, Vector2i.ZERO) 
			elif resource_choice < chance_to_spawn_ore + chance_to_spawn_tree:
				spawn_scene(tree_scene, current_pos) 
			else:
				spawn_scene(well_scene, current_pos) 
			
			
			next_spawn_distance = randi_range(min_blocks_between_resources, max_blocks_between_resources)
			current_distance = 0
		else:
			current_distance += 1


func _process(delta: float) -> void:
	
	pass


func spawn_scene(scene: PackedScene, pos: Vector2) -> void:
	var instance: Node2D = scene.instantiate()
	instance.global_position = pos + Vector2(0, -20)
	get_tree().current_scene.add_child(instance)
