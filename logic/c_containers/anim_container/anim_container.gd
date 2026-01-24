@tool
@icon("res://-assets-/x_icons/white/icon_grid.png")

class_name AnimContainer
extends BaseAnimContainer


## for simplicity this container is used for all characters for now.
## if native_player dont have animation name from _animations, it will simply skip it


var _anim_by_id: Dictionary[String, AnimationData] = {}


## MAIN INTERFACE
func get_by_anim_id(anim_id: String) -> AnimationData:
	return DictUtils.safe_get_dict_key(_anim_by_id, anim_id, null, WL.WARN)


## native_player - player's player, se's player, etc
func _accept_animations(
		_animations: Array[AnimationData],
		native_player: AnimationPlayer,
		param_prefixes: Array[String],
		param_tracks: Array[String],
		required_markers: Dictionary[String, Array],
	) -> void:
	for anim: AnimationData in _animations:
		# get native anim
		if not AnimUtils.safe_has_animation(native_player, anim.anim_id, WL.SILENT):
			continue

		var raw_native_anim: Animation = native_player.get_animation(anim.anim_id)

		# WARNING: Important! should be as higher as possible. Also consider deep flag if inner data like streams matter
		anim.native_anim = raw_native_anim.duplicate()
		
		# name
		anim.anim_name = raw_native_anim.resource_name

		# is looping
		anim.is_looping = (anim.native_anim.loop_mode == Animation.LOOP_LINEAR)

		# timings
		anim.duration = anim.native_anim.length
		
		# all markers
		var markers := __get_animation_markers(anim.native_anim)
		anim._markers = markers

		# all audio tracks data
		var audio_tracks := __get_audio_tracks_data(anim.native_anim, anim.anim_id)
		anim._audio_tracks = audio_tracks
		var _all_timestamps := TypeCast.array_of_float(audio_tracks.keys())
		_all_timestamps.sort()
		anim._audio_tracks_timestamps_sorted = _all_timestamps

		# Build the transform (usually bone data) track cache
		anim._tranform_track_path_to_idx = __build_transform_track_cache(anim.native_anim)

		_anim_by_id[anim.anim_id] = anim


	# VALIDATION
	var invalid_animations: Array[String] = []
	for anim: AnimationData in _anim_by_id.values():
		if not AnimDataValidator.validate_anim(anim, param_prefixes, param_tracks, required_markers):
			invalid_animations.append(anim.anim_name)
		else:
			__log_("", anim.anim_name, "is valid")

	if invalid_animations.size() > 0:
		__log_error("Found %d invalid animations: %s" % [invalid_animations.size(), ", ".join(invalid_animations)], "", "")


## Returns dict { timestamp <float>: Array[AudioTrackKey] }
## NOTE: Disables all audio tracks. We dont need them to play directly. 
func __get_audio_tracks_data(native_anim: Animation, anim_id: String) -> Dictionary[float, Array]:
	var result_dict: Dictionary[float, Array] = {}
	
	var track_count: int = native_anim.get_track_count()
	var audio_track_count := 0
	var audio_stream_total := 0
	
	for track_idx: int in track_count:
		var track_type: int = native_anim.track_get_type(track_idx)

		if track_type != Animation.TYPE_AUDIO:
			continue

		var track_enabled := native_anim.track_is_enabled(track_idx)
		if track_enabled:
			# prints("disabled", track_idx)
			native_anim.track_set_enabled(track_idx, false)
		# var track_enabled_2 := native_anim.track_is_enabled(track_idx)
		# prints("disabled ////////////", track_enabled, track_enabled_2)
		audio_track_count += 1
		
		var track_path: NodePath = native_anim.track_get_path(track_idx)
		var track_name: String = track_path.get_concatenated_names()
		var key_count: int = native_anim.track_get_key_count(track_idx)

		# __log_("[AudioEvents]", "track_idx", track_idx, "name", track_name, "keys", key_count)
		
		for key_idx in key_count:
			var timestamp: float = native_anim.track_get_key_time(track_idx, key_idx)
			var stream: AudioStream = native_anim.audio_track_get_key_stream(track_idx, key_idx)
			if not stream:
				__log_error("[AudioEvents] stream is null", "", "continue", "key_idx/timestamp", key_idx, timestamp)
				continue
			
			var start_offset: float = native_anim.audio_track_get_key_start_offset(track_idx, key_idx)
			var end_offset: float = native_anim.audio_track_get_key_end_offset(track_idx, key_idx)
			var _stream_name := stream.resource_name
			var audio_data := AudioTrackKey.new(
				timestamp,
				track_idx,
				track_enabled,
				track_name,
				_stream_name,
				start_offset,
				end_offset)
			
			if not result_dict.has(timestamp):
				result_dict[timestamp] = []
			
			result_dict[timestamp].append(audio_data)
			audio_stream_total += 1
			
			# prints("[AudioEvents]", "added:", audio_data)
	
	if audio_track_count > 0:
		__log_("[AudioEvents]", pp.anim_n(anim_id),
			"Number of tracks/track keys/timestamps", audio_track_count, audio_stream_total, result_dict.size())
	
	return result_dict


static func __build_transform_track_cache(native_anim: Animation) -> Dictionary[String, Dictionary]:
	var cache: Dictionary[String, Dictionary] = {"pos": {}, "rot": {}}
	for i in range(native_anim.get_track_count()):
		var path: String = native_anim.track_get_path(i)
		var type: int = native_anim.track_get_type(i)
		
		if type == Animation.TYPE_POSITION_3D:
			cache["pos"][path] = i
		elif type == Animation.TYPE_ROTATION_3D:
			cache["rot"][path] = i
	return cache


static func __get_animation_markers(animation: Animation) -> Dictionary[String, AnimMarker]:
	## Returns dict {marker_name: AnimMarker instance}
	var markers_dict: Dictionary[String, AnimMarker] = {}
	
	var marker_names: PackedStringArray = animation.get_marker_names()
	
	# Create AnimMarker instances for each marker
	for marker_name in marker_names:
		var marker_time: float = animation.get_marker_time(marker_name)
		
		var marker := AnimMarker.new(marker_time, marker_name)
		markers_dict[marker_name] = marker
	
	return markers_dict


func __LOG_B() -> bool:
	return LogToggler.ANIM_CONTAINER_B

func __LOG_INDENT() -> int:
	return 0
