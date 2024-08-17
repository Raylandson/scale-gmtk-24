extends Area2D

@export var camera: Camera2D
@export_range (0.0, 76) var actor_offset_distance: float = 30

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("CameraChanger"):
		actor_animation(body)
		camera_animation()


func camera_animation() -> void:
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(camera, "global_position", $Marker2D.global_position,
	0.5).set_ease(Tween.EASE_IN)


func actor_animation(node: Node2D) -> void:
	if node.has_method("stun"):
		node.stun()
	var tween:Tween = get_tree().create_tween()
	var direction: Vector2 = node.global_position.\
	direction_to($Marker2D.global_position)
	var final_pos: Vector2 = \
	Vector2(sign(direction.x) * actor_offset_distance, 0) + node.global_position
	tween.tween_property(node, "global_position", final_pos,
	0.5).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(1.0)
	if node.has_method("stun"):
		node.stun(false)
