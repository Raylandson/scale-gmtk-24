extends CharacterBody2D

class_name CutTree
var player: Actor
var player_inside: bool = false
@export var log_quantity: int = 3
@export var log_scene: PackedScene

func _ready() -> void:
	pass



func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and player_inside\
	and is_instance_valid(player) and not player.carrying \
	and not player.inside_bucket and not player.wood_carrying:
		player.cut(self)
	
	velocity.y += 222 * delta
	move_and_slide()


func finish_cutting() -> void:
	#colocar umas particula e uns fru fru aqui, tu manja disso
	spawn_logs()
	#await get_tree().create_timer(0.1).timeout
	#self.queue_free()


func spawn_logs() -> void:
	for i in range(log_quantity):
		var new_log: RigidBody2D = log_scene.instantiate()
		new_log.global_position = self.global_position
		get_tree().current_scene.add_child(new_log)
		print('log spawned')
		#await get_tree().create_timer(0.01).timeout
	
	self.queue_free()


func _on_cut_area_body_entered(body: Node2D) -> void:
	if body is Actor:
		player = body
		player_inside = true


func _on_cut_area_body_exited(body: Node2D) -> void:
	if body is Actor:
		player_inside = false
