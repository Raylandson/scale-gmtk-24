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

var speed_multi = 1
var mining_speed_multi = 1
var chop_speed_multi = 1
var damage_multi = 1
var carry_count = 1
var attack_level = 1

func update_vars():
	wood = dict_vars["wood"]
	water = dict_vars["water"]
	ore = dict_vars["ore"]

func _ready():
	pass # Replace with function body.
