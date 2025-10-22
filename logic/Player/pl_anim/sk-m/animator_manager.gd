@tool
@icon("res://-assets-/x_misc/x_icons/node-colors/purple.png")
extends Node

## NOTE: CLIENT CODE COMMUNICATES WITH ANIMATORS ONLY VIA THIS FACADE
class_name AnimatorManager

@onready var root_animator: RootAnimator = %RootAnimator
@onready var full_body: ModifierAnimator = %FullBody
@onready var legs: ModifierAnimator = %Legs

@onready var _begin: BeginModifier = %_Begin
@onready var _end: EndModifier = %_End

@onready var anim_container: AnimationContainer = %AnimContainer
@onready var native_animator: AnimationPlayer = %NativeAnimator


## SET ANIMATIONS TO PLAY AND CONFIGURE ▶️

func set_overlay_anim(anim_name: String, fade_in: float = 0.1, hold: float = -1.0, fade_out: float = 0.15, local_speed: float = 1.0) -> void:
	var anim: AnimationData = anim_container.get_by_name(anim_name)
	if anim == null:
		push_error("Overlay anim not found: " + anim_name)
		return
	full_body.set_overlay_anim(anim, fade_in, hold, fade_out, local_speed)


func set_anim_to_play(anim_name: String, blend_for: float = 0.0, start_time_offset: float = 0.0) -> void:
	if blend_for < 0:
		print_.warn("blend_for < 0 is not supported, 0 will be used:" + str(blend_for))
		blend_for = 0

	if start_time_offset < 0:
		print_.warn("start time shift < 0 is not supported, 0 will be used: " + str(start_time_offset))
		start_time_offset = 0

	var anim: AnimationData = anim_container.get_by_name(anim_name)
	if anim == null:
		push_error("set_anim_to_play fail: animation not found: " + anim_name)
		return

	full_body.set_anim_to_play(anim, blend_for, start_time_offset)


func set_global_speed_scale(new_scale: float):
	var max_speed_scale := 2
	var min_speed_scale := 0.1
	new_scale = snappedf(new_scale, 0.01)
	if new_scale < min_speed_scale or new_scale > max_speed_scale:
		# u.print_warn(pp.s("extreme speed scale:", new_scale, "Was:", global_speed_scale, "Will be clamped between", max_speed_scale))
		new_scale = clamp(new_scale, min_speed_scale, max_speed_scale)
	
	if absf(full_body.global_speed_scale - new_scale) > 0.001:
		full_body.set_global_speed_scale(new_scale)


func reset_global_speed_scale():
	full_body.reset_global_speed_scale()


## READ INFO ABOUT WHAT'S PLAYING


func get_current_anim_effective_progress() -> float:
	return full_body.curr_playback.get_effective_progress()

func get_prev_anim_time_spent() -> float:
	return full_body.prev_playback.time_spent

func get_curr_anim_time_spent() -> float:
	return full_body.curr_playback.time_spent

func get_curr_anim_effective_duration() -> float:
	return full_body.curr_playback.get_effective_duration()

func get_curr_blend_duration() -> float:
	return full_body.curr_blend_playback.duration

func is_blending() -> bool:
	return full_body.curr_blend_playback.is_blending

func get_prev_blend_percentage() -> float:
	return full_body.curr_blend_playback.prev_percentage


func get_root_velocity(y_zeroed: bool = true, use_blending: bool = true, backwards: bool = false) -> Vector3:
	return root_animator.get_root_velocity(y_zeroed, use_blending, backwards)

func get_root_rotation(y_only: bool = true) -> float:
	return root_animator.get_root_rotation(y_only)

func get_prev_root_rotation() -> float:
	return root_animator.get_prev_root_rotation()

func calculate_animation_start_root_velocity(anim: AnimationData, start_time_offset: float = 0.0, backwards: bool = false) -> float:
	return root_animator.calculate_animation_start_root_velocity(anim, start_time_offset, backwards)


## INTERNAL

func _accept_modifiers():
	var initial_anim := anim_container.get_by_name(A.move.idle)


	native_animator.play(A.move.idle)
	full_body.curr_playback = AnimPlayback.new(initial_anim, 0.0, 0.0)
	full_body.prev_playback = AnimPlayback.new(initial_anim, 0.0, 0.0)
	full_body.initialise()
	
	_begin.initialise()
	_end.initialise()
