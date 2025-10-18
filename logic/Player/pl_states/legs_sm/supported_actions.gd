extends RefCounted
class_name SupportedActions


var _motion_type_to_default_action := {}
var action_names := []


func _init(motion_to_action_: Dictionary, additional_actions: Array):
	_motion_type_to_default_action = motion_to_action_
	
	for name_ in _motion_type_to_default_action.values():
		if name_ not in action_names:
			action_names.append(name_)
			

	## we can add any additional action_names. 
	## main difference is that behavior needs to use their name directly. (for now)
	## how do we know we support it? see convert_to_supported()
	for name_ in additional_actions:
		if name_ not in action_names:
			action_names.append(name_)

	__validation()
	print_.lsm_beh(" _ready()", _to_string())


## mandatory method for every behavior's initial decision
func convert_to_supported(action: LegsAction) -> String:
	if is_action_supported(action.action_name):
		return action.action_name
	else:
		print_.lsm_beh("", pp.in_q(action.action_name) + " is not supported. will return default supported with the same motion type")
		return default_by_motion(action.motion_type)


func is_action_supported(requested_name: String) -> bool:
	return requested_name in action_names


func by_name(requested_name: String) -> String:
	## NOTE: There shouldnt be a problem of using an action in curr behavior SM which it doesnt support.
	## (because of convert_to_supported mechanic) 
	## But we may prevent this in the future: we ll return default action by the same type. 
	if not is_action_supported(requested_name):
		print_.warn(requested_name + " cant be find in supported actions: " + str(action_names))
	return requested_name


func default_by_motion(motion) -> String:
	return _motion_type_to_default_action[motion]


func _to_string() -> String:
	return "supported action_names: " + pp._array(action_names) + "\n_motion_type_to_action:\n" + pp._dict(_motion_type_to_default_action)


func __validation():
	for type_ in MotionType.get_all_types():
		assert(_motion_type_to_default_action.has(type_),
			pp.s("SupportedActions must contain all motion types:", type_, "is missing"))
		var value = _motion_type_to_default_action[type_]
		assert(value is String and value != "")
	assert(len(action_names) > 0, "action_names len empty")