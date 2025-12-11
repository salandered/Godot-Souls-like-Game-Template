extends ResourceLogger
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
## markers have unique names by Godot design. So we can use marker_name as a dictionary key
var _markers: Dictionary[String, AnimMarker] # {marker_name <String>: <AnimMarker>}
var _audio_tracks: Dictionary[float, Array] # { timestamp <float>: Array[AudioTrackKey] }
## caches timestamps sorted ASC, was built using _audio_tracks
var _audio_tracks_timestamps_sorted: Array[float]
var uses_root_rotation: bool
# { "pos": {track_path: track_idx, ...}, "rot": {track_path: track_idx, ...} }
var _tranform_track_path_to_idx: Dictionary[String, Dictionary] = {"pos": {}, "rot": {}}

func _init(
		_anim_id,
		_speed_scale: float = 1.0,
		_uses_root_rotation: bool = false
		):
	anim_id = _anim_id
	speed_scale = _speed_scale
	uses_root_rotation = _uses_root_rotation


func get_pos_track_idx(track_path: String) -> int:
	if track_path in _tranform_track_path_to_idx["pos"]:
		return _tranform_track_path_to_idx["pos"][track_path]
	return -1

func get_rot_track_idx(track_path: String) -> int:
	if track_path in _tranform_track_path_to_idx["rot"]:
		return _tranform_track_path_to_idx["rot"][track_path]
	return -1


## Client code may get some specific marker directly.
func get_marker_by_name(marker_name: String, warn_level: String = WL.WARN) -> AnimMarker:
	return u.safe_get_dict_key(_markers, marker_name, null, warn_level)

func get_markers_by_prefix(prefix: String) -> Array[AnimMarker]:
	var result: Array[AnimMarker] = []
	for marker_name in _markers.keys():
		if marker_name.begins_with(prefix):
			result.append(_markers[marker_name])
	return TypeCast.array_of_anim_marker(result)

func does_marker_exist(marker_name: String) -> bool:
	var marker := get_marker_by_name(marker_name, WL.SILENT)
	return marker != null


func get_audio_tracks_timestamps_sorted() -> Array[float]:
	return _audio_tracks_timestamps_sorted

func get_audio_tracks_data_by_timestamp(timestamp: float) -> Array[AudioTrackKey]:
	var r: Array = u.safe_get_dict_key(_audio_tracks, timestamp, null)
	return TypeCast.array_of_audio_track_data(r)
# native_anim.track_is_enabled(track_idx)

## returns time withing anim.duration
## returns -1 or default_value (if set) in case of problems
func get_marker_time_by_name(marker_name: String, default_value: float = -1) -> float:
	var marker := get_marker_by_name(marker_name)
	if not marker:
		__log_warn("marker not found " + pp.in_q(marker_name))
		return default_value
	if duration - marker.time < 0.0:
		__log_warn("marker time outside the duration")
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


## __LOGS
# region

func pp_name() -> String:
	return "AnimData|" + anim_name

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0

# endregion