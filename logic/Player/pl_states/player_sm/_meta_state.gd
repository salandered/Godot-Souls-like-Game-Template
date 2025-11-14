extends RefCounted
class_name MetaState


## State that can interrupt current SM flow. For now I cant come up with the word for describing it. 
## (like preemption, interruption, ...)

@abstract class _MetaState extends RefCounted:
	var _state_name: String
	var _state_priority: int

	func _init() -> void:
		_state_name = ""
		_state_priority = -1

	func set_from_other(new_state: String, new_priority: int):
		__log_(__pp_state(new_state, new_priority), " ", pp.in_br("from " + __pp_curr_state()))
		_state_name = new_state
		_state_priority = new_priority

	func reset() -> void:
		if _state_name != "" or _state_priority != -1:
			__log_(pp.in_q(_state_name), pp.in_curl(_state_priority), "will be resetted")
		_state_name = ""
		_state_priority = -1

	func get_state_name():
		return _state_name

	func get_state_priority():
		return _state_priority

	func is_set_to(another_state_name_: String) -> bool:
		return _state_name == another_state_name_

	func is_set() -> bool:
		return _state_name != ""

	func try_set(new_state: String, new_priority: int, equal_wins: bool = true) -> void:
		if not is_set():
			set_state(new_state, new_priority)
			return
		if new_priority > _state_priority:
			set_state(new_state, new_priority)
			return
		 # QUESTION: when > or >=
		if equal_wins and new_priority == _state_priority:
			set_state(new_state, new_priority)
			return

		__log_("couldn't set", __pp_state(new_state, new_priority), "equal_wins", equal_wins)

	func set_state(new_state: String, new_priority: int):
		__log_(__pp_state(new_state, new_priority), " ", pp.in_br("from " + __pp_curr_state()))
		_state_name = new_state
		_state_priority = new_priority
	
	func set_from_another(new_state: _MetaState) -> void:
		set_state(new_state.get_state_name(), new_state.get_state_priority())

	func try_set_from_another(new_state: _MetaState, equal_wins: bool = true) -> void:
		try_set(new_state.get_state_name(), new_state.get_state_priority(), equal_wins)

	# region __LOGS
	func __pp_state(state_name_: String, _state_priority_: int) -> String:
		if state_name_ == "" and _state_priority_ == -1:
			return "- x -"
		return __pp_type() + " '%s' {%d}" % [state_name_, _state_priority_]
	
	func __pp_curr_state() -> String:
		return __pp_state(_state_name, _state_priority)
	
	@abstract func __pp_type() -> String

	## like Queued or Forced
	func __log_(...parts: Array) -> void:
		if print_.META_STATES_B:
			print_.prefix_s(pp.s(__pp_type(), get_instance_id()), pp.list_(parts))

	func _to_string() -> String:
		return __pp_curr_state()
	# endregion


## NOTE: godot tool formatter doesnt like this setup. something with @abstract method. 
## '\' helps
class Queued \
	extends _MetaState:
	func __pp_type() -> String:
		return "QueuedState👥"


class Forced extends _MetaState:
	func __pp_type() -> String:
		return "ForcedState🦾"
