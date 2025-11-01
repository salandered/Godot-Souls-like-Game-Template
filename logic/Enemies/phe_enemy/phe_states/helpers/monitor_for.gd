extends RefCounted
class_name PHEHelpers

class MonitorFor:
	## STATIC
	# will monitor state for random '_duration' set between _min and _max
	# these are static defaults, but set_random() supports overriding
	var _min: float
	var _max: float
	# state this helper monitors, static default
	var _state_name: String
	## DYNAMIC
	# will monitor state for this time
	var _duration: float = -1.0
	## NOTE: should be updated in _process using accumulate_time()
	var _timer: float = -1.0


	func _init(min_: float, max_: float, _state_name_: String) -> void:
		self._min = min_
		self._max = max_
		self._state_name = _state_name_


	## DOCS:
	## designed in a way, that after implementing _auto_update, helper can be used via only two methods:
	##   - 'is_done' for checking
	##   - calling 'auto_update' in _process for all the internal machinery
	## But if it feels too abstract, u can use exposed methods like manual 'set_random' and 'reset'

	func is_done() -> bool:
		if not is_set():
			return true # not set = done (we r not in waiting period)
		return _timer >= _duration


	func auto_update(delta: float, current_substate_name: String, _next_state_name: String, min_: float = -1.0, max_: float = -1.0):
		accumulate_time(delta)
		_auto_update(current_substate_name, _next_state_name, min_, max_)


	## override this to make monitor easier to use via auto_update
	## implementation SHOULD auto set and reset monitor.
	func _auto_update(current_substate_name: String, _next_state_name: String, min_: float = -1.0, max_: float = -1.0):
		pass


	func reset() -> void:
		_duration = -1.0
		_timer = -1.0
	

	func is_set() -> bool:
		return _duration != -1.0 and _timer != -1.0


	func set_random(min_: float = -1.0, max_: float = -1.0) -> void:
		if min_ != -1.0 and max_ != -1.0:
			_duration = randf_range(min_, max_)
		else:
			_duration = randf_range(_min, _max)
		_timer = 0.0


	# in case u want it the old deterministic way
	func set_specific(value: float) -> void:
		set_random(value, value)

	func get_current_value() -> float:
		return _duration

	func accumulate_time(delta: float) -> void:
		if is_set():
			_timer += delta

	func _is_switch_from(current_substate_name: String, _next_state_name: String) -> bool:
		return current_substate_name == _state_name and _next_state_name != _state_name
	
	func _is_switch_to(current_substate_name: String, _next_state_name: String) -> bool:
		return current_substate_name != _state_name and _next_state_name == _state_name

	func __pp_set_random() -> String:
		return pp.s("set_random for", _state_name, "to", _duration)

	func __pp_is_done() -> String:
		return pp.s(_state_name, "is done. worked > ", _duration)


class WillNotDoFor extends MonitorFor:
	## returns true if was set
	func _auto_set_on_switch_from(current_substate_name: String, _next_state_name: String, min_: float = -1.0, max_: float = -1.0) -> bool:
		if _is_switch_from(current_substate_name, _next_state_name):
			# if is_set(): print_.warn("_auto_set_on_switch_from triggered set, but already was set")
			set_random(min_, max_)
			return true
		else:
			return false

	## returns true if was reset
	func _auto_reset_on_switch_to(current_substate_name: String, _next_state_name: String) -> bool:
		if _is_switch_to(current_substate_name, _next_state_name):
			reset()
			return true
		else:
			return false

	func _auto_update(current_substate_name: String, _next_state_name: String, min_: float = -1.0, max_: float = -1.0):
		var _is_set := _auto_set_on_switch_from(current_substate_name, _next_state_name, min_, max_)
		var _is_reset := _auto_reset_on_switch_to(current_substate_name, _next_state_name)

		if _is_reset and _is_set:
			print_.warn("something strange happened; by design both function cant complete their task")


class WillDoFor extends MonitorFor:
	## alternative way to check result, without using is_done() (ignoring accumulate_time as well)
	func is_done_using_substate(curr_sub: BasePHEState) -> bool:
		if curr_sub.state_name != _state_name:
			print_.warn(pp.s("WillDoFor.is_done state name mismatch. Init with", _state_name, "Got", curr_sub.state_name, "Will return true"))
			return true
		if curr_sub.get_actual_time_spent() > _duration:
			return true
		return false


	## returns true if was set
	func _auto_set_on_switch_to(current_substate_name: String, _next_state_name: String, min_: float = -1.0, max_: float = -1.0) -> bool:
		if _is_switch_to(current_substate_name, _next_state_name):
			# if is_set(): print_.warn("_auto_set_on_switch_to triggered set, but already was set")
			set_random(min_, max_)
			return true
		else:
			return false

	## returns true if was reset
	func _auto_reset_on_switch_from(current_substate_name: String, _next_state_name: String) -> bool:
		if _is_switch_from(current_substate_name, _next_state_name):
			reset()
			return true
		else:
			return false

	func _auto_update(current_substate_name: String, _next_state_name: String, min_: float = -1.0, max_: float = -1.0):
		var _is_set := _auto_set_on_switch_to(current_substate_name, _next_state_name, min_, max_)
		var _is_reset := _auto_reset_on_switch_from(current_substate_name, _next_state_name)

		if _is_reset and _is_set:
			print_.warn("something strange happened; by design both function cant complete their task")
