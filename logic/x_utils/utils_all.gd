extends RefCounted
# here are all utils which dont have their separate more focused module
class_name u

static var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


## small division error, we dont care
static func get_curr_time_ticks_sec() -> float:
	return Time.get_ticks_msec() / 1000.0


static func sfr(str_prefix: bool = false) -> Variant:
	if not str_prefix:
		return str(Engine.get_process_frames())
	return pp.s("fr_n-", Engine.get_process_frames())

static func ifr() -> int:
	return Engine.get_process_frames()


# ease-in-out S-curve
# takes a linear progress value (0 to 1) and returns a smoothed value (0 to 1)
static func ease_in_out(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return 0.5 * (1.0 - cos(x * PI))


## returns null if key does not exist
static func safe_get_dict_key(dict: Dictionary, key: Variant, default: Variant = null, warn_level: String = WarnLevel.WARN_CRUCIAL) -> Variant:
	if safe_has_key(dict, key, warn_level):
		return dict[key]
	else:
		return default


static func _msg_key_problem(key: Variant, dict: Dictionary, found_is_problem: bool = false) -> String:
	var _found_msg := "found in dictionary" if found_is_problem else "not found in dictionary:"
	var _msg := pp.s("Key", pp.in_q(key), _found_msg, pp.dict_(dict, false, false, true))
	return _msg


static func safe_has_key(dict: Dictionary, key: Variant, warn_level: String = WarnLevel.PUSH_WARNING) -> bool:
	var exists: bool = key in dict
	if not exists:
		error_.warn(_msg_key_problem(key, dict), "", "", warn_level)
	return exists


static func safe_has_no_key(dict: Dictionary, key: Variant, warn_level: String = WarnLevel.PUSH_WARNING) -> bool:
	var exists: bool = key in dict
	if exists:
		error_.warn(_msg_key_problem(key, dict, true), "", "", warn_level)
	return not exists


static func safe_has_method(
		object: Object,
		method_: String,
		warn_level: String = WarnLevel.PUSH_ERROR,
) -> bool:
	if not object or not is_instance_valid(object):
		error_.warn("no object at all or it is invalid", "", "", warn_level)
		return false

	var exists: bool = object.has_method(method_)
	if not exists:
		var _msg := pp.s("method_", pp.in_q(method_), "not found in object", safe_object_pp_name(object))
		error_.warn(_msg, "", "", warn_level)
		
	return exists


static func safe_has_property(
		object: Object,
		property_name: String,
		warn_level: String = WarnLevel.PUSH_ERROR,
) -> bool:
	if not object or not is_instance_valid(object):
		error_.warn("no object at all or it is invalid", "", "", warn_level)
		return false
	
	var exists: bool = property_name in object
	if not exists:
		var _msg := pp.s("property", pp.in_q(property_name), "not found in object", safe_object_pp_name(object))
		error_.warn(_msg, "", "", warn_level)
		
	return exists


static func safe_has_pp_name(object: Object) -> bool:
	if not object or not is_instance_valid(object):
		error_.warn("no object at all or it is invalid", "", "return false", WarnLevel.WARN)
		return false
	var exists: bool = object.has_method("pp_name")
	return exists


static func safe_object_pp_name(object: Object) -> String:
	if not object or not is_instance_valid(object):
		error_.warn("no object at all or it is invalid", "", "return empty string", WarnLevel.WARN)
		return ""
	return str(object.pp_name()) if safe_has_pp_name(object) else str(object)


static func is_object_ok(object_: Object, description: String = "", warn_level: String = WarnLevel.PUSH_WARNING) -> bool:
	if not object_ or not is_instance_valid(object_):
		error_.warn("object is null or not valid", description, "", warn_level)
		return false
	else:
		return true

static func safe_emit(
	signal_data: SignalData,
	signal_payload: Dictionary[String, Variant],
	warn_level: String = WarnLevel.WARN):
	if not signal_data:
		error_.warn("no signal data", "", "", warn_level)
		return
	if not error_.null_signal(signal_data):
		signal_data.signal_obj.emit(signal_payload)


static func safe_look_at(
		from_who: Node3D,
		target: Vector3,
		up: Vector3 = Vector3.UP,
		# by default -Z is pointed to target. built-in use_model_front solves that
		use_model_front: bool = false,
		eps: float = 0.001
) -> bool:
	var dir := target - from_who.global_transform.origin
	if dir.length_squared() < eps * eps:
		return false
	if abs(dir.normalized().dot(up)) > 1.0 - eps:
		return false
	from_who.look_at(target, up, use_model_front)
	return true


static func _dev_change_t12_param(event, param, param_name: String = "some param", step: float = 0.1) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t1, RawAction.t2)

static func _dev_change_t34_param(event, param, param_name: String = "some param", step: float = 0.1) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t3, RawAction.t4)

static func _dev_change_t58_param(event, param, param_name: String = "some param", step: float = 0.1) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t5, RawAction.t8)

static func _dev_change_t67_param(event, param, param_name: String = "some param", step: float = 0.1) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t6, RawAction.t7)

static func _dev_change_param(
	event, param: Variant, param_name: String = "some param", step: float = 0.1, key_a: String = RawAction.t1, key_b: String = RawAction.t2) -> Variant:
	var prev_param: Variant = param
	if event.is_action_released(key_a):
		param -= step
	if event.is_action_released(key_b):
		param += step

	if prev_param != param:
		print_.dev("~~ ", pp.s(param_name, prev_param, pp.arr, param), 0)
	return param


static func to_pascal_case(snake_case: String) -> String:
	var words := snake_case.split("_")
	var result := ""
	for word in words:
		if word.length() > 0:
			result += word.capitalize()
	return result


## point_index starts with zero!
static func get_curve_point_x(curve: Curve, point_index: int) -> float:
	return curve.get_point_position(point_index).x


static func reset_all(resettable: Array):
	for item in resettable:
		if item.has_method("reset"):
			item.reset()

static func fpow2(number: float) -> float:
	return number * number

static func ipow2(number: int) -> int:
	return number * number


static func cut_string(text: String, limit: int = 600) -> String:
	if text.length() <= limit:
		return text
	return text.left(limit) + " ... <too long to print>"


## awed/name -> name; 
## awd/awdaw/name -> name; 
## ../awd/name -> name; 
## name -> name; 
## /name -> name; 
## name/ -> ''; 
static func get_last_slash_part(raw_string: String) -> String:
	# NOTE: looks like built in get_file will do. But this is custom approach.
	## var pos = raw_string.rfind("/")
	## var _r = raw_string.substr(pos + 1) if pos != -1 else raw_string
	var _r = raw_string.get_file()
	return _r