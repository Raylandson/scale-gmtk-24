extends CharacterBody2D

class_name Actor

enum {STATE_MOVE, STATE_STAND, STATE_AIR, STATE_CLIMBING, STATE_STUNED,
STATE_CARRYING, STATE_CUTTING}


const TILE_SIZE = 16

@export var horizontal_attack_damage = 10
@export var vertical_attack_damage = 15

@export var ground_max_velocity: float = 7.0 * TILE_SIZE
@export_range (0.01, 2.0) var ground_turn_time: float = 0.15
@export_range (0.01, 2.0) var ground_accel_time: float = 0.2
@export_range (0.01, 2.0) var ground_fric_time: float = 0.15

@export var air_max_velocity := 7.5 * TILE_SIZE
@export_range (0.01, 5.0) var air_turn_time: float= 0.25
@export_range (0.01, 5.0) var air_accel_time: float= 0.55
@export_range (0.01, 5.0) var air_fric_time: float= 0.75


@export var climb_speed: float = 100
@export var jump_size:float = 2.2 * TILE_SIZE
@export var min_jump_size: float = 1.1 * TILE_SIZE
@export var fall_time: float = 0.65
@onready var gravity: float = 2 * jump_size / (pow(fall_time, 2)/2) 
@onready var jump_force: float = sqrt(2 * gravity * jump_size)

@export_range (0.0, 1.0) var buffering_time: float = 0.20
@export_range (0.0, 1.0) var coyote_time: float = 0.20
var flip_time: float = 0.1
@export_range (0.0, 5.0) var stuned_time: float = 3.0
var default_stuned := stuned_time

var active = true 

@onready var _default_gravity: float = 2 * jump_size / (pow(fall_time, 2)/2) 
@onready var _gravity_multiplier: float = jump_size/min_jump_size
@onready var _ground_fric: float = ground_max_velocity / (ground_fric_time) #fps
@onready var _ground_accel: float = ground_max_velocity / (ground_accel_time) #fps
@onready var _ground_turn_accel: float = ground_max_velocity / (ground_turn_time) #fps
@onready var _air_fric: float = air_max_velocity / (air_fric_time) #fps
@onready var _air_accel: float = air_max_velocity / (air_accel_time) #fps
@onready var _air_turn_accel: float = air_max_velocity / (air_turn_time) #fps

@onready var _default_buffering_time: float = buffering_time
@onready var _default_coyote_time: float = coyote_time
var _inside_wind = false
var _initial_fall_pos := 2.0
var _fall_distance := 0.0
var _g_multiplier := 1.0
var _direction := 0.0
var _actual_state: int = STATE_STAND
var _first_fall : bool = false
var _jump_pressed : bool = false
var _was_jumped : bool = false
var _engine_fps = Engine.get_frames_per_second()

var _previous_state: int = 0
var _inside_ladder = false
var _ladder
var _bucket : Bucket
var _cut_tree: CutTree
var carrying_velocity_multiplier: float = 1
var default_carrying_multiplier: float = 0.5
var carrying: bool = false
var inside_well: bool = false
var inside_bucket: bool = false
@export var cut_time: float = 1.0
@onready var default_cut_time: float = cut_time
var wood_carrying: bool = false

var is_attacking = false


func _process(delta: float) -> void:
	bucket_follow()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func _ready():
	add_to_group("player")


func _physics_process(delta):
	_direction = get_direction()
	manage_animations()
	
	
	#printt(velocity, _g_multiplier, _ground_accel)s
	#print(_actual_state)
	match _actual_state:
		STATE_STAND:
			stand_state(delta)
		
			
		STATE_MOVE:
			move_state(delta)
		
		
		STATE_AIR:
			air_state(delta)
		
		
		STATE_CLIMBING:
			climbing_state(delta)
		
		
		STATE_STUNED:
			stuned_state(delta)
		
		
		STATE_CUTTING:
			cutting_state(delta)
	
	velocity.y += gravity * delta * _g_multiplier
	move_and_slide()


func grab(bucket: Bucket) -> void:
	_bucket = bucket
	carrying = true
	if bucket.full():
		change_velocity_multiplier()


func change_velocity_multiplier() -> void:
	carrying_velocity_multiplier = default_carrying_multiplier

#top 3 nomes
func disgrab() -> void:
	carrying = false
	carrying_velocity_multiplier = 1


func bucket_follow() -> void:
	if is_instance_valid(_bucket) and carrying:
		_bucket.global_position = %BucketPos.global_position
	
	if Input.is_action_just_pressed("ui_accept") and is_instance_valid(_bucket)\
	and carrying and not inside_well:
		disgrab()
		_bucket.dishold()


func carrying_state(delta: float) -> void:
	
	pass


func cut(cut_tree:CutTree) -> void:
	
	_cut_tree = cut_tree
	if not carrying:
		_actual_state = STATE_CUTTING


func cutting_state(delta: float) -> void:
	if not Input.is_action_pressed("ui_accept"):
		cutting_state_exit()
	
	cut_time -= delta
	
	if cut_time < 0:
		if is_instance_valid(_cut_tree):
			_cut_tree.finish_cutting()
		cutting_state_exit()
	
	friction(_ground_fric, delta)


func cutting_state_exit() -> void:
	cut_time = default_cut_time
	if is_on_floor():
		_actual_state = STATE_STAND
	else:
		_actual_state = STATE_AIR
	pass


func friction(frict: float, delta: float):
	velocity.x = max(abs(velocity.x) - frict * delta, 0.0) * sign(velocity.x)


func stand_state(delta: float) -> void:
	flip_nodes()
	
	friction(_ground_fric, delta)
	
	#velocity.x = clamp(velocity.x, -ground_max_velocity, ground_max_velocity)
	
	if _direction != 0:
		_actual_state = STATE_MOVE
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	
	if Input.is_action_pressed("ui_accept"):
		if Input.is_action_pressed("ui_up"):
			vertical_attack()
		else:
			horizontal_attack()
	
	if not is_on_floor():
		_actual_state = STATE_AIR


func move_state(delta: float) -> void:
	flip_nodes()
	#SPEED MULTIPLIER BRONCA BRONCA ALARME
	movement(_ground_accel, _ground_turn_accel, ground_max_velocity * Globals.speed_multi, delta)
		
	if _direction == 0.0:
		flip_time -= delta
		if flip_time < 0:
			_actual_state = STATE_STAND
	
	else:
		flip_time = 0.1
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	
	if not is_on_floor():
		_actual_state = STATE_AIR
	
	if Input.is_action_pressed("ui_accept"):
		if Input.is_action_pressed("ui_up"):
			vertical_attack()
		else:
			horizontal_attack()

func air_state(delta: float) -> void:
	flip_nodes()
	movement(_air_accel, _air_turn_accel, air_max_velocity, delta)
	calculate_fall_distance()
	
	if _direction == 0.0:
		friction(_air_fric, delta)
	
	if Input.is_action_just_pressed("jump"):
		_jump_pressed = true
	
	if Input.is_action_just_pressed("jump") and coyote_time > 0 and not _was_jumped:
		_g_multiplier = 1
		buffering_time = _default_buffering_time
		_jump_pressed = false
		jump()
		
	if (not Input.is_action_pressed("jump") and _was_jumped) or velocity.y > 0:
		_g_multiplier = _gravity_multiplier
	
	coyote_time -= delta
	
	if Input.is_action_pressed("ui_accept"):
		if Input.is_action_pressed("ui_up"):
			vertical_attack()
		else:
			horizontal_attack()
	
	if _jump_pressed:
		buffering_time -= delta
	
	
	if is_on_floor():
		_was_jumped = false
		if _jump_pressed and buffering_time > 0:
			jump()
		_jump_pressed = false
		buffering_time = _default_buffering_time
		coyote_time = _default_coyote_time
		_g_multiplier = 1
		_fall_distance = 0.0
		_actual_state = STATE_MOVE


func stun(_bool: bool = true) -> void:
	if _bool:
		_previous_state = _actual_state
		_actual_state = STATE_STUNED
		return
	_actual_state = _previous_state


func stuned_state(delta: float) -> void:
	
	return
	
	pause_animation()
	#self.modulate = Color.rebeccapurple
	if not _inside_wind:
		velocity.x = max(abs(velocity.x) - _ground_fric, 0.0) * sign(velocity.x)
	
	velocity.x = clamp(velocity.x, -ground_max_velocity, ground_max_velocity)
	stuned_time -= delta
	if stuned_time < 0:
		stuned_time = default_stuned
		#self.modulate = Color.white
		start_animation()
		_actual_state = STATE_MOVE


func pause_animation():
	pass


func start_animation():
	pass


func setting_active_property(new_value):
	active = new_value


func calculate_fall_distance() -> void:
	if velocity.y > 0 and not _first_fall:
		_initial_fall_pos = self.global_position.y
		_first_fall = true
	
	elif velocity.y > 0 and _first_fall:
		_fall_distance = (self.global_position.y - _initial_fall_pos)
	
	else:
		_first_fall = false
		_fall_distance = 0.0


func climbing_state(_delta) -> void:
	pass


func get_direction() -> float:
	if active:
		return sign(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	return 0.0


func jump() -> void:
#	inside if active
	velocity.y = -jump_force
	_was_jumped = true


func movement(accel:float, turn_accel:float, max_velocity:float, delta:float) -> void:
	#if Input.is_action_just_pressed("ui_accept") and carrying:
		#disgrab()
	#print('movemenenenenene')
	
	if _direction != 0.0:
		if _direction == sign(velocity.x) or is_equal_approx(velocity.x, 0):
			#print(accel)
			velocity.x += accel * _direction * delta
		
		else:
			velocity.x += turn_accel * _direction * delta
		
		velocity.x = clamp(velocity.x,
		 -max_velocity * carrying_velocity_multiplier,
		 max_velocity * carrying_velocity_multiplier)


func manage_animations():
	pass

func flip_nodes() -> void:
	if _direction:
		$Flip.scale.x = -_direction


func _on_horizontal_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(horizontal_attack_damage * Globals.damage_multi)


#func _on_vertical_attack_body_entered(body: Area2D) -> void:
	#if body.is_in_group("enemy"):
		#body.take_damage(vertical_attack_damage)


func horizontal_attack():
	if is_attacking == false:
		is_attacking = true
		$AnimationPlayer.play("horizontal_attack")
		await get_tree().create_timer(0.6)
		is_attacking = false
		
func vertical_attack():
	if is_attacking == false:
		is_attacking = true
		$AnimationPlayer.play("vertical_attack")
		await get_tree().create_timer(0.6)
		is_attacking = false
