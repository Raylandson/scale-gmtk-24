extends RigidBody2D

class_name Bucket
var player: Actor
var player_inside: bool = false
@export var gravity: float = 222.0
@onready var default_gravity: float = gravity
@export var current_water_quantity: int = 0

func dishold(velocity: Vector2) -> void:
	self.freeze = false
	self.apply_central_force(velocity)
	#await get_tree().create_timer(0.2).timeout

func catch_water(water_quantity: int) -> int:
	if current_water_quantity == Globals.bucket_max_water:
		return water_quantity
	
	if water_quantity >= Globals.bucket_max_water:
		water_quantity -= Globals.bucket_max_water
		current_water_quantity = Globals.bucket_max_water
		return water_quantity
	
	current_water_quantity = water_quantity
	return 0


func _process(delta: float) -> void:
	#print(get_contact_count(), self.name)
	$Sprite2D.frame = not full()
	if Input.is_action_just_pressed("ui_accept") and player_inside\
	and is_instance_valid(player) and not player.carrying \
	and not player.wood_carrying:
		player.grab(self)
		self.freeze = true
		#gravity = 0
		#set_process(false)
		print('pegando')
	$Sprite2D.frame = not full()



#func _physics_process(delta: float) -> void:
	#velocity.y += gravity * delta
	#move_and_slide()


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
	if Globals.bucket_max_water == current_water_quantity:
		return true
	return false
