extends RefCounted
class_name ActionData

class BlendTime:
	const DEFAULT: float = 0.2
	
	var by_prev_action: Dictionary = {}
	var action_specific: float = DEFAULT
	
	
	## Priority:
	## - by prev action
	## - specific
	## - default
	func calculate_actual(prev_action_name: String) -> float:
		if by_prev_action.has(prev_action_name):
			return by_prev_action[prev_action_name]
		return action_specific
	
	func set_by_prev_action(by_prev_action_: Dictionary):
		by_prev_action = by_prev_action_


	func set_specific(action_specific_: float):
		action_specific = action_specific_


	func reset_to_default():
		action_specific = DEFAULT
		by_prev_action.clear()


class StartTimeOffset:
	const DEFAULT: float = 0.0
	
	var by_prev_action: Dictionary = {}
	var action_specific: float = DEFAULT

	## Priority:
	## - by prev action
	## - specific
	## - default
	func calculate_actual(prev_action_name: String) -> float:
		if by_prev_action.has(prev_action_name):
			return by_prev_action[prev_action_name]
		return action_specific
	
	func set_by_prev_action(by_prev_action_: Dictionary):
		by_prev_action = by_prev_action_

	func set_specific(action_specific_: float):
		action_specific = action_specific_

	func reset_to_default():
		action_specific = DEFAULT
		by_prev_action.clear()
