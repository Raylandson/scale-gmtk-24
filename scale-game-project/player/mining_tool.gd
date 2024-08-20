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
	
	tile_map.set_cell(cell_position)
	generate_ore(tile_map.map_to_local(cell_position))


func generate_ore(ore_pos: Vector2) -> void:
	for a in range(2):
		var ore_instance: CollectableItem = ore.instantiate()
		ore_instance.global_position = ore_pos
		get_tree().current_scene.add_child(ore_instance)
