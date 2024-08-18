extends Node
class_name Global
 
var wood : float = 0.0 :
	set = _change_wood
var water : float = 0.0
var ore : float = 0.0

func _ready():
	pass # Replace with function body.

func _change_wood(new_value):
	wood = max(0, new_value)
	print(wood)
