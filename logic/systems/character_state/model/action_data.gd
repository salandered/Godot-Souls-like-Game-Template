extends RefCounted
class_name ActionData


class _DataByPrevAction:
	var by_prev_action: Dictionary[StringName, Variant] = {}
	var DEFAULT: float
	var action_specific: float = -999.0

		
	func _init(default_: float) -> void:
		DEFAULT = default_

	## Priority:
	## - by prev action
	## - specific
	## - default
	func calculate_actual(prev_action_name: StringName) -> float:
		if by_prev_action.has(prev_action_name):
			return by_prev_action[prev_action_name]
		if action_specific != -999.0:
			return action_specific
		return DEFAULT
	
	func set_by_prev_action(by_prev_action_: Dictionary[StringName, Variant]):
		by_prev_action = by_prev_action_


	func set_specific(action_specific_: float):
		action_specific = action_specific_


	func reset_to_default():
		action_specific = -999.0
		by_prev_action.clear()


class BlendTime extends _DataByPrevAction:
	pass


class StartTimeOffset extends _DataByPrevAction:
	pass


class ExtraRootSpeedZ extends _DataByPrevAction:
	pass


class ExtraRootSpeedFadeTime extends _DataByPrevAction:
	pass
