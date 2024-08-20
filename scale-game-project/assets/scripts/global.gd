extends Node
class_name Global
 

signal upgrade_thornmail
signal upgrade_sword_2
signal upgrade_sword_berzek
signal upgrade_slow_area
signal call_shake
signal show_upgrades

var wood : int = 0
var water : int = 0
var ore : int = 0

var dict_vars: Dictionary = {
	"wood" : wood,
	"water" : water,
	"ore" : ore
}

var speed_multi = 1
var mining_speed_multi = 1
#var chop_speed_multi = 1
var damage_multi = 1
var carry_count = 1
var attack_level = 1
var plant_heal_muilti = 1
var plant_max_life = 75

var well_max_water: int = 3
var well_fill_multiplier: float = 1.0
var bucket_max_water: int = 2

var spawn_tree_time: float = 50.0
var spawn_tree_multi: float = 1.0
var cut_speed_multi:float = 1.0

func update_vars():
	wood = dict_vars["wood"]
	water = dict_vars["water"]
	ore = dict_vars["ore"]

func _ready():
	pass # Replace with function body.
