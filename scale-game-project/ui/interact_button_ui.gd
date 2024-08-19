extends Area2D

@export_multiline var show_text = ""


func _ready():
	hide()
	if show_text != "":
		$Label.text = show_text


func _on_body_entered(body):
	if body.is_in_group("player"):
		self.show()


func _on_body_exited(body):
	if body.is_in_group("player"):
		self.hide()
