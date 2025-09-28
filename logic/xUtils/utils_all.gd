extends RefCounted
# here are all utils which dont have their separate more focused module
class_name u

static var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


static func fr(to_str_: bool = true) -> Variant:
	if to_str_:
		return "fr_n-" + str(Engine.get_process_frames())
	else:
		return Engine.get_process_frames()


# TODO: consider 4.5 update
static func not_implemented(context = ""):
	push_error(str(context), " abstract function is called")


static func safe_get_dict_key(dict: Dictionary, key: String, context: String = "", fatal: bool = false) -> Variant:
	var key_exists: bool = dict.has(key)
	
	if key_exists:
		return dict[key]

	var msg = pp.ts("Dict does not have key", pp.in_q(key), "Context:", context)
	if fatal:
		assert(false, msg)
	print_.warn(msg)
	return null

# ease-in-out S-curve
# takes a linear progress value (0 to 1) and returns a smoothed value (0 to 1)
static func ease_in_out(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return 0.5 * (1.0 - cos(x * PI))


static func safe_look_at(
	from_who: Node3D,
	target: Vector3,
	up: Vector3 = Vector3.UP,
	# by default -Z is pointed to target. built in use_model_front solves that
	use_model_front: bool = false,
	eps: float = 0.001
) -> bool:
	var dir = target - from_who.global_transform.origin
	if dir.length_squared() < eps * eps:
		return false
	if abs(dir.normalized().dot(up)) > 1.0 - eps:
		return false
	from_who.look_at(target, up, use_model_front)
	return true
