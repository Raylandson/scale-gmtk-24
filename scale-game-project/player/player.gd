extends CharacterBody2D

@export var speed: float = 100.0
@export var distance_to_build: float = 1
@export var tile_map_layer: TileMapLayer
@onready var tile_cells: Array[Vector2i] = tile_map_layer.get_used_cells_by_id(3)
var tile_size:float = 16.0



func _physics_process(delta: float) -> void:
	var direction:Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#ppega algebra linea braba
	direction = Vector2(direction.x + direction.y, 
	(-direction.x)*0.5 + direction.y * 0.5)

	if direction != Vector2.ZERO:
		$Marker2D.position = direction * distance_to_build * tile_size
		$StaticBody2D.position = direction * distance_to_build * tile_size
	
	if Input.is_action_pressed("ui_accept"):
		put_block()
	
	velocity = velocity.lerp(direction * speed, 0.5)
	move_and_slide()


func erase_block() -> void:
	if tile_cells.size() <= 1:
		get_tree().reload_current_scene()
		return
	
	var current_cell: Vector2i = tile_cells[0]
	
	tile_map_layer.set_cell(current_cell)
	tile_map_layer.set_cell(current_cell, 0, Vector2i(0, 0))
	
	tile_cells.pop_front()


func put_block() -> void:
	#for now, its only erasing
	var new_cell_pos:Vector2i = tile_map_layer.local_to_map(
	tile_map_layer.to_local($Marker2D.global_position))
	tile_map_layer.set_cell(new_cell_pos, 3, Vector2i(0, 0))
	
	if not tile_cells.has(new_cell_pos):
		tile_cells.append(new_cell_pos)
