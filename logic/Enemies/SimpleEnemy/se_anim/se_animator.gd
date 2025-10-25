@tool
@icon("res://-assets-/x_misc/x_icons/node-colors/purple.png")

extends Node
class_name SEAnimator


# @onready var _animator: AnimationPlayer = $AnimationPlayer
# @export var me: SECharacter


# func _ready():
# 	_configure_blending_times()


# func _configure_blending_times():
# 	pass
# 	# _set_blend_time(A.strafe_R, A.strafe_L, 0.5)
# 	# # _set_blend_time("ss_strafe/strafe_L", "ss_strafe/strafe_R", 0.5)
# 	# _set_blend_time(A.strafe_R, A.strafe_idle, 0.5)
# 	# _set_blend_time(A.strafe_L, A.strafe_idle, 0.5)
# 	# _set_blend_time(A.strafe_R, A.strafe_forward, 0.5)
# 	# _set_blend_time(A.strafe_L, A.strafe_back, 0.5)
# 	# _set_blend_time(A.idle_longsword, A.strafe_idle, 1)
# 	# _set_blend_time(A.strafe_idle, A.idle_longsword, 1)


# func _set_blend_time(from: String, to: String, time: float):
# 	ua.assert_has_animation(_animator, from)
# 	ua.assert_has_animation(_animator, to)
# 	# TODO: both sides?
# 	_animator.set_blend_time(from, to, time)


# func set_speed_scale(speed: float):
# 	# TODO: difference from calling builtin set_speed_scale() ?
# 	_animator.speed_scale = speed


# func reset_animation():
# 	_animator.seek(0)


# func update_animation():
# 	var animation := me.current_state.anim_id
# 	# print_._prefix("Anim", current_animation + " changing to " + animation_name)
# 	ua.assert_has_animation(_animator, animation)
# 	if _animator.current_animation != animation:
# 		_animator.play(animation)
