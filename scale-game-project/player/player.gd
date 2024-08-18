extends CharacterBody2D

#class_name Actor

enum {STATE_MOVE, STATE_STAND, STATE_AIR, STATE_CLIMBING, STATE_STUNED}


const TILE_SIZE = 16

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
var flip_time = 0.1
@export_range (0.0, 5.0) var stuned_time: float= 3.0
var default_stuned := stuned_time

var active = true 

@onready var _default_gravity = 2 * jump_size / (pow(fall_time, 2)/2) 
@onready var _gravity_multiplier = jump_size/min_jump_size
@onready var _ground_fric = ground_max_velocity / (ground_fric_time * _engine_fps) #fps
@onready var _ground_accel = ground_max_velocity / (ground_accel_time * _engine_fps) #fps
@onready var _ground_turn_accel = ground_max_velocity / (ground_turn_time * _engine_fps) #fps
@onready var _air_fric = air_max_velocity / (air_fric_time * _engine_fps) #fps
@onready var _air_accel = air_max_velocity / (air_accel_time * _engine_fps) #fps
@onready var _air_turn_accel = air_max_velocity / (air_turn_time * _engine_fps) #fps

@onready var _default_buffering_time = buffering_time
@onready var _default_coyote_time = coyote_time
var snap = Vector2.ZERO
var _inside_wind = false
var _initial_fall_pos := 2.0
var _fall_distance := 0.0
var _g_multiplier := 1.0
var _direction := 0.0
var _actual_state = STATE_STAND
#var velocity := Vector2.ZERO
var _first_fall : bool = false
var _jump_pressed : bool = false
var _was_jumped : bool = false
var _engine_fps = Engine.get_frames_per_second()

var _previous_state: int = 0
var _inside_ladder = false
var _ladder


func _ready():
	add_to_group("player")


func _physics_process(delta):
	_direction = get_direction()
	manage_animations()
	#printt(velocity, _g_multiplier)
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
	
	
	velocity.y += gravity * delta * _g_multiplier
	move_and_slide()


func stand_state(delta):
	flip_nodes()
	
	if not _inside_wind:
		velocity.x = max(abs(velocity.x) - _ground_fric, 0.0) * sign(velocity.x)
	
	velocity.x = clamp(velocity.x, -ground_max_velocity, ground_max_velocity)
	
	if _direction != 0:
		_actual_state = STATE_MOVE
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	
	if not is_on_floor():
		_actual_state = STATE_AIR


func move_state(delta):
	flip_nodes()
	movement(_ground_accel, _ground_turn_accel, ground_max_velocity)
		
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


func air_state(delta):
	flip_nodes()
	movement(_air_accel, _air_turn_accel, air_max_velocity)
	calculate_fall_distance()
	
	if _direction == 0.0:
		velocity.x = max(abs(velocity.x) - _air_fric, 0.0) * sign(velocity.x)
	
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


func stuned_state(delta) -> void:
	
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


func climbing_state(_delta):
	pass


func get_direction() -> float:
	if active:
		return sign(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	return 0.0


func jump():
#	inside if active
	velocity.y = -jump_force
	_was_jumped = true


func movement(accel:float, turn_accel:float, max_velocity:float) -> void:
	if _direction != 0.0:
		if _direction == sign(velocity.x) or is_equal_approx(velocity.x, 0):
			velocity.x += accel * _direction
		
		else:
			velocity.x += turn_accel * _direction
		
		velocity.x = clamp(velocity.x, -max_velocity, max_velocity)


func manage_animations():
	pass

func flip_nodes():
	if _direction:
		$Flip.scale.x = -_direction
	return
