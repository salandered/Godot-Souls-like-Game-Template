extends Node
## suits for any node with life cycle like this:
##	on_enter - update - on_exit
class_name TimeManagement


var _accumulated_time: float = 0.0
var _enter_state_ticks: int


func mark_enter_state() -> void:
	_enter_state_ticks = Time.get_ticks_msec()
	_accumulated_time = 0.0


## ignores pause and time_scale
## NOTE: needs mark_enter_state to be set beforehand
func get_real_time_spent() -> float:
	var now := Time.get_ticks_msec()
	return (now - _enter_state_ticks) / 1000.0 # Convert ms to seconds


## NOTE: needs mark_enter_state to be set beforehand
## respects pause and time_scale
## DANGER: works only if descendant uses accumulate_time_spent() in _process
func get_actual_time_spent() -> float:
	return _accumulated_time


func accumulate_time_spent(delta) -> void:
	_accumulated_time += delta