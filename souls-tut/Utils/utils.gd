extends RefCounted
class_name u


static func assert_has_animation(animator: AnimationPlayer, animation: String):
	assert(animator.has_animation(animation), "Animator " + animator.name + " has no animation '" + animation + "'")