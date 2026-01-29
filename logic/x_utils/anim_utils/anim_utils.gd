extends RefCountedStaticLogger
class_name AnimUtils


static func is_track_exists(native_anim: Animation, track_prefix: String, param_name: String) -> bool:
	var _track_name := track_prefix + param_name
	if not native_anim:
		__log_warn("")
		return false
	var _track_idx := native_anim.find_track(_track_name, Animation.TYPE_VALUE)
	
	if _track_idx == -1:
		# error_.warn("Track not found: " + _track_name + " in animation " + anim_name)
		return false
	return true


## returns 'false' or 'default_value' in case of any problems
static func get_bool_value_from_track(native_anim: Animation, track_prefix: String, param_name: String, timestamp: float, default_value: bool = false) -> bool:
	var _track_name := track_prefix + param_name
	if not native_anim:
		__log_warn("")
		return default_value
	var _track_idx := native_anim.find_track(_track_name, Animation.TYPE_VALUE)
	# native_anim.track_get_path(
	if _track_idx == -1:
		# error_.warn("Track not found: " + _track_name + " in animation " + anim_name)
		return default_value

	var value: Variant = native_anim.value_track_interpolate(_track_idx, timestamp)
	if value is bool:
		# if param_name == WEAPON_HURTS:
			# print_.prefix("_get_value_from_track return ", str(value))
		return value

	# WARNING: Normally return value should be bool already. But there was a bug when it was not
	if native_anim.track_get_key_count(_track_idx) == 0: # no keys
		__log_warn_soft("Track '%s' has no keys, using default" % _track_name)
		return default_value

	# try nearest key. TODO: probably delete. was a temporary measure and problem has not reoccured ever since
	__log_warn_soft("Interpolation failed for '%s' at %.3f, trying nearest key lookup" % [_track_name, timestamp])
	var key_index := native_anim.track_find_key(_track_idx, timestamp, Animation.FIND_MODE_NEAREST)
	if key_index != -1:
		var key_value: Variant = native_anim.track_get_key_value(_track_idx, key_index)
		var key_time: Variant = native_anim.track_get_key_time(_track_idx, key_index)
		print_.note(false, "Found nearest key at index %d, time %.3f, value: %s" % [key_index, key_time, str(key_value)])
		if key_value != null and key_value is bool:
			return key_value
		elif key_value != null:
			return bool(key_value)
			
	return default_value # Last resort


static func _msg_key_problem(animator: AnimationPlayer, anim_id: String, found_is_problem: bool = false) -> String:
	var _found_msg := "found in AnimPlayer" if found_is_problem else "not found in AnimPlayer:"
	var _msg := pp.s("Anim", pp.in_q(anim_id), _found_msg, animator)
	return _msg


static func safe_has_animation(animator: AnimationPlayer, anim_id: String, warn_level: String = WL.PUSH_WARN) -> bool:
	if error_.null_object(animator):
		return false
	var exists: bool = animator.has_animation(anim_id)
	if not exists:
		error_.warn(_msg_key_problem(animator, anim_id), "", "", warn_level)
	return exists


## fast fail
static func safe_has_animations(animator: AnimationPlayer, anim_ids: Array[String], warn_level: String = WL.PUSH_WARN) -> bool:
	if error_.null_object(animator):
		return false
	for item in anim_ids:
		if not safe_has_animation(animator, item, warn_level):
			return false
	return true


static func duplicate_native_player_mute_audio(source_player: AnimationPlayer) -> AnimationPlayer:
	var new_player := AnimationPlayer.new()
	
	# copy all libs
	var lib_names := source_player.get_animation_library_list()
	for lib_name: StringName in lib_names:
		var _source_lib: AnimationLibrary = source_player.get_animation_library(lib_name)

		var new_lib := _source_lib.duplicate(true)
		
		# mute audio tracks
		for anim_name: StringName in new_lib.get_animation_list():
			var native_anim: Animation = new_lib.get_animation(anim_name)
			_disable_audio_tracks(native_anim)
		
		new_player.add_animation_library(lib_name, new_lib)
	
	new_player.root_node = source_player.root_node
	new_player.root_motion_track = source_player.root_motion_track
	new_player.playback_default_blend_time = source_player.playback_default_blend_time
	
	return new_player


static func _disable_audio_tracks(anim: Animation) -> void:
	for track_idx: int in anim.get_track_count():
		if anim.track_get_type(track_idx) == Animation.TYPE_AUDIO:
			anim.track_set_enabled(track_idx, false)


####

class AnimSetPlayingData:
	var blend_for: float
	var start_time_offset: float
	var anim: AnimationData

	func _init(blend_for_: float, start_time_offset_: float, anim_: AnimationData) -> void:
		blend_for = blend_for_
		start_time_offset = start_time_offset_
		anim = anim_

static func set_anim_to_play(
	native_player: AnimationPlayer,
	anim_container: BaseAnimContainer,
	config: AnimatableEntityConfig,
	anim_id: String,
	blend_for: float = 0.0,
	start_time_offset: float = 0.0,
) -> AnimSetPlayingData:
	if anim_id == "":
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

const max_speed_scale := 2.0
const min_speed_scale := 0.2
static func set_global_speed_scale(native_player: AnimationPlayer, config: AnimatableEntityConfig, new_scale: float) -> void:
	new_scale = snappedf(new_scale, 0.01)
	
	if new_scale < min_speed_scale or new_scale > max_speed_scale:
		__log_("new_scale will be clamped. min/max/curr scale", new_scale, min_speed_scale, max_speed_scale)
		new_scale = clampf(new_scale, min_speed_scale, max_speed_scale)
	
	if absf(native_player.speed_scale - new_scale) > 0.005:
		# __log_("set_global_speed_scale to", new_scale, "  (from", native_player.speed_scale, ")")
		## TODO: i think it should use anim.speed_scale * new_scale
		native_player.speed_scale = new_scale * config.SPEED_SCALE_COEF


static func reset_global_speed_scale(native_player: AnimationPlayer, config: AnimatableEntityConfig, ) -> void:
	native_player.speed_scale = 1.0 * config.SPEED_SCALE_COEF


## guarantees not 0.0
static func get_global_speed_scale(anim: AnimationData, native_player: AnimationPlayer) -> float:
	## TODO: here should be just native_player.speed_scale 
	return _get_effective_speed(anim, native_player)


static func get_anim_effective_time_spent(anim: AnimationData, native_player: AnimationPlayer) -> float:
	var raw_time_spent := native_player.current_animation_position
	var effective_speed := _get_effective_speed(anim, native_player)
	return raw_time_spent / absf(effective_speed)


static func get_anim_time_spent(anim: AnimationData, anim_start_offset: float, native_player: AnimationPlayer) -> float:
	var raw_time_spent := native_player.current_animation_position - anim_start_offset
	var effective_speed := _get_effective_speed(anim, native_player)
	return raw_time_spent / absf(effective_speed)


## Returns the raw, unscaled playhead position. (Animation Time)
static func get_anim_position_unscaled(anim: AnimationData, native_player: AnimationPlayer) -> float:
	return native_player.current_animation_position


## Returns the raw, unscaled duration. (Animation Time)
static func get_anim_duration_unscaled(anim: AnimationData, ) -> float:
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


# region: __LOGS


static func pp_name() -> String:
	return "AnimUtils"

static func __LOG_B() -> bool:
	return false

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())


# endregion
