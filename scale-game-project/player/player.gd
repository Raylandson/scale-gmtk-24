extends CharacterBody2D

@export var speed: float = 100.0
@export var distance_to_build: float = 1
@export var tile_map_layer: TileMapLayer
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



func put_block() -> void:
	#for now, its only erasing
	tile_map_layer.set_cell(tile_map_layer.local_to_map(
	tile_map_layer.to_local($Marker2D.global_position)))
