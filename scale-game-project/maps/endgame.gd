extends Area2D


func _on_body_entered(body):
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://ui/congratulations.tscn")
		#$CanvasLayer/AnimationPlayer.play("fade")
