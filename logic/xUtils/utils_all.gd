extends RefCounted
# here are all utils which dont have their separate more focused module
class_name u

static var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


static func fr(to_str_: bool = true, str_prefix: bool = false) -> Variant:
	if to_str_:
		if not str_prefix:
			return str(Engine.get_process_frames())
		return "fr_n-" + str(Engine.get_process_frames())
	else:
		return Engine.get_process_frames()


# ease-in-out S-curve
# takes a linear progress value (0 to 1) and returns a smoothed value (0 to 1)
static func ease_in_out(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return 0.5 * (1.0 - cos(x * PI))


## returns null if key does not exist
static func safe_get_dict_key(dict: Dictionary, key: String, context: String = "", fallback: String = Fallback.WARN_CRUCIAL) -> Variant:
	if safe_has_key(dict, key, fallback):
		return dict[key]
	else:
		return null


static func safe_has_key(dict: Dictionary, key: String, fallback: String = Fallback.WARN_CRUCIAL) -> bool:
	var exists := key in dict
	if not exists:
		match fallback:
			Fallback.FAIL:
				assert(false, "Key '" + str(key) + "' not found in dictionary")
			Fallback.WARN, Fallback.WARN_CRUCIAL:
				print_.warn_raw(fallback == Fallback.WARN_CRUCIAL, "Key '" + str(key) + "' not found in dictionary")
			Fallback.SOFT:
				pass
			_:
				print_.warn_raw(false, "Key '" + str(key) + "' not found in dictionary")
	return exists

static func safe_look_at(
		from_who: Node3D,
		target: Vector3,
		up: Vector3 = Vector3.UP,
		# by default -Z is pointed to target. built in use_model_front solves that
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
	return _dev_change_param(event, param, param_name, step, "t1", "t2")

static func _dev_change_t34_param(event, param, param_name: String = "some param", step: float = 0.1) -> Variant:
	return _dev_change_param(event, param, param_name, step, "t3", "t4")

static func _dev_change_t58_param(event, param, param_name: String = "some param", step: float = 0.1) -> Variant:
	return _dev_change_param(event, param, param_name, step, "t5", "t8")

static func _dev_change_t67_param(event, param, param_name: String = "some param", step: float = 0.1) -> Variant:
	return _dev_change_param(event, param, param_name, step, "t6", "t7")

static func _dev_change_param(
	event, param: Variant, param_name: String = "some param", step: float = 0.1, key_a: String = "t1", key_b: String = "t2") -> Variant:
	var prev_param: Variant = param
	if event.is_action_released(key_a):
		param -= step
	if event.is_action_released(key_b):
		param += step

	if prev_param != param:
		print_.dev("~~ ", pp.s(param_name, prev_param, pp.arr, param), 0, LogL.FORCE_PRINT)
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


static func safe_cast_array_of_strings(array: Array[Variant]) -> Array[String]:
	var list_casted: Array[String] = []
	for item in array:
		if item is not String:
			print_.warn_raw(false,
				"Array contains non-string value: ", item, " | Array:", pp.list_(array), "Fallback: will return empty array.")
			return []
	list_casted.assign(array)
	return list_casted
