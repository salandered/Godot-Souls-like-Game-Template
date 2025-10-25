extends RefCounted
# var _queued_states = []


# func add_queued_state(state_name: String):
# 	_queued_states.append(state_name)


# func reset_queued_states(state_name: String):
# 	if has_queued_state:
# 		print_.phe_sm("", pp.s("resetting _queued_states", pp.list_(_queued_states)))
# 	_queued_states = []


# func has_queued_state() -> bool:
# 	return len(_queued_states) > 0


# func get_first_queued_state() -> String:
# 	if has_queued_state():
# 		return _queued_states[0]
# 	else:
# 		print_.warn("no queued state, return empty string")
# 		return ""