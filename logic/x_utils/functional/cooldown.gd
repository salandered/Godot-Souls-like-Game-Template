class_name Cooldown
extends RefCountedLogger

var _cooldown_period: float
var _last_time: float = -1.0


func _init(cooldown_sec: float) -> void:
	_cooldown_period = cooldown_sec


func is_cooldown_passed(__log_remaining_time_on_false: bool = false, __log_context: String = "") -> bool:
	var _remaining_time := get_remaining_time()
	if _remaining_time <= 0.0:
		return true
	else:
		if __log_remaining_time_on_false:
			__log_("cooldown not passed", "time remaining", _remaining_time, "context:", pp.in_q(__log_context))
		return false


func mark_time() -> void:
	_last_time = _get_time_sec()


func get_remaining_time() -> float:
	if _last_time < 0:
		return 0.0
	
	var diff := _get_time_sec() - _last_time
	return maxf(0.0, _cooldown_period - diff)


func get_progress() -> float:
	if _cooldown_period <= 0:
		return 1.0
	return 1.0 - (get_remaining_time() / _cooldown_period)

func _get_time_sec() -> float:
	return u.get_curr_time_ticks_sec()
