extends BasePHELeaf

var _target_duration: float = 0.0


func is_ended() -> bool:
	return works_longer_than(_target_duration)


func on_enter_state() -> void:
	_target_duration = ra.float_range(7.0, 20.0)
