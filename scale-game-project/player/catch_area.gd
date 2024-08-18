extends Area2D

var items_list: Array = []
var current_itens: Array = []
@export var player: Actor
@export var catch_position: Marker2D
@export var offset_pos:float = 5.5
var timer := 0.5
var max_carrying_items: int = 3
var can_catch_timer = 0.1



func _process(delta: float) -> void:
	timer -= delta
	
	var count = 0
	
	for item:Node2D in current_itens:
		if is_instance_valid(item):
			item.global_position = catch_position.global_position\
			+ Vector2(0, -count * offset_pos)
		else:
			current_itens.erase(item)
		count+= 1
	
	
	
	if timer < 0:
		printt(player.carrying, player.wood_carrying, current_itens.size(), 
		items_list.is_empty(), current_itens, items_list)
		timer = 0.5
	
	can_catch_timer -= delta
	
	if Input.is_action_just_pressed("ui_accept") and player.wood_carrying \
		and (items_list.is_empty() or current_itens.size() >= max_carrying_items) \
		and not current_itens.is_empty():

		var items_copy: Array = current_itens.duplicate()
		
		for item:Node2D in items_copy:
			if items_list.size() < max_carrying_items:
				items_list.append(item)
			
			if item is CollectableItem:
				item.set_freeze(false)
				var base_vector: Vector2 = item.random_direction_upwards()
				
				item.apply_central_force(player.velocity * 30 + \
				base_vector * randf_range(1, 5)) # esse numero magico eh psico
			current_itens.erase(item)
			print('item deletado', item.name)
		
		if current_itens.is_empty():
			player.wood_carrying = false
		#tem que ter esse return
		return
		
	if Input.is_action_just_pressed("ui_accept") and not player.carrying \
		and (not player.wood_carrying or current_itens.size() < max_carrying_items) \
		and not items_list.is_empty():
		print('catching wood')
		
		var items_copy: Array = items_list.duplicate() 
		
		for item: Node2D in items_copy:
			if current_itens.size() >= max_carrying_items:
				break 
			if current_itens.has(item):
				continue
			if item is CollectableItem:
				item.set_freeze(true)
			current_itens.append(item)
			items_list.erase(item)

		player.wood_carrying = true



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("CatchItem") and not current_itens.has(body) \
	and not items_list.has(body) and items_list.size() < max_carrying_items:
		#gptenio maluco logo 2 if pra confima com a mesma bool
		if items_list.size() < max_carrying_items:
			items_list.append(body)


func _on_body_exited(body: Node2D) -> void:
	if items_list.has(body):
		items_list.erase(body)
