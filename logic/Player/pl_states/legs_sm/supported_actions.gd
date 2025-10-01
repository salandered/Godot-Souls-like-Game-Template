extends RefCounted
class_name SupportedActions


var _motion_type_to_action := {}
var actions := []


func _init(motion_to_action_: Dictionary):
	_motion_type_to_action = motion_to_action_
	
	for action in _motion_type_to_action.values():
		if action not in actions:
			actions.append(action)

	__validation()
	print_.lsm_beh(" _ready()", _to_string())


func get_by_motion(motion) -> String:
	return _motion_type_to_action[motion]


func _to_string() -> String:
	return "supported actions: " + pp._array(actions) + "\n_motion_type_to_action:\n" + pp._dict(_motion_type_to_action)


func __validation():
	for type_ in MotionType.get_all_types():
		assert(_motion_type_to_action.has(type_),
			pp.s("SupportedActions must contain all motion types:", type_, "is missing"))
		var value = _motion_type_to_action[type_]
		assert(value is String and value != "")
	assert(len(actions) > 0, "actions len empty")