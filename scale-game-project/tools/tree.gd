extends RigidBody2D

class_name CutTree
var player: Actor
var player_inside: bool = false
@export var log_quantity: int = 2
@export var log_scene: PackedScene
#@export var _tree_scene: PackedScene

func _ready() -> void:
	randomize()
	$Sprite2D.texture = load("res://assets/sprites/tree" + str(randi_range(0, 2)) + ".png")
	pass



func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and player_inside\
	and is_instance_valid(player) and not player.carrying \
	and not player.inside_bucket and not player.wood_carrying and \
	not player.catch_area.currently_used() and not animation:
		player.cut(self)
		$AnimationPlayer.play("chooping")
	if not Input.is_action_pressed("ui_accept") and player_inside \
	and not animation:
		$AnimationPlayer.play("RESET")
	#velocity.y += 222 * delta
		
	#move_and_slide()
	if animation:
		print(linear_velocity.length())
	if animation and abs(linear_velocity.length()) <= 2:
		create_wood_material()
		queue_free()

var animation = false
func finish_cutting() -> void:
	#$AnimationPlayer.play("fall")
	$InteractButtonUi.queue_free()
	print(11111111)
	$AnimationPlayer.play("RESET")
	lock_rotation = false
	#apply_central_force(Vector2(-20000, -60000))
	var sign := 1 if randi() % 2 == 0 else -1
	
	apply_force(Vector2(500 * sign * randf_range(0.6, 1.0), 
	-4000 * randf_range(0.6, 1.0)), Vector2(-50 * -sign, 0))
	get_tree().create_timer(0.5).timeout.connect(func():
		animation = true
		)
	#to ficando maluco ja, crazy


func _on_cut_area_body_entered(body: Node2D) -> void:
	if body is Actor:
		player = body
		player.inside_tree = true
		player_inside = true


func _on_cut_area_body_exited(body: Node2D) -> void:
	if body is Actor:
		player.inside_tree = false
		player_inside = false


func create_wood_material():
	for i in range(log_quantity):
		var new_log: RigidBody2D = log_scene.instantiate()
		new_log.global_position = self.global_position
		get_tree().current_scene.add_child(new_log)
