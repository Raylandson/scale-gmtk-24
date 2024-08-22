extends Camera2D

var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)
 
var _can_run := true
 
@export var player: Actor


func _ready():
	Globals.call_shake.connect(shake)
	randomize()
	_can_run = true


func _process(delta): 
	if _can_run:
		_update(delta)
	drag_vertical_enabled = not player.is_on_floor()
 

func _update(delta):
	if _timer == 0:
		set_offset(Vector2())
		_can_run = false
		return
	_last_shook_timer = _last_shook_timer + delta
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		var new_x = randf_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y = randf_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		var new_offset = Vector2(x_component, y_component)
		set_offset(get_offset() - _last_offset + new_offset)
		_last_offset = new_offset
	_timer = _timer - delta
	if _timer <= 0:
		_timer = 0
		set_offset(get_offset() - _last_offset)
 
 
func shake(duration:float, frequency:float, amplitude:float):
	if(_timer != 0):
		return
 
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = randf_range(-1.0, 1.0)
	_previous_y = randf_range(-1.0, 1.0)
	set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)
	_can_run = true

	
