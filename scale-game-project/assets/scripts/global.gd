extends Node
class_name Global
 
var wood : int = 0
var water : float = 0.0
var ore : int = 0

var dict_vars: Dictionary = {
	"wood" : wood,
	"water" : water,
	"ore" : ore
}

func update_vars():
	wood = dict_vars["wood"]
	water = dict_vars["water"]
	ore = dict_vars["ore"]

func _ready():
	pass # Replace with function body.

func _process(delta: float) -> void:
	print(wood, water, ore)

func _change_wood(new_value):
	wood = max(0, new_value)
	print(wood)
