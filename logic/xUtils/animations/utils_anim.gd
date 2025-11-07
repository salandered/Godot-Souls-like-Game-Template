extends RefCounted
class_name ua


static func assert_has_animation(animator: AnimationPlayer, anim_id: String, fatal: bool = true) -> bool:
	if fatal:
		assert(animator.has_animation(anim_id), pp.s("Animator", animator.name, "has no anim_id", pp.in_q(anim_id)))
		return true
	if not animator.has_animation(anim_id):
		print_.warn(true, pp.s("Animator" + animator.name + "has no animation" + pp.in_q(anim_id)), "assert_has_animation", "skip")
		return false
	return true
