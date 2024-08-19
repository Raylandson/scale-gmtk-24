extends StaticBody2D
class_name Seed

@export var anim_time: float = 0.5

func _ready():
	add_to_group("seed")


func _on_collect_area_body_entered(body: Node2D) -> void:
	if body is CollectableItem:
		if Globals.dict_vars.has(body.type):
			Globals.dict_vars[body.type] += 1
			Globals.update_vars()
		
		
		body.modulate = Color.DARK_RED
		body.set_freeze(true)
		var tw = create_tween()
		tw.tween_property(body, "global_position", self.global_position, anim_time)
		await get_tree().create_timer(anim_time).timeout
		body.queue_free()
