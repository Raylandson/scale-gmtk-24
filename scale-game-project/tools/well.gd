extends Area2D

@export var water_quantity: int = 3

var _player: Actor
var _player_inside: bool = false


func _process(delta: float) -> void:
	
	#encher o balde de agua
	if Input.is_action_just_pressed("ui_accept") and _player_inside:
		if is_instance_valid(_player) \
		and _player.carrying\
		and water_quantity > 0:
			if _player._bucket.full():
				_player_inside = false
				_player.inside_well = false
			water_quantity = _player._bucket.catch_water(water_quantity)
			_player.change_velocity_multiplier()
			#printt(water_quantity)



func _on_body_entered(body: Node2D) -> void:
	
	if body is Actor:
		if water_quantity <= 0 or (body.carrying \
		and is_instance_valid(body._bucket) and body._bucket.full()):
			body.inside_well = false
			_player_inside = false
			return
		
		_player_inside = true
		_player = body
		_player.inside_well = true


func _on_body_exited(body: Node2D) -> void:
	if body is Actor:
		_player_inside = false
		_player.inside_well = false
