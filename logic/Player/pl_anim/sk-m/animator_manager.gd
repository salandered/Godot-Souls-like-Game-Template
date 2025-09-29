@tool
@icon("res://-assets-/x_misc/x_icons/node-colors/purple.png")
extends Node
class_name AnimatorManager

@onready var full_body: ModifierAnimator = %FullBody
@onready var legs: ModifierAnimator = %Legs

@onready var _begin: BeginModifier = %_Begin
@onready var _end: EndModifier = %_End

func set_overlay_anim(anim_name: String, fade_in: float = 0.1, hold: float = -1.0, fade_out: float = 0.15, local_speed: float = 1.0) -> void:
	full_body.set_overlay_anim(anim_name, fade_in, hold, fade_out, local_speed)


func set_anim_to_play(anim_name: String, blend_for: float = 0) -> void:
	full_body.set_anim_to_play(anim_name, blend_for)


func get_root_velocity(y_zeroed: bool = true) -> Vector3:
	return full_body.get_root_velocity(y_zeroed)


func get_current_anim_progress() -> float:
	return full_body.get_current_anim_progress()


func set_global_speed_scale(new_scale: float):
	full_body.set_global_speed_scale(new_scale)


func reset_global_speed_scale():
	full_body.reset_global_speed_scale()


func accept_modifiers(anim_container):
	var animators := [full_body, legs]
	for animator: ModifierAnimator in animators:
		animator.curr_anim = anim_container.get_by_name(A.combat_idle)
		animator.curr_anim_looping = animator.curr_anim.is_looping
		animator.curr_anim_progress = 0
		animator.prev_anim = anim_container.get_by_name(A.combat_idle)
		animator.prev_anim_looping = animator.prev_anim.is_looping
		animator.prev_anim_progress = 0
		animator.initialise()
	_begin.initialise()
	_end.initialise()
	# limp.initialise()
