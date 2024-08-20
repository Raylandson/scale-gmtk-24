extends CharacterBody2D

enum States{MOVING, ATTACKING, DEATH, IDLE, CRAWLING}
var current_state = States.CRAWLING



@export var speed = 8
@export var gravity = 222
@export var attack_distance_threshold = 50
@export var jump_height: float = 46
@export var health_points = 50
@onready var current_health_points = health_points
var jump_force = 0
var floor_pos: Vector2  = Vector2.ZERO
var direction = Vector2.ZERO 
var target: Node2D = null
var tile_map: TileMapLayer = null
var gravity_scale: float = 1
@onready var jump_speed = sqrt(2 * gravity * jump_height)
var jumped = false

func _ready():
	target = get_tree().get_first_node_in_group("seed")
	tile_map = get_tree().get_first_node_in_group("MainTileMap")
	
	if is_instance_valid(target):
		var direct_to_target = global_position.direction_to(target.global_position)
		floor_pos = global_position + Vector2(sign(direct_to_target.x)*200, -200)
	$CollisionShape2D.disabled = true
	%CollisionShape2D.disabled = true


func _physics_process(delta):
	
	
	
	#aqui programa ta, e muito
	#if not is_instance_valid(target):
		#target = get_tree().get_first_node_in_group("seed")
	
	
	match current_state:
		States.CRAWLING:
			#print('crawling in my skin')
			gravity_scale = 0
			self.modulate.a = 0.5
			$Seed.scale = Vector2(0.5, 0.5)
			if is_instance_valid(target):
				direction = global_position.direction_to(floor_pos)
			
			velocity.y = direction.y * speed * 2
			
			
			if is_instance_valid(tile_map):
				var cell_id: = tile_map.get_cell_source_id(
					tile_map.local_to_map(self.global_position))
				
				if cell_id == -1:
					gravity_scale = 1
					jump_force = -100
					$CollisionShape2D.disabled = false
					#a sublime diferença
					%CollisionShape2D.disabled = false
					current_state = States.MOVING
		
		
		States.IDLE:
			self.modulate.a = 1
			direction = Vector2.ZERO
			$Seed.scale = Vector2(1, 1)
			
			if is_instance_valid(target) and self.global_position.distance_to(target.global_position) < attack_distance_threshold:
				current_state = States.ATTACKING
				
		States.MOVING:
			self.modulate.a = 1
			$Seed.scale = Vector2(1, 1)
			if is_instance_valid(target):
				var distance_to_target: float = self.global_position.distance_to(target.global_position) 
				direction = self.global_position.direction_to(target.global_position).normalized()
				
				if  distance_to_target <= attack_distance_threshold:
					direction = Vector2.ZERO
					current_state = States.ATTACKING
			
			#paia isso aqui, olha como se programa de verdade
			#if $Flip/RayCast2D.is_colliding():
				#jump_force = -100
			#else:
				#jump_force = 0
			if is_instance_valid(tile_map):
				var cell_id: = tile_map.get_cell_source_id(
					tile_map.local_to_map(%Marker2D.global_position))
				#print(cell_id)
				if cell_id != -1 and not jumped:
					jumped = true
					self.velocity.y = -jump_speed
			
			if self.is_on_floor():
				jumped = false
				
			velocity.x = speed * direction.x
		
		States.ATTACKING:
			#ataque
			direction = Vector2.ZERO
			velocity.x = speed * direction.x
		
		
	if sign(direction.x) == -1:
		$AnimationPlayer.play("movingR")
		if current_state == States.CRAWLING:
			$Seed.rotation_degrees = 90
		else:
			$Seed.rotation_degrees = 0
			
	elif sign(direction.x) == 1:
		$AnimationPlayer.play("movingL")
		if current_state == States.CRAWLING:
			$Seed.rotation_degrees = -90
		else:
			$Seed.rotation_degrees = 0
		
	velocity.y += gravity * gravity_scale * delta
	move_and_slide()
	
	if sign(direction.x): $Flip.scale.x = sign(direction.x)
	

func take_damage(damage : float) -> void:
	current_health_points = max(0, current_health_points - damage)
	if current_health_points <= 0:
		death()
	#apply_knockback()
	
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color(1, 1, 1), 0.25).from(Color.DARK_RED).set_trans(Tween.TRANS_QUART)


func death():
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(0,0), 0.25).from(Vector2(1.2, 1.2)).set_trans(Tween.TRANS_QUART)
	await tw.finished
	self.queue_free()


func apply_knockback():
	self.global_position += -direction + Vector2(10, 10)
	pass 


func _on_player_atack_area_body_entered(body: Node2D) -> void:
	if body is Actor and is_instance_valid(target):
		body.take_damage(self.global_position.direction_to(target.global_position))
