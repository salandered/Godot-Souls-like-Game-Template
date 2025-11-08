extends RefCounted
class_name AnimUtils


## returns 'false' or 'default_value' in case of any problems
static func get_bool_value_from_track(native_anim: Animation, track_prefix: String, param_name: String, timestamp: float, default_value: bool = false) -> bool:
	var _track_name := track_prefix + param_name
	if not native_anim:
		print_.warn_raw(false, "")
		return default_value
	var _track := native_anim.find_track(_track_name, Animation.TYPE_VALUE)
	
	if _track == -1:
		# print_.warn("Track not found: " + _track_name + " in animation " + anim_name)
		return default_value

	var value: Variant = native_anim.value_track_interpolate(_track, timestamp)
	if value is bool:
		# if param_name == WEAPON_HURTS:
			# print_.prefix("_get_value_from_track return ", str(value))
		return value

	# WARNING: Normally return value should be bool already. But there was a bug when it was not
	if native_anim.track_get_key_count(_track) == 0: # no keys
		print_.warn_raw(false, "Track '%s' has no keys, using default" % _track_name)
		return default_value

	# try nearest key
	print_.warn_raw(false, "Interpolation failed for '%s' at %.3f, trying nearest key lookup" % [_track_name, timestamp])
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
