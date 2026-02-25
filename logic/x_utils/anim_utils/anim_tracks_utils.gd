class_name AnimTrackUtils
extends RefCountedStaticLogger


static func is_track_exists(native_anim: Animation, track_prefix: String, param_name: String) -> bool:
	if error_.null_object(native_anim):
		return false
	
	var _track_name := track_prefix + param_name
	var _track_idx := native_anim.find_track(_track_name, Animation.TYPE_VALUE)
	
	if _track_idx == -1:
		# error_.warn("Track not found: " + _track_name + " in animation " + anim_name)
		return false
	return true


## returns 'false' or 'default_value' in case of any problems
static func get_bool_value_from_track(native_anim: Animation, track_prefix: String, param_name: String, timestamp: float, default_value: bool = false) -> bool:
	if error_.null_object(native_anim):
		return default_value

	var _track_name := track_prefix + param_name

	var _track_idx := native_anim.find_track(_track_name, Animation.TYPE_VALUE)

	if _track_idx == -1:
		# error_.warn("Track not found: " + _track_name + " in animation " + anim_name)
		return default_value

	var value: Variant = native_anim.value_track_interpolate(_track_idx, timestamp)
	if value is bool:
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
			
	return default_value # last resort


# region: __LOGS

static func pp_name() -> String:
	return "AnimTrackUtils"

static func __LOG_B() -> bool:
	return false

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.msg_raw(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# end region