extends Resource
class_name AnimationData

var anim_id: String ## lib + resource_name
var anim_name: String ## resource_name
var start_time: float
var end_time: float
var duration: float
var speed_scale: float
var is_looping: bool
var native_anim: Animation
var markers: Dictionary # {str: M.Marker}

func _init(
		_anim_id,
		_name = "",
		_start = 0,
		_end = 0,
		_duration = 0,
		_speed_scale: float = 1.0,
		_loop = false,
		_native_anim = null,
		markers_ = null
		):
	anim_id = _anim_id
	anim_name = _name
	start_time = _start
	end_time = _end
	duration = _duration
	speed_scale = _speed_scale
	is_looping = _loop
	native_anim = _native_anim
	markers = markers_ if markers_ else {}

	if native_anim and not validate_track_values():
		print_.warn("Animation '%s' has invalid track values!" % anim_name)

## Client code may get some specific marker directly.
func get_marker_by_name(marker_name: String) -> M.Marker:
	return u.safe_get_dict_key(markers, marker_name, "get marker from anim data")

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
	var _track_name = _track_begins + param_name
	if not native_anim:
		print("WTF")
	var _track = native_anim.find_track(_track_name, Animation.TYPE_VALUE)
	
	if _track == -1:
		# print_.warn("Track not found: " + _track_name + " in animation " + anim_name)
		return DEFAULT_PARAMS[param_name]

	# NOTE the '+ start_time' shift. It's important
	var value = native_anim.value_track_interpolate(_track, timestamp + start_time)
	if value is bool:
		return value

	# WARNING: Normally return value should be bool already. But there was a bug when it was not.
	if native_anim.track_get_key_count(_track) == 0: # no keys
		print_.warn("Track '%s' has no keys, using default" % _track_name)
		return DEFAULT_PARAMS[param_name]
	# try nearest key
	print_.warn("Interpolation failed for '%s' at %.3f, trying nearest key lookup" % [_track_name, timestamp])
	var key_index = native_anim.track_find_key(_track, timestamp, Animation.FIND_MODE_NEAREST)
	if key_index != -1:
		var key_value = native_anim.track_get_key_value(_track, key_index)
		var key_time = native_anim.track_get_key_time(_track, key_index)
		print_.debug("Found nearest key at index %d, time %.3f, value: %s" % [key_index, key_time, str(key_value)])
		if key_value != null and key_value is bool:
			return key_value
		elif key_value != null:
			return bool(key_value)
	return DEFAULT_PARAMS[param_name] # Last resort

func validate_track_values() -> bool:
	var all_valid = true
	
	for param_name in [SWITCHES_TO_QUEUE, ALLOWS_QUEUE, VULNERABLE, INTERRUPTABLE, WEAPON_HURTS, TRACKS_INPUT_VECTOR]:
		var track_name = _track_begins + param_name
		var track_idx = native_anim.find_track(track_name, Animation.TYPE_VALUE)
		
		if track_idx == -1:
			continue # Track not existing is OK
		
		var key_count = native_anim.track_get_key_count(track_idx)
		if key_count == 0:
			print_.warn("Track '%s' exists but has no keys" % param_name)
			continue
		
		# Check first key (frame 0 area)
		var first_value = native_anim.track_get_key_value(track_idx, 0)
		if first_value == null:
			print_.warn("Track '%s' has null value at first key! Fix in animation editor." % param_name)
			all_valid = false
		elif not first_value is bool:
			print_.warn("Track '%s' first key is not boolean: %s (%s)" % [param_name, str(first_value), type_string(typeof(first_value))])
	
	return all_valid


# region: print to str

func _to_string() -> String:
	var parts: Array[String] = []
	
	parts.append("AnimationData {")
	parts.append("  anim_name: \"%s\"" % anim_name)
	parts.append("  start_time: %.3f" % start_time)
	parts.append("  end_time: %.3f" % end_time)
	parts.append("  duration: %.3f" % duration)
	parts.append("  speed_scale: %.3f" % speed_scale)
	parts.append("  is_looping: %s" % is_looping)
	
	if native_anim:
		parts.append("  native_anim: Animation(length=%.3f, tracks=%d)" % [native_anim.length, native_anim.get_track_count()])
	else:
		parts.append("  native_anim: null")
	
	if markers.size() > 0:
		var marker_names = markers.keys()
		marker_names.sort() # Sort for consistent output
		parts.append("  markers: %d marker(s) [%s]" % [markers.size(), ", ".join(marker_names)])
		
		# Optionally detailed
		# for marker_name in marker_names:
		#     var marker = markers[marker_name]
		#     parts.append("    - %s: %s" % [marker_name, str(marker)])
	else:
		parts.append("  markers: {} (empty)")
	
	parts.append("}")
	
	return "\n".join(parts)

func to_string_compact() -> String:
	return "%24s: %4.2f-%4.2f, dur %4.2f, scale %1.2f, lp %5s, markers %2d" % [
		pp.in_q(anim_name), start_time, end_time, duration, speed_scale, str(is_looping), markers.size()
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

const _track_begins = "%AnimParameters:"

# endregion