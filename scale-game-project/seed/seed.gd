extends StaticBody2D
class_name Seed

@export var anim_time: float = 0.4
@onready var seed = $Seed
var size_level = 1
@onready var xp_to_size_level = 30 * size_level
var current_xp = 0

@export var recover_time: float = 5
@onready var default_recover_time: float = recover_time
@onready var max_life = Globals.plant_max_life
@onready var current_life = max_life
var recover_multiplier := 1


func _ready():
	add_to_group("seed")



func _process(delta: float) -> void:
	if current_life < max_life:
		recover_time -= delta
	
	if recover_time < 0:
		current_life += 1
		recover_time = default_recover_time * recover_multiplier
	current_xp += 20 * delta
	
	#print(current_xp)
	
	if current_xp >= xp_to_size_level:
		update_level_up()


func take_damage(num: float) -> void:
	current_life -= num
	if current_life <= 0:
		get_tree().reload_current_scene()
		print('its over, brutal')


func _on_collect_area_body_entered(body: Node2D) -> void:
	if body is Actor:
		body.inside_upgrade_area = true
	
	if body is Bucket:
		Globals.dict_vars["water"] += body.current_water_quantity
		Globals.update_vars()
		body.current_water_quantity = 0
	
	
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
		#body.queue_free()


func update_level_up():
	current_xp = 0
	$Seed.frame = min(size_level, 8)
	Globals.emit_signal("call_shake", 0.2, 12, 6)
	
	match $Seed.frame:
		4:
			$Leaf2/CollisionShape2D.disabled = false
		3:
			$Leaf/CollisionShape2D.disabled = false
		5: 
			$Leaf3/CollisionShape2D.disabled = false
			$Leaf4/CollisionShape2D.disabled = false
		6:
			$Leaf5/CollisionShape2D.disabled = false
			$Leaf6/CollisionShape2D.disabled = false
		7:
			$Leaf7/CollisionShape2D.disabled = false
			$Leaf8/CollisionShape2D.disabled = false
			$Leaf9/CollisionShape2D.disabled = false
			$Leaf10/CollisionShape2D.disabled = false
		8:
			$Leaf11/CollisionShape2D.disabled = false
			$Leaf12/CollisionShape2D.disabled = false
			$Leaf13/CollisionShape2D.disabled = false
			$Leaf14/CollisionShape2D.disabled = false
			$Leaf15/CollisionShape2D.disabled = false
			$Leaf16/CollisionShape2D.disabled = false
	
	size_level += 1
