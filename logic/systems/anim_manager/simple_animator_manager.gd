extends BaseAnimatorManager

class_name SimpleAnimatorManager


@export var config: AnimatableEntityConfig


# Track the starting position to calculate time_spent
var _curr_anim_start_offset: float = 0.0
var _curr_anim: AnimationData


func initialize_implementation() -> void:
	pass


## SET ANIMATIONS TO PLAY ▶️


func set_anim_to_play(anim_id: StringName, blend_for: float = 0.0, start_time_offset: float = 0.0) -> void:
	var result := AnimUtils.set_anim_to_play(_native_player,
		_anim_container,
		config,
		anim_id,
		blend_for,
		start_time_offset)
	if result:
		__log_new_anim(_curr_anim, result.anim)
		_curr_anim = result.anim
		_curr_anim_start_offset = result.start_time_offset


func set_global_speed_scale(new_scale: float) -> void:
	AnimUtils.set_global_speed_scale(_native_player, config, new_scale)


func reset_global_speed_scale() -> void:
	# __log_("reset_global_speed_scale to 1.0")
	AnimUtils.reset_global_speed_scale(_native_player, config)


## guarantees not 0.0
func get_global_speed_scale() -> float:
	return AnimUtils.get_global_speed_scale(_curr_anim, _native_player)


## READ INFO ABOUT WHAT'S PLAYING

func get_curr_anim_effective_time_spent() -> float:
	return AnimUtils.get_anim_effective_time_spent(_curr_anim, _native_player)


func get_curr_anim_time_spent() -> float:
	return AnimUtils.get_anim_time_spent(_curr_anim, _curr_anim_start_offset, _native_player)


## Returns the raw, unscaled playhead position. (Animation Time)
func get_curr_anim_position_unscaled() -> float:
	return AnimUtils.get_anim_position_unscaled(_curr_anim, _native_player)


## Returns the raw, unscaled duration. (Animation Time)
func get_curr_anim_duration_unscaled() -> float:
	return AnimUtils.get_anim_duration_unscaled(_curr_anim)


## returns 0.0 if no curr anim
func get_curr_anim_effective_duration() -> float:
	return AnimUtils.get_anim_effective_duration(_curr_anim, _curr_anim_start_offset, _native_player)


## returns "" if no curr anim
func get_curr_anim_id() -> StringName:
	if not _curr_anim:
		return Const.EMPTY_SNAME
	return _curr_anim.anim_id


func is_playing() -> bool:
	return get_native_player().is_playing()


## nullable
func get_curr_anim() -> AnimationData:
	return _curr_anim


##

func __LOG_B() -> bool:
	return false