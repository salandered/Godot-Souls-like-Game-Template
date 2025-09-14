extends RefCounted
# here are all utils which dont have their separate more focused module
class_name u

static func fr() -> String:
	return "fr_n-" + str(Engine.get_process_frames())


static func round_01(f: float) -> String:
	assert(f is float)
	return str(snapped(f, 0.01))


static func assert_has_animation(animator: AnimationPlayer, animation: String, fatal: bool = true) -> bool:
	if fatal:
		assert(animator.has_animation(animation), "Animator " + animator.name + " has no animation '" + animation + "'")
		return true
	if not animator.has_animation(animation):
		push_warning("Animator " + animator.name + " has no animation '" + animation + "'")
		return false
	return true


# ease-in-out S-curve
# takes a linear progress value (0 to 1) and returns a smoothed value (0 to 1)
static func ease_in_out(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return 0.5 * (1.0 - cos(x * PI))


static func safe_look_at(
	node: Node3D,
	target: Vector3,
	up: Vector3 = Vector3.UP,
	use_model_front: bool = false,
	eps: float = 0.001
) -> bool:
	var dir = target - node.global_transform.origin
	if dir.length_squared() < eps * eps:
		return false
	if abs(dir.normalized().dot(up)) > 1.0 - eps:
		return false
	node.look_at(target, up, use_model_front)
	return true
