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


static func is_nth_frame(interval: int) -> bool:
	if interval <= 0: return true
	return ifr() % interval == 0


static func is_nth_physics_frame(interval: int) -> bool:
	if interval <= 0: return true
	return Engine.get_physics_frames() % interval == 0


# ease-in-out S-curve
# takes a linear progress value (0 to 1) and returns a smoothed value (0 to 1)
static func ease_in_out(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return 0.5 * (1.0 - cos(x * PI))


## returns null if key does not exist
static func safe_get_dict_key(dict: Dictionary, key: Variant, default: Variant = null, warn_level: String = WL.WARN_CRUCIAL) -> Variant:
	if safe_has_key(dict, key, warn_level):
		return dict[key]
	else:
		return default


static func _msg_key_problem(key: Variant, dict: Dictionary, found_is_problem: bool = false) -> String:
	var _found_msg := "found in dictionary" if found_is_problem else "not found in dictionary:"
	var _msg := pp.s("Key", pp.in_q(key), _found_msg, pp.dict_(dict, false, false, true))
	return _msg


static func safe_has_key(dict: Dictionary, key: Variant, warn_level: String = WL.PUSH_WARN) -> bool:
	var exists: bool = key in dict
	if not exists:
		error_.warn(_msg_key_problem(key, dict), "", "", warn_level)
	return exists


static func safe_has_no_key(dict: Dictionary, key: Variant, warn_level: String = WL.PUSH_WARN) -> bool:
	var exists: bool = key in dict
	if exists:
		error_.warn(_msg_key_problem(key, dict, true), "", "", warn_level)
	return not exists


static func safe_has_method(
		object_: Object,
		method_: String,
		warn_level: String = WL.PUSH_ERROR,
) -> bool:
	if not object_ or not is_instance_valid(object_):
		error_.warn("no object_ at all or it is invalid", "", "", warn_level)
		return false

	var exists: bool = object_.has_method(method_)
	if not exists:
		var _msg := pp.s("method_", pp.in_q(method_), "not found in object_", safe_object_pp_name(object_))
		error_.warn(_msg, "", "", warn_level)
		
	return exists


static func safe_has_property(
		object_: Object,
		property_name: String,
		warn_level: String = WL.PUSH_ERROR,
) -> bool:
	if not object_ or not is_instance_valid(object_):
		error_.warn("no object_ at all or it is invalid", "", "", warn_level)
		return false
	
	var exists: bool = property_name in object_
	if not exists:
		var _msg := pp.s("property", pp.in_q(property_name), "not found in object_", safe_object_pp_name(object_))
		error_.warn(_msg, "", "", warn_level)
		
	return exists


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


static func is_object_ok(object_: Object, description: String = "", warn_level: String = WL.PUSH_WARN) -> bool:
	if not object_ or not is_instance_valid(object_):
		error_.warn("object is null or not valid", description, "", warn_level)
		return false
	else:
		return true

## return true if emitted
static func safe_emit(
	signal_data: SignalData,
	signal_payload: Dictionary[String, Variant],
	__log: bool = false,
	warn_level: String = WL.WARN) -> bool:
	if error_.null_object(signal_data, "no signal data", warn_level):
		return false
	if error_.null_signal(signal_data, "", warn_level):
		return false
	signal_data.signal_obj.emit(signal_payload)
	if __log:
		print_.prefix("<emit>", pp.sig(signal_data, signal_payload))
	return true

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


static func construct_obj_pp_name(object_: Object) -> String:
	if not error_.null_variant(object_.get_script(), "construct_obj_pp_name", WL.SILENT):
		var _r = object_.get_script().get_global_name()
		_r = pp_name_replacers(_r)
		return _r
	return "undefined"

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


static func pp_name_replacers(_r: String) -> String:
	for key_word: String in _pp_replacers:
		_r = _r.replace(key_word, _pp_replacers[key_word])
	return _r


static var _pp_replacers: Dictionary[String, String] = {
		"Container": em.box,
		"Player": "Pl",
		"Character": "Char",
		"Enemy": "🗿",
		"Feelings": em.h_white,
		"Weapon": em.dagger,
		"Awareness": "👀",
		"ModifierAnimator": "💀Animator"
	}

##

static func set_all_descendant_asp_3d_default_bus(for_whom: Node3D):
	var asps := get_descendants.audio_stream_players_3D(for_whom)
	for asp: AudioStreamPlayer3D in asps:
		asp.bus = Constants.SFX_ASP_BASE_BUS_ID
