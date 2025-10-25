extends Resource
class_name AnimationData

var anim_id: String ## lib + resource_name
var anim_name: String ## resource_name
## DANGER: should not be used. 
##         needs more time for accurate implementation inside the animator.
##         use Animator's 'start_time_offset' to achieve the similar effect
var _start_time: float
var _end_time: float ## end_time should be working fine but needs testing
var duration: float
var speed_scale: float
var is_looping: bool
var native_anim: Animation
var _markers: Dictionary # {str: Marker}
var uses_root_rotation: bool
# { "pos": {track_path: track_idx, ...}, "rot": {track_path: track_idx, ...} }
var _track_path_to_idx := {"pos": {}, "rot": {}}

func _init(
		_anim_id,
		_speed_scale: float = 1.0,
		_uses_root_rotation: bool = false
		):
	anim_id = _anim_id
	speed_scale = _speed_scale
	uses_root_rotation = _uses_root_rotation


func get_pos_track_idx(track_path: String) -> int:
	if track_path in _track_path_to_idx["pos"]:
		return _track_path_to_idx["pos"][track_path]
	return -1

func get_rot_track_idx(track_path: String) -> int:
	if track_path in _track_path_to_idx["rot"]:
		return _track_path_to_idx["rot"][track_path]
	return -1


## Client code may get some specific marker directly.
func get_marker_by_name(marker_name: String) -> Marker:
	return u.safe_get_dict_key(_markers, marker_name, "get marker from anim data")


## returns time withing anim.duration
## returns -1 or default_value (if set) in case of problems
func get_marker_time_by_name(marker_name: String, default_value: float = -1) -> float:
	var marker := get_marker_by_name(marker_name)
	if not marker:
		print_.warn("marker not found " + pp.in_q(marker_name))
		return default_value
	if duration - marker.time < 0.0:
		print_.warn("marker time outside the duration")
		return default_value
	return marker.time


# PARAMETERS
func switches_to_queue(timestamp) -> bool:
	return _get_value_from_track(SWITCHES_TO_QUEUE, timestamp)

	
func allows_queue(timestamp) -> bool:
	return _get_value_from_track(ALLOWS_QUEUE, timestamp)

	
func vulnerable(timestamp) -> bool:
	# return _get_value_from_track(VULNERABLE, timestamp)
	return true
	
func interruptable(timestamp) -> bool:
	# return _get_value_from_track(INTERRUPTABLE, timestamp)
	return true
	
func weapon_hurts(timestamp) -> bool:
	return _get_value_from_track(WEAPON_HURTS, timestamp)

func tracks_input_vector(timestamp) -> bool:
	return _get_value_from_track(TRACKS_INPUT_VECTOR, timestamp)

# PARAMETERS END


func _get_value_from_track(param_name: String, timestamp: float) -> bool:
	var _track_name := _anim_param_track_prefix + param_name
	if not native_anim:
		print_.warn("")
	var _track := native_anim.find_track(_track_name, Animation.TYPE_VALUE)
	
	if _track == -1:
		# print_.warn("Track not found: " + _track_name + " in animation " + anim_name)
		return DEFAULT_PARAMS[param_name]

	# NOTE the '+ _start_time' shift. It's important
	var value: Variant = native_anim.value_track_interpolate(_track, timestamp + _start_time)
	if value is bool:
		return value

	# WARNING: Normally return value should be bool already. But there was a bug when it was not.
	if native_anim.track_get_key_count(_track) == 0: # no keys
		print_.warn("Track '%s' has no keys, using default" % _track_name)
		return DEFAULT_PARAMS[param_name]
	# try nearest key
	print_.warn("Interpolation failed for '%s' at %.3f, trying nearest key lookup" % [_track_name, timestamp])
	var key_index := native_anim.track_find_key(_track, timestamp, Animation.FIND_MODE_NEAREST)
	if key_index != -1:
		var key_value: Variant = native_anim.track_get_key_value(_track, key_index)
		var key_time: Variant = native_anim.track_get_key_time(_track, key_index)
		print_.note("Found nearest key at index %d, time %.3f, value: %s" % [key_index, key_time, str(key_value)])
		if key_value != null and key_value is bool:
			return key_value
		elif key_value != null:
			return bool(key_value)
	return DEFAULT_PARAMS[param_name] # Last resort


# region: print to str

func _to_string() -> String:
	var parts: Array[String] = []
	
	parts.append("AnimationData\n")
	parts.append("  anim_name: \"%s\"" % anim_name)
	parts.append("  _start_time: %.3f" % _start_time)
	parts.append("  _end_time: %.3f" % _end_time)
	parts.append("  duration: %.3f" % duration)
	parts.append("  speed_scale: %.3f" % speed_scale)
	parts.append("  is_looping: %s" % is_looping)
	
	if native_anim:
		parts.append("  native_anim: Animation(length=%.3f, tracks=%d)" % [native_anim.length, native_anim.get_track_count()])
	else:
		parts.append("  native_anim: null")
	
	if _markers.size() > 0:
		var marker_names := _markers.keys()
		marker_names.sort() # Sort for consistent output
		parts.append("  _markers: %d marker(s) [%s]" % [_markers.size(), ", ".join(marker_names)])
	else:
		parts.append("  _markers: {}")
	return "\n".join(parts)

func to_string_compact() -> String:
	return "%24s: %4.2f-%4.2f, dur %4.2f, scale %1.2f, lp %5s, _markers %2d" % [
		pp.in_q(anim_name), _start_time, _end_time, duration, speed_scale, str(is_looping), _markers.size()
	]

# endregion


# region: CONSTANTS

# Track names
const SWITCHES_TO_QUEUE := "switches_to_queue"
const ALLOWS_QUEUE := "allows_queue"
const VULNERABLE := "vulnerable"
const INTERRUPTABLE := "interruptable"
const WEAPON_HURTS := "weapon_hurts"
const TRACKS_INPUT_VECTOR := "tracks_input_vector"

# If no track
const DEFAULT_PARAMS := {
	SWITCHES_TO_QUEUE: false,
	ALLOWS_QUEUE: false,
	VULNERABLE: true,
	INTERRUPTABLE: true,
	WEAPON_HURTS: false,
	TRACKS_INPUT_VECTOR: true,
}

const _anim_param_track_prefix := "%AnimParameters:"

# endregion


# region: VALIDATION

static func __validate_track_values(anim: AnimationData) -> bool:
	var all_valid := true
	
	for param_name: String in [SWITCHES_TO_QUEUE, ALLOWS_QUEUE, VULNERABLE, INTERRUPTABLE, WEAPON_HURTS, TRACKS_INPUT_VECTOR]:
		var track_name := _anim_param_track_prefix + param_name
		var track_idx := anim.native_anim.find_track(track_name, Animation.TYPE_VALUE)
		
		if track_idx == -1:
			continue # Track not existing is OK
		
		var key_count := anim.native_anim.track_get_key_count(track_idx)
		if key_count == 0:
			print_.warn("Track '%s' exists but has no keys" % param_name)
			continue
		
		# Check first key (frame 0 area)
		var first_value: Variant = anim.native_anim.track_get_key_value(track_idx, 0)
		if first_value == null:
			print_.warn("Track '%s' has null value at first key! Fix in animation editor." % param_name)
			all_valid = false
		elif not first_value is bool:
			print_.warn("Track '%s' first key is not boolean: %s (%s)" % [param_name, str(first_value), type_string(typeof(first_value))])
	
	return all_valid


static func __validate_anim(anim_data: AnimationData) -> bool:
	# base field validation (not null)
	if anim_data.anim_id == null:
		return false
	if anim_data.anim_name == null:
		return false
	if anim_data.native_anim == null:
		return false

	# TODO: add validation, that marker time is within anim_data duration and start-end times. 
	#       technically marker can be outside of that (but not outside native_anum len, of course).
	#       for simplicity, lets not support that for now
	if anim_data._markers == null: # (no markers is fine, would be empty dict)
		return false
	
	# specific field validation
	if anim_data._start_time < 0:
		return false
	if anim_data._end_time <= anim_data._start_time:
		return false
	if anim_data.duration <= 0:
		return false
	if anim_data.speed_scale <= 0:
		return false

	# native anim tracks data (experimental)
	if not __validate_track_values(anim_data):
		print_.warn("Animation '%s' has invalid track values!" % anim_data.anim_name)
		return false
	
	return true


# endregion