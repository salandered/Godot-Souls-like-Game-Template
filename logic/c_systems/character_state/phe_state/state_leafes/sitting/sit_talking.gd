extends BasePHELeaf


var _target_duration: float = 0.0


func on_enter_state() -> void:
	_target_duration = ra.float_range(6.0, 40.0)


func is_ended() -> bool:
	var _r := false
	if works_longer_than(_target_duration):
		return true
	elif time_remaining() < TIME_REMAINING_TO_END:
		return true
	return _r