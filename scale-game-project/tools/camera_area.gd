extends Area2D

@export var camera: Camera2D
@export_range (0.0, 76) var actor_offset_distance: float = 30
@export var tween_animation_time :float = 0.5
@export var is_first_room: bool = false

func _ready() -> void:
	#depois programar para achar a camera automatic vinici 13
	
	if is_first_room:
		camera.global_position = $Marker2D.global_position


func _on_body_entered(body: Node2D) -> void:
	if is_first_room and body.is_in_group("CameraChanger"):
		is_first_room = false
		#print(self.name)
		return
	
	if body.is_in_group("CameraChanger"):
		
		prints(self.name, is_first_room)
		actor_animation(body)
		camera_animation()


func camera_animation() -> void:
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(camera, "global_position", $Marker2D.global_position,
	tween_animation_time).set_ease(Tween.EASE_IN)


func actor_animation(node: Node2D) -> void:
	if node.has_method("stun"):
		node.stun()
	var tween:Tween = get_tree().create_tween()
	var direction: Vector2 = node.global_position.\
	direction_to($Marker2D.global_position)
	var final_pos: Vector2 = \
	Vector2(sign(direction.x) * actor_offset_distance, 0) + node.global_position
	tween.tween_property(node, "global_position", final_pos,
	tween_animation_time).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(tween_animation_time).timeout
	if node.has_method("stun"):
		node.stun(false)
