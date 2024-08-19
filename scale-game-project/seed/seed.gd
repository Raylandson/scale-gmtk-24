extends StaticBody2D
class_name Seed

@export var anim_time: float = 0.4
@onready var seed = $Seed

func _ready():
	add_to_group("seed")


func _on_collect_area_body_entered(body: Node2D) -> void:
	if body is Actor:
		body.inside_upgrade_area = true
	
	if body is CollectableItem:
		body.collectable = false
		if Globals.dict_vars.has(body.type):
			Globals.dict_vars[body.type] += 1
			Globals.update_vars()
		
		
		body.set_freeze(true)
		body.rotation = randf()
		var tw = create_tween().set_parallel(true)
		tw.tween_property(body, "global_position", self.global_position, anim_time).set_trans(Tween.TRANS_QUINT)
		tw.tween_property(body, "scale", Vector2.ZERO, anim_time).from(Vector2(1.2, 1.2)).set_trans(Tween.TRANS_BOUNCE)
		tw.tween_property(seed, "scale", Vector2(1,1), 0.35).from(Vector2(1.3, 1.3)).set_trans(Tween.TRANS_BOUNCE)
		await get_tree().create_timer(anim_time).timeout
		if is_instance_valid(body):
			body.queue_free()


func _on_collect_area_body_exited(body: Node2D) -> void:
	if body is Actor:
		body.inside_upgrade_area = false
		body.queue_free()
		
		#tw.tween_property($Seed, "modulate")
