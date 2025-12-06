@tool
extends BaseAnimatorManager

## NOTE: CLIENT CODE COMMUNICATES WITH ANIMATORS ONLY VIA THIS FACADE
class_name PlAnimatorManager

@onready var root_animator: PlayerRootAnimator = %RootAnimator
@onready var full_body: PlayerModifierAnimator = %FullBody
@onready var overlay_modifer: OverlayModifier = %OverlayModifer

@onready var _begin: BeginModifier = %_Begin
@onready var _end: EndModifier = %_End

@onready var anim_container: AnimationContainer = %AnimContainer
@onready var native_animator: AnimationPlayer = %NativeAnimator


## SET ANIMATIONS TO PLAY AND CONFIGURE ▶️
# region 

func set_overlay_anim(anim_id: String, overlay_config: OverlayConfig, start_time_offset: float = 0.0) -> void:
	var anim: AnimationData = anim_container.get_by_anim_id(anim_id)
	if anim == null:
		__log_warn(true, "Overlay anim not found: " + anim_id, "set_overlay_anim", "")
		return
	overlay_modifer.set_overlay_anim(anim, overlay_config, start_time_offset)


func set_anim_to_play(anim_id: String, blend_for: float = 0.0, start_time_offset: float = 0.0) -> void:
	if blend_for < 0:
		__log_warn(false, "blend_for < 0 is not supported", "set_anim_to_play", "0 will be used", blend_for)
		blend_for = 0

	if start_time_offset < 0:
		__log_warn(false, "start time shift < 0 is not supported", "set_anim_to_play", "0 will be used", start_time_offset)
		start_time_offset = 0

	var anim: AnimationData = anim_container.get_by_anim_id(anim_id)
	if anim == null:
		__log_warn(true, "set_anim_to_play fail: animation not found: " + anim_id, "set_anim_to_play", "")
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

# endregion


## READ INFO ABOUT WHAT'S PLAYING
# region 

func get_curr_anim_effective_time_spent() -> float:
	return full_body.curr_playback.get_effective_time_spent()

func get_prev_anim_time_spent() -> float:
	return full_body.prev_playback.time_spent

func get_curr_anim_time_spent() -> float:
	return full_body.curr_playback.time_spent

func get_curr_anim_effective_duration() -> float:
	return full_body.curr_playback.get_effective_duration()

func get_curr_blend_duration() -> float:
	return full_body.curr_blend_playback.duration

# func get_curr_blend_time_spent() -> float:
# 	return full_body.curr_blend_playback.

func is_blending() -> bool:
	return full_body.curr_blend_playback.is_blending

func get_curr_blend_percentage() -> float:
	return full_body.curr_blend_playback.percentage

func get_curr_anim() -> AnimationData:
	return full_body.curr_playback.anim


# TODO WARNING: validate this and get_curr_anim_effective_time_spent. 
# 				One of them violates the interface doc!
func get_curr_anim_position_unscaled() -> float:
	return full_body.curr_playback.get_effective_time_spent()

func get_curr_anim_duration_unscaled() -> float:
	return full_body.curr_playback.anim.duration

## ROOT

func get_root_velocity(y_zeroed: bool = true, use_blending: bool = false, backwards: bool = false) -> Vector3:
	return root_animator.get_root_velocity(y_zeroed, use_blending, backwards)

func get_root_rotation(y_only: bool = true) -> float:
	return root_animator.get_root_rotation(y_only)

func get_prev_root_rotation() -> float:
	return root_animator.get_prev_root_rotation()

func calculate_animation_start_root_velocity(anim: AnimationData, start_time_offset: float = 0.0, backwards: bool = false) -> float:
	return root_animator.calculate_animation_start_root_velocity(anim, start_time_offset, backwards)

# endregion


## INTERNAL

func initialise():
	var initial_anim := anim_container.get_by_anim_id(A.loco.idle)

	native_animator.play(A.loco.idle)

	full_body.curr_playback = AnimPlayback.new(initial_anim, 0.0, 0.0)
	full_body.prev_playback = AnimPlayback.new(initial_anim, 0.0, 0.0)
	full_body.initialise()
	overlay_modifer.initialise()
	
	_begin.initialise()
	_end.initialise()


func is_player() -> bool:
	return true

func pp_name() -> String:
	return "player animator"

func __LOG_INDENT() -> int:
	return 0

func __LOG_B() -> bool:
	return true
