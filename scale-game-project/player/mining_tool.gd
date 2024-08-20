extends Marker2D

@export var player: Actor
@onready var tile_map: TileMapLayer = player.tile_map
@export var ore:PackedScene

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and not player.carrying\
	and not player.wood_carrying:
		var cell_position: = tile_map.local_to_map(self.global_position)
		var cell_id: = tile_map.get_cell_source_id(cell_position)
		mine_cell(cell_id, cell_position)
		


func mine_cell(cell_id: int, cell_position:Vector2i) -> void:
	if cell_id != 0:
		return
	
	get_tree().create_timer(1.5).timeout.connect(func():
		tile_map.set_cell(cell_position + Vector2i(0, 1), 3, Vector2.ZERO))
	
	get_tree().create_timer(1).timeout.connect(func():
		for item in tile_map.get_used_cells_by_id(3):
			var rand_num = randf()
			var top_left = tile_map.get_cell_source_id(item + Vector2i(-1, -1)) != -1
			var top_right = tile_map.get_cell_source_id(item + Vector2i(1, -1)) != -1
			var pos = get_tree().get_first_node_in_group("MainPos")
			
			if rand_num < 0.25 and not (top_left or top_right) \
			and tile_map.map_to_local(item).distance_to(pos.global_position) > 600:
				tile_map.set_cell(item, 0, Vector2.ZERO)
				print("gerado", item)
				return
			#
		#for item in tile_map.get_surrounding_cells(cell_position + Vector2i(0, 1)):
			#var edge = top_left or top_right
#
			#if not edge and tile_map.get_cell_source_id(item) == 3:
				#return
#
			#for item2 in tile_map.get_surrounding_cells(item):
				#var top_left_2 = tile_map.get_cell_source_id(item2 + Vector2i(-1, -1)) != -1
				#var top_right_2 = tile_map.get_cell_source_id(item2 + Vector2i(1, -1)) != -1
				#var edge_2 = top_left_2 or top_right_2
#
				#if not edge_2 and tile_map.get_cell_source_id(item2) == 3:
					#tile_map.set_cell(item2, 0, Vector2.ZERO)
					#return
					)


	tile_map.set_cell(cell_position)
	for item in tile_map.get_surrounding_cells(cell_position):
		if tile_map.get_cell_source_id(item) == 3:
			print(item)
	generate_ore(tile_map.map_to_local(cell_position))


func can_mining() -> bool:
	var cell_position: = tile_map.local_to_map(self.global_position)
	return tile_map.get_cell_source_id(cell_position) == 0


func generate_ore(ore_pos: Vector2) -> void:
	for a in range(2):
		var ore_instance: CollectableItem = ore.instantiate()
		ore_instance.global_position = ore_pos
		get_tree().current_scene.add_child(ore_instance)
