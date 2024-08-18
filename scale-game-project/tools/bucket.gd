extends CharacterBody2D

class_name Bucket
var player: Actor
var player_inside: bool = false
@export var gravity: float = 222.0
@onready var default_gravity: float = gravity
@export var max_water_quantity: int = 2

@export var current_water_quantity: int = 0

func dishold() -> void:
	gravity = default_gravity
	set_process(true)
	#await get_tree().create_timer(0.2).timeout


func catch_water(water_quantity: int) -> int:
	if current_water_quantity == max_water_quantity:
		return water_quantity
	
	if water_quantity >= max_water_quantity:
		water_quantity -= max_water_quantity
		current_water_quantity = max_water_quantity
		return water_quantity
	
	current_water_quantity = water_quantity
	return 0


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and player_inside\
	and is_instance_valid(player) and not player.carrying and is_on_floor()\
	and not player.wood_carrying:
		player.grab(self)
		gravity = 0
		set_process(false)
		print('pegando')




func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	move_and_slide()


func _on_body_entered(body: Node2D) -> void:
	if body is Actor:
		player_inside = true
		player = body
		player.inside_bucket = true


func _on_body_exited(body: Node2D) -> void:
	if body is Actor:
		player_inside = false
		body.inside_bucket = false


func full() -> bool:
	if max_water_quantity == current_water_quantity:
		return true
	return false
