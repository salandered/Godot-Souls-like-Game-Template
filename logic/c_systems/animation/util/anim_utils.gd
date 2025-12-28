extends RefCountedStaticLogger
class_name AnimUtils


static func is_track_exists(native_anim: Animation, track_prefix: String, param_name: String) -> bool:
	var _track_name := track_prefix + param_name
	if not native_anim:
		__log_warn("")
		return false
	var _track := native_anim.find_track(_track_name, Animation.TYPE_VALUE)
	
	if _track == -1:
		# error_.warn("Track not found: " + _track_name + " in animation " + anim_name)
		return false
	return true


## returns 'false' or 'default_value' in case of any problems
static func get_bool_value_from_track(native_anim: Animation, track_prefix: String, param_name: String, timestamp: float, default_value: bool = false) -> bool:
	var _track_name := track_prefix + param_name
	if not native_anim:
		__log_warn("")
		return default_value
	var _track := native_anim.find_track(_track_name, Animation.TYPE_VALUE)
	
	if _track == -1:
		# error_.warn("Track not found: " + _track_name + " in animation " + anim_name)
		return default_value

	var value: Variant = native_anim.value_track_interpolate(_track, timestamp)
	if value is bool:
		# if param_name == WEAPON_HURTS:
			# print_.prefix("_get_value_from_track return ", str(value))
		return value

	# WARNING: Normally return value should be bool already. But there was a bug when it was not
	if native_anim.track_get_key_count(_track) == 0: # no keys
		__log_warn("Track '%s' has no keys, using default" % _track_name)
		return default_value

	# try nearest key
	__log_warn("Interpolation failed for '%s' at %.3f, trying nearest key lookup" % [_track_name, timestamp])
	var key_index := native_anim.track_find_key(_track, timestamp, Animation.FIND_MODE_NEAREST)
	if key_index != -1:
		var key_value: Variant = native_anim.track_get_key_value(_track, key_index)
		var key_time: Variant = native_anim.track_get_key_time(_track, key_index)
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


static func duplicate_native_player_mute_audio(source_player: AnimationPlayer) -> AnimationPlayer:
	var new_player := AnimationPlayer.new()
	
	# copy all libs
	var lib_names = source_player.get_animation_library_list()
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


# region: __LOGS


static func pp_name() -> String:
	return "AnimUtils"

static func __LOG_B() -> bool:
	return false

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())


# endregion