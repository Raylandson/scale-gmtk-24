extends CharacterBody2D

enum States{MOVING, ATTACKING, DEATH, IDLE, CRAWLING}
var current_state = States.CRAWLING

@export var speed = 8
@export var gravity = 50
@export var attack_distance_threshold = 50

@export var health_points = 50
@onready var current_health_points = health_points
@export var surface_time = 0.5

var floor_pos: Vector2  = Vector2.ZERO
var direction = Vector2.ZERO 
var target: Node2D = null
var tile_map: TileMapLayer = null
var gravity_scale: float = 1

func _ready():
	target = get_tree().get_first_node_in_group("seed")
	tile_map = get_tree().get_first_node_in_group("MainTileMap")
	
	if is_instance_valid(target):
		var direct_to_target = global_position.direction_to(target.global_position)
		floor_pos = global_position + Vector2(sign(direct_to_target.x)*200, -200)
	$CollisionShape2D.disabled = true
	


func _physics_process(delta):
	
	velocity.y += gravity * gravity_scale
	
	#aqui programa ta, e muito
	#if not is_instance_valid(target):
		#target = get_tree().get_first_node_in_group("seed")
	
	
	match current_state:
		States.CRAWLING:
			print('crawling in my skin')
			gravity_scale = 0
			if is_instance_valid(target):
				direction = global_position.direction_to(floor_pos)
			
			velocity = direction * speed * 3
			
			
			if is_instance_valid(tile_map):
				var cell_id: = tile_map.get_cell_source_id(
					tile_map.local_to_map(self.global_position))
				
				if cell_id == -1:
					
					gravity_scale = 1
					current_state = States.MOVING
					$CollisionShape2D.disabled = false
		
		
		States.IDLE:
			direction = Vector2.ZERO
			
			if is_instance_valid(target) and self.global_position.distance_to(target.global_position) < attack_distance_threshold:
				current_state = States.ATTACKING
				
		States.MOVING:
			if is_instance_valid(target):
				var distance_to_target: float = self.global_position.distance_to(target.global_position) 
				direction = self.global_position.direction_to(target.global_position).normalized()
				
				if  distance_to_target <= attack_distance_threshold:
					direction = Vector2.ZERO
					current_state = States.ATTACKING
			
			velocity.x = speed * direction.x
		
		States.ATTACKING:
			#ataque
			direction = Vector2.ZERO
			velocity.x = speed * direction.x
		
	if sign(direction.x) == -1:
		$AnimationPlayer.play("movingR")
	elif sign(direction.x) == 1:
		$AnimationPlayer.play("movingL")
	move_and_slide()


func take_damage(damage : float) -> void:
	current_health_points = max(0, current_health_points - damage)
	if current_health_points <= 0:
		death()
	apply_knockback()
	
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color(1, 1, 1), 0.15).from(Color.DARK_RED).set_trans(Tween.TRANS_QUART)


func death():
	self.queue_free()


func apply_knockback():
	self.global_position += -direction + Vector2(10, 10)
	pass 
