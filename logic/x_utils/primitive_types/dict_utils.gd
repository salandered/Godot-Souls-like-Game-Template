class_name DictUtils
extends RefCounted


## returns null if key does not exist
static func safe_get_dict_key(dict: Dictionary, key: Variant, default: Variant = null, wl: StringName = WL.INFO) -> Variant:
	if safe_has_key(dict, key, wl):
		return dict[key]
	else:
		return default


static func safe_has_key(dict: Dictionary, key: Variant, wl: StringName = WL.INFO) -> bool:
	var exists: bool = key in dict
	if not exists:
		error_.warn(_msg_key_problem(key, dict), "", "", wl)
	return exists


static func safe_has_no_key(dict: Dictionary, key: Variant, wl: StringName = WL.INFO) -> bool:
	var exists: bool = key in dict
	if exists:
		error_.warn(_msg_key_problem(key, dict, true), "", "", wl)
	return not exists


static func _msg_key_problem(key: Variant, dict: Dictionary, found_is_problem: bool = false) -> String:
	var _found_msg := "found in dictionary" if found_is_problem else "not found in dictionary:"
	var _msg := pp.s("Key", pp.in_q(key), _found_msg, pp.dict_(dict, false, false, true))
	return _msg