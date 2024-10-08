extends CharacterBody2D

class_name Actor

enum {STATE_MOVE, STATE_STAND, STATE_AIR, STATE_CLIMBING, STATE_STUNED,
STATE_CARRYING, STATE_CUTTING, STATE_DAMAGE}


const TILE_SIZE = 16

const SWORD_LVL_1 = preload("res://attacks/sword_lvl_1.tscn")
const SWORD_LVL_2 = preload("res://attacks/sword_lvl_2.tscn")
const SWORD_BERZEK = preload("res://attacks/sword_lvl3.tscn")
var current_sword = SWORD_LVL_1

@export var tile_map: TileMapLayer
@export var catch_area: CatchArea
@export var enemy_area: Area2D

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

@onready var state_machine = $AnimationTree["parameters/playback"]

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

var inside_upgrade_area: bool = false
var _previous_state: int = 0
var _inside_ladder = false
var _ladder
var _bucket : Bucket
var _cut_tree: CutTree
var carrying_velocity_multiplier: float = 0.6
var default_carrying_multiplier: float = 0.5
var carrying: bool = false
var inside_well: bool = false
var inside_bucket: bool = false
var inside_tree: bool = false
@export var cut_time: float = 1.0
@onready var default_cut_time: float = cut_time
@export var _tree_scene: PackedScene
var wood_carrying: bool = false

var is_attacking: = false
var first_pick: bool = true #olha oq vc me faz fazer

var timer_tomenu = 0.35
var _timer = 0

func _process(delta: float) -> void:
	bucket_follow()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func _ready():
	add_to_group("player")
	Globals.upgrade_sword_2.connect(update_sword_2)
	Globals.upgrade_sword_berzek.connect(update_berzek_sonaro)



func _physics_process(delta):
	_direction = get_direction()
	manage_animations()
	
	_timer += delta
	if inside_upgrade_area and Input.is_action_just_pressed("x") and _timer >= timer_tomenu:
		Globals.emit_signal("show_upgrades")
		_timer = 0
	#printt(velocity, _g_multiplier, _ground_accel)s
	#print(Globals.speed_multi)
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
	
		STATE_DAMAGE:
			velocity.x = 300 * damage_dir
			if is_on_floor():
				_actual_state = STATE_MOVE
			
	velocity.y += gravity * delta * _g_multiplier
	move_and_slide()

var damage_dir = 1

func grab(bucket: Bucket) -> void:
	%Catch.play()
	_bucket = bucket
	carrying = true
	first_pick = true
	if bucket.full():
		change_velocity_multiplier()


func change_velocity_multiplier() -> void:
	return
	carrying_velocity_multiplier = default_carrying_multiplier

#top 3 nomes
func disgrab() -> void:
	%Catch.play()
	carrying = false
	carrying_velocity_multiplier = 1


func bucket_follow() -> void:
	#print(carrying)
	if is_instance_valid(_bucket) and carrying:
		_bucket.global_position = %BucketPos.global_position
	
	if Input.is_action_just_pressed("ui_accept") and is_instance_valid(_bucket)\
	and carrying and not inside_well:
		if not first_pick:
			disgrab()
			_bucket.dishold(velocity * 100)
		first_pick = false


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
	
	state_machine.travel("tree")
	
	if cut_time < 0:
		if is_instance_valid(_cut_tree):
			_cut_tree.finish_cutting()
			var _tree_pos:Vector2 = self.global_position
			get_tree().create_timer(Globals.spawn_tree_time * Globals.spawn_tree_multi).timeout.connect(func():
				var new_tree:Node = _tree_scene.instantiate()
				new_tree.global_position = _tree_pos + Vector2(randf_range(-50, 50),
				-400)
				get_tree().current_scene.add_child(new_tree))
		cutting_state_exit()
	
	friction(_ground_fric, delta)


func cutting_state_exit() -> void:
	cut_time = default_cut_time * Globals.cut_speed_multi
	if is_on_floor():
		_actual_state = STATE_STAND
	else:
		_actual_state = STATE_AIR


func friction(frict: float, delta: float):
	velocity.x = max(abs(velocity.x) - frict * delta, 0.0) * sign(velocity.x)


func stand_state(delta: float) -> void:
	flip_nodes()
	if wood_carrying or carrying:
		state_machine.travel("hold")
	else:
		state_machine.travel("idle")
	friction(_ground_fric, delta)
	
	#velocity.x = clamp(velocity.x, -ground_max_velocity, ground_max_velocity)
	
	if _direction != 0:
		_actual_state = STATE_MOVE
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	
	if Input.is_action_just_pressed("ui_accept"):
			horizontal_attack()
	
	if not is_on_floor():
		_actual_state = STATE_AIR


func move_state(delta: float) -> void:
	flip_nodes()
	#SPEED MULTIPLIER BRONCA BRONCA ALARME]
	if wood_carrying or carrying:
		state_machine.travel("hold_walk")
	else:
		state_machine.travel("walk")
	
	movement(_ground_accel, _ground_turn_accel, ground_max_velocity * Globals.speed_multi, delta)
		
	if _direction == 0.0:
		flip_time -= delta
		if flip_time < 0:
			_actual_state = STATE_STAND
	
	else:
		flip_time = 0.1
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
		state_machine.travel("jump")
	
	if not is_on_floor():
		_actual_state = STATE_AIR
	
	if Input.is_action_just_pressed("ui_accept"):
			horizontal_attack()


func air_state(delta: float) -> void:
	flip_nodes()
	movement(_air_accel, _air_turn_accel, air_max_velocity, delta)
	calculate_fall_distance()
	
	state_machine.travel("jump")
	
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
	
	if Input.is_action_just_pressed("ui_accept"):
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
	%AudioStreamPlayer2D.play()
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
		 -max_velocity,
		 max_velocity)


func manage_animations():
	pass


func flip_nodes() -> void:
	if _direction:
		$Flip.scale.x = _direction


func horizontal_attack() -> void:
	#print(inside_tree)
	if enemy_area.has_overlapping_bodies() and not is_attacking:
		atack()
		return
	if not is_attacking and not carrying and not wood_carrying and \
	not inside_tree and not catch_area.currently_used() and \
	not $Flip/MiningPos.can_mining() and not inside_bucket:
		atack()


func atack() -> void:
	%Sword.play()
	is_attacking = true
	var sw = current_sword.instantiate()
	$Flip/AtkPivot.add_child(sw)
	sw.ended.connect(set_can_attacking)


func set_can_attacking() -> void:
	is_attacking = false


func update_sword_2() -> void:
	current_sword = SWORD_LVL_2 


func update_berzek_sonaro() -> void:
	current_sword = SWORD_BERZEK


func take_damage(vector: Vector2) -> void:
	if _actual_state == STATE_DAMAGE:
		return
	_actual_state = STATE_DAMAGE
	damage_dir = -sign(vector.x)
	#print(damage_dir)
	velocity.y = -200
	
