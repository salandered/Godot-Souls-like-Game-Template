extends RefCountedSystem
class_name SupportedActions


var _motion_type_to_default_action: Dictionary[StringName, StringName] = {}
var action_names: Array[StringName] = []


func _init(motion_to_action_: Dictionary[StringName, StringName], additional_actions: Array[StringName]):
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
func convert_to_supported(action: BaseAction) -> StringName:
	if is_action_supported(action.action_name):
		return action.action_name
	else:
		# print_.lsm_beh("", pp.in_q(action.action_name) + " is not supported. will return default supported with the same motion type")
		return default_by_motion(action.motion_type)


func is_action_supported(requested_name: StringName) -> bool:
	return requested_name in action_names


func by_name(requested_name: StringName) -> StringName:
	## NOTE: There shouldnt be a problem of using an action in curr behavior SM which it doesnt support.
	## (because of convert_to_supported mechanic) 
	## But we may prevent this in the future: we ll return default action by the same type. 
	if not is_action_supported(requested_name):
		__log_warn(requested_name + " cant be find in supported actions: " + str(action_names))
	return requested_name


func default_by_motion(motion: StringName) -> StringName:
	var _r: StringName = DictUtils.safe_get_dict_key(_motion_type_to_default_action, motion, "")
	return _r


func _to_string() -> String:
	return "supported action_names: " + pp.array_(action_names) + "\n_motion_type_to_action:\n" + pp.dict_(_motion_type_to_default_action)


func __validation():
	for type_ in MotionType.get_all_types():
		if not DictUtils.safe_has_key(_motion_type_to_default_action, type_):
			__log_error(pp.s("must contain all motion types:", type_, "is missing"))
		else:
			var value: Variant = _motion_type_to_default_action[type_]
			error_.empty_string(value)
	error_.empty_list(action_names, "action_names len empty")


## __LOGS
# region


func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion
