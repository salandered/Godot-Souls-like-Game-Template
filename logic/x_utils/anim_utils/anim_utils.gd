class_name AnimUtils
extends RefCountedStaticLogger


const MAX_SPEED_SCALE := 2.0
const MIN_SPEED_SCALE := 0.2


class AnimSetPlayingData:
	var blend_for: float
	var start_time_offset: float
	var anim: AnimationData

	func _init(blend_for_: float, start_time_offset_: float, anim_: AnimationData) -> void:
		blend_for = blend_for_
		start_time_offset = start_time_offset_
		anim = anim_


static func safe_has_animation(animator: AnimationPlayer, anim_id: StringName, wl: StringName = WL.PUSH_WARN) -> bool:
	if error_.null_object(animator):
		return false
	var exists: bool = animator.has_animation(anim_id)
	if not exists:
		error_.warn(_msg_key_problem(animator, anim_id), "", "", wl)
	return exists


## fast fail
static func safe_has_animations(animator: AnimationPlayer, anim_ids: Array[StringName], wl: StringName = WL.PUSH_WARN) -> bool:
	if error_.null_object(animator):
		return false
	for item in anim_ids:
		if not safe_has_animation(animator, item, wl):
			return false
	return true


static func set_anim_to_play(
	native_player: AnimationPlayer,
	anim_container: BaseAnimContainer,
	config: AnimatableEntityConfig,
	anim_id: StringName,
	blend_for: float = 0.0,
	start_time_offset: float = 0.0,
) -> AnimSetPlayingData:
	if anim_id == Const.EMPTY_SNAME:
		__log_error("anim_id is empty string", "set_anim_to_play", "will not play anything")
		return null
	if blend_for < 0:
		__log_warn_soft("blend_for < 0 is not supported, 0 will be used:" + str(blend_for), "", "")
		blend_for = 0
	
	if start_time_offset < 0:
		__log_warn_soft("start time shift < 0 is not supported, 0 will be used: " + str(start_time_offset), "", "")
		start_time_offset = 0
	
	var anim: AnimationData = anim_container.get_by_anim_id(anim_id)

	if anim == null:
		__log_error("set_anim_to_play fail: animation not found: " + anim_id, "set_anim_to_play", "")
		return null

	if not native_player.has_animation(anim_id):
		__log_error("set_anim_to_play fail: animation not found: " + anim_id, "set_anim_to_play", "")
		return null
	
	# NOTE: playing anim and setting _curr_anim is atomic
	native_player.play(anim.anim_id, blend_for, anim.speed_scale * config.SPEED_SCALE_COEF)
	if start_time_offset > 0:
		native_player.seek(start_time_offset, true)

	return AnimSetPlayingData.new(
		blend_for,
		start_time_offset,
		anim
	)


## GLOBAL SPEED SCALE
# region

static func set_global_speed_scale(native_player: AnimationPlayer, config: AnimatableEntityConfig, new_scale: float) -> void:
	new_scale = snappedf(new_scale, 0.01)
	
	if new_scale < MIN_SPEED_SCALE or new_scale > MAX_SPEED_SCALE:
		__log_("new_scale will be clamped. min/max/curr scale", new_scale, MIN_SPEED_SCALE, MAX_SPEED_SCALE)
		new_scale = clampf(new_scale, MIN_SPEED_SCALE, MAX_SPEED_SCALE)
	
	if absf(native_player.speed_scale - new_scale) > 0.005:
		# __log_("set_global_speed_scale to", new_scale, "  (from", native_player.speed_scale, ")")
		## TODO: looks like should use anim.speed_scale * new_scale
		native_player.speed_scale = new_scale * config.SPEED_SCALE_COEF


static func reset_global_speed_scale(native_player: AnimationPlayer, config: AnimatableEntityConfig, ) -> void:
	native_player.speed_scale = 1.0 * config.SPEED_SCALE_COEF


## guarantees not 0.0
static func get_global_speed_scale(anim: AnimationData, native_player: AnimationPlayer) -> float:
	## TODO: here should be just native_player.speed_scale 
	return _get_effective_speed(anim, native_player)

# endregion


## TIME SPENT / DURATION
# region

static func get_anim_effective_time_spent(anim: AnimationData, native_player: AnimationPlayer) -> float:
	var raw_time_spent := native_player.current_animation_position
	var effective_speed := _get_effective_speed(anim, native_player)
	return raw_time_spent / absf(effective_speed)


static func get_anim_time_spent(anim: AnimationData, anim_start_offset: float, native_player: AnimationPlayer) -> float:
	var raw_time_spent := native_player.current_animation_position - anim_start_offset
	var effective_speed := _get_effective_speed(anim, native_player)
	return raw_time_spent / absf(effective_speed)


## Returns the raw, unscaled duration. (Animation Time)
static func get_anim_duration_unscaled(anim: AnimationData) -> float:
	if not anim:
		return 0.0
	return anim.duration


## returns 0.0 if no curr anim
static func get_anim_effective_duration(anim: AnimationData, anim_start_offset: float, native_player: AnimationPlayer) -> float:
	if not anim:
		return 0.0

	var _base_duration: float
	if anim.is_looping:
		_base_duration = anim.duration
	else:
		_base_duration = anim.duration - anim_start_offset
	
	var effective_speed := _get_effective_speed(anim, native_player)

	return _base_duration / absf(effective_speed)

# endregion


## Returns the raw, unscaled playhead position. (Animation Time)
static func get_anim_position_unscaled(anim: AnimationData, native_player: AnimationPlayer) -> float:
	return native_player.current_animation_position


## INTERNAL

## guarantees not 0.0
## returns 1.0 if no curr anim
static func _get_effective_speed(anim: AnimationData, native_player: AnimationPlayer) -> float:
	# NOTE: we could use native_player.get_playing_speed(), 
	# 		but then if animation ends playing, it drops to 0.0.
	if not anim:
		return 1.0
	var _r := anim.speed_scale * native_player.speed_scale
	if _r == 0.0:
		__log_warn("effective_speed 0", "_get_effective_speed", "return 1.0")
		return 1.0
	return _r


static func _msg_key_problem(animator: AnimationPlayer, anim_id: StringName, found_is_problem: bool = false) -> String:
	var _found_msg := "found in AnimPlayer" if found_is_problem else "not found in AnimPlayer:"
	var _msg := pp.s("Anim", pp.in_q(anim_id), _found_msg, animator)
	return _msg


# region: __LOGS

static func pp_name() -> String:
	return "AnimUtils"

static func __LOG_B() -> bool:
	return false

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.msg_raw(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion
