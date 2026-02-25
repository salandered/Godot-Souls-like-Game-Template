class_name ObjUtils
extends RefCounted


static func safe_has_method(
		object_: Object,
		method_: String,
		wl: StringName = WL.PUSH_ERROR,
) -> bool:
	if not object_ or not is_instance_valid(object_):
		error_.warn("no object_ at all or it is invalid", "", "", wl)
		return false

	var exists: bool = object_.has_method(method_)
	if not exists:
		var _msg := pp.s("method_", pp.in_q(method_), "not found in object_", safe_object_pp_name(object_))
		error_.warn(_msg, "", "", wl)
		
	return exists


static func safe_has_property(
		object_: Object,
		property_name: String,
		wl: StringName = WL.PUSH_ERROR,
) -> bool:
	if not object_ or not is_instance_valid(object_):
		error_.warn("no object_ at all or it is invalid", "", "", wl)
		return false
	
	var exists: bool = property_name in object_
	if not exists:
		var _msg := pp.s("property", pp.in_q(property_name), "not found in object_", safe_object_pp_name(object_))
		error_.warn(_msg, "", "", wl)
		
	return exists


static func is_object_ok(object_: Object, description: String = "", wl: StringName = WL.PUSH_WARN) -> bool:
	if not object_ or not is_instance_valid(object_):
		error_.warn("object is null or not valid", description, "", wl)
		return false
	else:
		return true


## PP NAME
# region

static func safe_has_pp_name(object_: Object) -> bool:
	if not object_ or not is_instance_valid(object_):
		error_.warn("no object_ at all or it is invalid", "", "return false", WL.WARN)
		return false
	var exists: bool = object_.has_method("pp_name")
	return exists


static func safe_object_pp_name(object_: Object) -> String:
	if not object_ or not is_instance_valid(object_):
		error_.warn("no object_ at all or it is invalid", "", "return empty string", WL.WARN)
		return ""
	return str(object_.pp_name()) if safe_has_pp_name(object_) else str(object_)


static func construct_obj_pp_name(object_: Object) -> String:
	if not error_.null_variant(object_.get_script(), "construct_obj_pp_name", WL.SILENT):
		var _r = object_.get_script().get_global_name()
		_r = StrUtils.pp_name_replacers(_r)
		return _r
	return "undefined"

# endregion