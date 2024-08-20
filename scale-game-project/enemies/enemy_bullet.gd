extends Area2D

var damage = 5
var direction = Vector2.ZERO
var speed = 150


func _process(delta):
	self.translate(direction * speed * delta)


func _on_body_entered(body):
	if body.is_in_group("seed"):
		body.take_damage(damage)
		self.queue_free()


func set_direction(_direction):
	direction = _direction
	pass
