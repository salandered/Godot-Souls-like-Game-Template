extends RefCounted
class_name ua


static func assert_has_animation(animator: AnimationPlayer, animation: String, fatal: bool = true) -> bool:
	if fatal:
		assert(animator.has_animation(animation), pp.ts("Animator", animator.name, "has no animation", pp.in_q(animation)))
		return true
	if not animator.has_animation(animation):
		push_warning("Animator " + animator.name + " has no animation '" + animation + "'")
		return false
	return true
