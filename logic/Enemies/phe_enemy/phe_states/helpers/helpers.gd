extends RefCounted
class_name PHEHelpers

class WillDoFor:
	var _min: float
	var _max: float
	var _state_name: String
	var _current_value: float = -1.0

	func _init(_min_: float, _max_: float, _state_name_: String) -> void:
		self._min = _min_
		self._max = _max_
		self._state_name = _state_name_

	func set_random() -> void:
		_current_value = randf_range(_min, _max)

	func get_current_value() -> float:
		return _current_value

	func is_done(curr_sub: BasePHEState) -> bool:
		if curr_sub.state_name != _state_name:
			print_.warn(pp.s("WillDoFor.is_done state name mismatch. Init with", _state_name, "Got", curr_sub.state_name, "Will return true"))
			return true
		if curr_sub.get_actual_time_spent() > _current_value:
			return true
		return false


	func __pp_set_random() -> String:
		return pp.s("set_random for", _state_name, "to", _current_value)

	func __pp_is_done() -> String:
		return pp.s(_state_name, "is done. worked > ", _current_value)

