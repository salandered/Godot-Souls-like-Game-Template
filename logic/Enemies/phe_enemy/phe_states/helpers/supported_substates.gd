extends RefCounted
class_name SupportedSubstates


var state_names: Array[String]
var parent_state: String

func _init(states_: Array[String], parent_state_: String):
	self.state_names = states_
	self.parent_state = parent_state_

	__validation()
	__log_("_init()", _to_string())


func is_state_supported(requested_name: String) -> bool:
	var _r := requested_name in state_names

	return _r


func get_first_one() -> String:
	return state_names[0]


func _to_string() -> String:
	return "SupportedSbs: " + pp.array_(state_names)


func __validation():
	assert(state_names and len(state_names) > 0, pp.s("For parent_state", parent_state, "state_names is null or empty"))


# region __LOGS

func __pp_state_supported(requested_name: String) -> String:
	var _msg := pp.s(requested_name, "is supported.", _to_string())
	return _msg

func __pp_state_not_supported(requested_name: String) -> String:
	var _msg := pp.s(requested_name, "is not supported" + em.warn, _to_string())
	return _msg

func __log_(...parts: Array):
	print_.phe_sm("SupportedSbs", pp.list_(parts))

# endregion