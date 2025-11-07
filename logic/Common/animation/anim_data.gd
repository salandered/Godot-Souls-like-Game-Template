extends Resource
class_name AnimationData

var anim_id: String ## lib + resource_name
var anim_name: String ## resource_name
# NOTE: there could be start_time here, but all animation systems already embraced the dynamic 'start_time_offset' feature.
# 		it can do anything that hard 'start_time' can offer, while using 'start_time' on top of it would make animators logic even more complex
#       Also hard 'start time' leaded to non obvious quirks like it does not influence the duration of looping animations.
# var _end_time: float ## UPD: turned off. It's fine and should be useful but needs more testing. Right now systems could handle without it.
## duration is the same as native_anim.length
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
func get_marker_by_name(marker_name: String, fallback: String = Fallback.WARN) -> Marker:
	return u.safe_get_dict_key(_markers, marker_name, null, "get marker from anim " + anim_id, fallback)

func does_marker_exist(marker_name: String) -> bool:
	var marker := get_marker_by_name(marker_name, Fallback.SOFT)
	return marker != null


## returns time withing anim.duration
## returns -1 or default_value (if set) in case of problems
func get_marker_time_by_name(marker_name: String, default_value: float = -1) -> float:
	var marker := get_marker_by_name(marker_name)
	if not marker:
		print_.warn_raw(false, "marker not found " + pp.in_q(marker_name))
		return default_value
	if duration - marker.time < 0.0:
		print_.warn_raw(false, "marker time outside the duration")
		return default_value
	return marker.time


# region: print to str

func _to_string() -> String:
	var parts: Array[String] = []
	
	parts.append("AnimationData\n")
	parts.append("  anim_name: \"%s\"" % anim_name)
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
	return "%24s: dur %4.2f, scale %1.2f, lp %5s, _markers %2d" % [
		pp.in_q(anim_name), duration, speed_scale, str(is_looping), _markers.size()
	]

# endregion


# region: CONSTANTS


# endregion


# region: VALIDATION

static func __validate_track_values(anim: AnimationData, param_prefix: String, param_tracks: Array[String]) -> bool:
	var all_valid := true
	
	for param_name: String in param_tracks:
		var track_name := param_prefix + param_name
		var track_idx := anim.native_anim.find_track(track_name, Animation.TYPE_VALUE)
		
		if track_idx == -1:
			continue # Track not existing is OK
		
		var key_count := anim.native_anim.track_get_key_count(track_idx)
		if key_count == 0:
			print_.warn_raw(false, "Track '%s' exists but has no keys" % param_name)
			continue
		
		# Check first key (frame 0 area)
		var first_value: Variant = anim.native_anim.track_get_key_value(track_idx, 0)
		if first_value == null:
			print_.warn_raw(false, "Track '%s' has null value at first key! Fix in animation editor." % param_name)
			all_valid = false
		elif not first_value is bool:
			print_.warn_raw(false, "Track '%s' first key is not boolean: %s (%s)" % [param_name, str(first_value), type_string(typeof(first_value))])
	
	return all_valid


static func __validate_anim(anim_data: AnimationData, param_prefix: String, param_tracks: Array[String]) -> bool:
	# base field validation (not null)
	if anim_data.anim_id == null:
		return false
	if anim_data.anim_name == null:
		return false
	if anim_data.native_anim == null:
		return false

	# TODO: add validation, that marker time is within anim_data duration. 
	if anim_data._markers == null: # (no markers is fine, would be empty dict)
		return false
	
	# specific field validation
	if anim_data.duration <= 0:
		return false
	if anim_data.speed_scale <= 0:
		return false

	# native anim tracks data (experimental)
	if not __validate_track_values(anim_data, param_prefix, param_tracks):
		print_.warn_raw(false, "Animation '%s' has invalid track values!" % anim_data.anim_name)
		return false
	
	return true


# endregion