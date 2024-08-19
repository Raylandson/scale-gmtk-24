extends Label


func _process(delta: float) -> void:
	self.text = str(Globals.wood) + " " + str(Globals.ore)
