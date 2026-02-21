extends RefCounted
class_name PHEHelpers

class MonitorFor extends RefCountedSystem:
	## STATIC
	# will monitor state for random '_duration' set between _min and _max
	# these are static defaults, but set_random() supports overriding
	var _min: float
	var _max: float
	# state this helper monitors, static default
	var _our_state: StringName
	## DYNAMIC
	# will monitor state for this time
	var _duration: float = -1.0
	## NOTE: should be updated in _process using accumulate_time()
	var _timer: float = -1.0

	func _init(min_: float, max_: float, state_name_: StringName) -> void:
		self._min = min_
		self._max = max_
		self._our_state = state_name_


	func calibrate_min_max(min_: float = -1.0, max_: float = -1.0) -> void:
		if min_ != -1.0:
			self._min = min_
		if max_ != -1.0:
			self._max = max_

	## DOCS:
	## designed in a way, that after implementing _auto_update, helper can be used via only two methods:
	##   - 'is_done' for checking
	##   - calling 'auto_update' in _process for all the internal machinery
	## But if it feels too abstract, u can use exposed methods like manual 'set_random' and 'reset'

	func is_done() -> bool:
		var _r: bool = false
		var _reason: String = ""
		if not is_set():
			if __LOG_B(): _reason += "not set = done (we r not in waiting period)"
			_r = true
		else:
			if __LOG_B(): _reason += "compare _timer and _duration" + pp.s(_timer, _duration)
			_r = _timer >= _duration
		return _r


	## Basic curr_substate/next_substate pairs (Assume ours is A):
	## A, B
	## B, A
	## A, A
	## C, B
	func auto_update(delta: float, curr_substate: StringName, next_substate: StringName, min_: float = -1.0, max_: float = -1.0, __log: String = ""):
		accumulate_time(delta)
		_auto_update(curr_substate, next_substate, min_, max_, __log)


	## override this to make monitor easier to use via auto_update
	## implementation SHOULD auto set and reset monitor.
	func _auto_update(curr_substate: StringName, next_substate: StringName, min_: float = -1.0, max_: float = -1.0, __log: String = ""):
		pass


	func reset(__log: String = "") -> void:
		if is_set():
			_duration = -1.0
			_timer = -1.0
			if __LOG_B(): __log_(__pp_reset(), "   |", __log)
	

	func is_set() -> bool:
		return _duration != -1.0 and _timer != -1.0


	func set_random(min_: float = -1.0, max_: float = -1.0, __log: String = "") -> void:
		var _already_set: bool = false
		if is_set():
			_already_set = true

		if min_ != -1.0 and max_ != -1.0:
			_duration = randf_range(min_, max_)
		else:
			_duration = randf_range(_min, _max)
		_timer = 0.0

		if __LOG_B():
			var _msg := "{set again} for " + _our_state if _already_set else "{set} " + __pp_set_random()
			__log_(_msg, "   |", __log)


	# in case u want it the old deterministic way
	func set_specific(value: float) -> void:
		set_random(value, value)

	func get_current_value() -> float:
		return _duration

	func accumulate_time(delta: float) -> void:
		if is_set():
			_timer += delta

	func _is_switch_from_our(curr_substate: StringName, next_substate: StringName) -> bool:
		return curr_substate == _our_state and next_substate != _our_state
	
	func _is_switch_to_our(curr_substate: StringName, next_substate: StringName) -> bool:
		return curr_substate != _our_state and next_substate == _our_state

	func _is_switch_not_related(curr_substate: StringName, next_substate: StringName) -> bool:
		return curr_substate != _our_state and next_substate != _our_state

	func _is_both_are_ours(curr_substate: StringName, next_substate: StringName) -> bool:
		return curr_substate == _our_state and next_substate == _our_state

	func __pp_set_random() -> String:
		return pp.s("set_random for", _our_state, "to", _duration)
	
	func __pp_reset() -> String:
		return pp.s("reset for", _our_state)

	func __pp_is_done() -> String:
		return pp.s(_our_state, "is done. worked >", _duration)


	## __LOGS
	# region

	func pp_name() -> String:
		return "MonitorFor"

	func __LOG_B() -> bool:
		return false

	func __LOG_INDENT() -> int:
		return 17

	static func pair_log(a, b) -> String:
		return "(%s, %s)" % [a, b]

	# endregion


class WillDoFor extends MonitorFor:
	## alternative way to check result, without using is_done() (ignoring accumulate_time as well)
	func is_done_using_substate(curr_sub: BasePHEState) -> bool:
		if curr_sub.state_name != _our_state:
			__log_warn(pp.s("WillDoFor.is_done state name mismatch. Init with", _our_state, "Got", curr_sub.state_name, "Will return true"))
			return true
		if curr_sub.get_actual_time_spent() > _duration:
			return true
		return false

	## curr/next if we monitor A
	## A, A - will set if was not set (normally we already set)
	## B, A - will set again if was already set! (normally we were reset) because it's an explicit switch.
	## "", A - behaviour is the same as B, A
	func _auto_set_on_switch_to(curr_substate: StringName, next_substate: StringName, min_: float = -1.0, max_: float = -1.0, __log: String = ""):
		if _is_switch_to_our(curr_substate, next_substate):
			set_random(min_, max_, __log + " " + pair_log(curr_substate, next_substate) if __LOG_B() else "")
		elif _is_both_are_ours(curr_substate, next_substate) and not is_set():
			set_random(min_, max_, __log + " " + pair_log(curr_substate, next_substate) if __LOG_B() else "")


	func _auto_reset_on_switch_from(curr_substate: StringName, next_substate: StringName, __log: String = ""):
		if _is_switch_from_our(curr_substate, next_substate) \
			or _is_switch_not_related(curr_substate, next_substate):
			reset(__log + " " + pair_log(curr_substate, next_substate) if __LOG_B() else "")

	func _auto_update(curr_substate: StringName, next_substate: StringName, min_: float = -1.0, max_: float = -1.0, __log: String = ""):
		_auto_set_on_switch_to(curr_substate, next_substate, min_, max_, __log)
		_auto_reset_on_switch_from(curr_substate, next_substate, __log)

	func pp_name() -> String:
		return "⏲️WillDoFor"


class WillNotDoFor extends MonitorFor:
	## curr/next if we monitor A
	## A, A - will reset 
	## A, B - will set again if was already set! (normally it doesnt happen in a row)
	## "", A - behaviour is the same as B, A
	func _auto_set_on_switch_from(curr_substate: StringName, next_substate: StringName, min_: float = -1.0, max_: float = -1.0, __log: String = ""):
		if _is_switch_from_our(curr_substate, next_substate):
			set_random(min_, max_, __log + " " + pair_log(curr_substate, next_substate) if __LOG_B() else "")

	func _auto_reset_on_switch_to(curr_substate: StringName, next_substate: StringName, __log: String = ""):
		if _is_switch_to_our(curr_substate, next_substate) or \
			_is_both_are_ours(curr_substate, next_substate):
			reset(__log + " " + pair_log(curr_substate, next_substate) if __LOG_B() else "")

	func _auto_update(curr_substate: StringName, next_substate: StringName, min_: float = -1.0, max_: float = -1.0, __log: String = ""):
		_auto_set_on_switch_from(curr_substate, next_substate, min_, max_, __log)
		_auto_reset_on_switch_to(curr_substate, next_substate, __log)


	func pp_name() -> String:
		return "⏰WillNotDoFor"
