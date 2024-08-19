extends CharacterBody2D

enum States{MOVING, ATTACKING, DEATH, IDLE}
var current_state = States.MOVING

@export var speed = 8
@export var gravity = 50
@export var attack_distance_threshold = 50

@export var health_points = 50
@onready var current_health_points = health_points


var direction = Vector2.ZERO 
var target = null


func _ready():
	pass
	
	
func _physics_process(delta):
	
	velocity.y += gravity
	
	target = get_tree().get_first_node_in_group("seed")
	
		
	match current_state:
		States.IDLE:
			direction = Vector2.ZERO
			
			if is_instance_valid(target) and self.global_position.distance_to(target.global_position) < attack_distance_threshold:
				current_state = States.ATTACKING
				
		States.MOVING:
			if is_instance_valid(target):
				direction = self.global_position.direction_to(target.global_position).normalized()
			
			if is_instance_valid(target) and self.global_position.distance_to(target.global_position) < attack_distance_threshold:
				current_state = States.ATTACKING
				
		
		States.ATTACKING:
			#ataque
			direction = Vector2.ZERO
		
	velocity.x = speed * direction.x
	if sign(direction.x) == -1:
		$AnimationPlayer.play("movingR")
	elif sign(direction.x) == 1:
		$AnimationPlayer.play("movingL")
	move_and_slide()


func take_damage(damage : float):
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
