extends RefCounted
class_name u


static func assert_has_animation(animator: AnimationPlayer, animation: String, fatal: bool = true) -> bool:
	if fatal:
		assert(animator.has_animation(animation), "Animator " + animator.name + " has no animation '" + animation + "'")
		return true
	if not animator.has_animation(animation):
		push_warning("Animator " + animator.name + " has no animation '" + animation + "'")
		return false
	return true


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
