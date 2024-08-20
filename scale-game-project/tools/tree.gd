extends CharacterBody2D

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
	not player.catch_area.currently_used():
		player.cut(self)
		$AnimationPlayer.play("chooping")
	if not Input.is_action_pressed("ui_accept") and player_inside:
		$AnimationPlayer.play("RESET")
		
	velocity.y += 333 * delta
	move_and_slide()


func finish_cutting() -> void:
	$AnimationPlayer.play("fall")
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
