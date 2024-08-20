extends CharacterBody2D

enum States{MOVING, ATTACKING, DEATH, IDLE}
var current_state = States.MOVING


const ENEMY_BULLET = preload("res://enemies/enemy_bullet.tscn")
@export var time_to_shoot = 1.5
var _timer = 0

@export var speed = 43
@export var gravity = 50
@export var attack_distance_threshold = 100
@export var jump_height: float = 46
@export var health_points = 35
@onready var current_health_points = health_points
var jump_force = 0
var floor_pos: Vector2  = Vector2.ZERO
var direction = Vector2.ZERO 
var target: Node2D = null
var tile_map: TileMapLayer = null
var gravity_scale: float = 1
@onready var jump_speed = sqrt(2 * gravity * jump_height)
var jumped = false
var random_point = Vector2.ZERO

func _ready():
	target = get_tree().get_first_node_in_group("seed")
	tile_map = get_tree().get_first_node_in_group("MainTileMap")
	if is_instance_valid(target): 
		random_point = target.global_position + Vector2(randf_range(-150, 150), randf_range(-105, -75))
	
	
func _physics_process(delta):
	
	#print(current_state)
	
	#aqui programa ta, e muito
	#if not is_instance_valid(target):
		#target = get_tree().get_first_node_in_group("seed")
	
	
	match current_state:
		States.IDLE:
			direction = Vector2.ZERO
			
			if is_instance_valid(target) and self.global_position.distance_to(target.global_position) < attack_distance_threshold:
				current_state = States.ATTACKING
			else:
				current_state = States.MOVING
				
		States.MOVING:
			if is_instance_valid(target):
				var distance_to_target: float = self.global_position.distance_to(random_point) 
				direction = self.global_position.direction_to(random_point).normalized()
				
				if sign(direction.x): $Flip.scale.x = sign(direction.x)
				
				#if distance_to_target <= 200 and self.global_position.y <= target.global_position.y - 50:
					#velocity.y += gravity * 0.5 * delta

				if  distance_to_target <= 5:
					direction = Vector2.ZERO
					current_state = States.ATTACKING
				
				velocity = speed * direction
		
		States.ATTACKING:
			#direction = Vector2.ZERO
			$Flip.scale.x = sign(self.global_position.direction_to(target.global_position).x)
			_timer += delta * 1
			if _timer >= time_to_shoot:
				var bullet = ENEMY_BULLET.instantiate()
				bullet.global_position = global_position
				bullet.set_direction(self.global_position.direction_to(target.global_position).normalized())
				get_tree().current_scene.add_child(bullet)
				_timer = 0
		
		
	#velocity.y += gravity * gravity_scale * delta
	move_and_slide()
	
	
	

func take_damage(damage : float) -> void:
	current_health_points = max(0, current_health_points - damage)
	if current_health_points <= 0:
		death()
	
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color(1, 1, 1), 0.25).from(Color.DARK_RED).set_trans(Tween.TRANS_QUART)


func death():
	self.queue_free()
