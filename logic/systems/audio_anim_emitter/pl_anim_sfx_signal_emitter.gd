extends BaseNodeCharacterSystem
class_name AnimSFXSignalEmitter

## Monitors animation playback and emits SFX signals when Audio Track keys are crossed

@onready var anim_manager: PlAnimatorManager = %AnimatorManager

var _last_checked_time: float = 0.0
var _last_anim: AnimationData = null

var MIN_WEIGHT := 0.0

var signals: PlayerSignals
var weapon_whoosh_signal: Signal


func initialise(signals_: PlayerSignals, weapon_whoosh_signal_: Signal):
	signals = signals_
	weapon_whoosh_signal = weapon_whoosh_signal_


func emit_sfx_signal(sfx_signal: Signal, data: Dictionary[String, Variant]) -> void:
	sfx_signal.emit(data)
	
	__log_("EMIT", sfx_signal.get_name(), "with data", pp.dict_(data, false, true))


func _emit_signal_based_on_track_data(audio_track_data: AudioTrackData) -> void:
	# Use track_name (e.g. "SFX_Footstep") to identify the signal type
	var audio_stream_player_name := audio_track_data.get_audio_stream_player_name()
	var track_name := audio_track_data.track_name
	
	var r_signal: Signal
	var r_signal_data: Dictionary[String, Variant] = {}
	
	match audio_stream_player_name:
		## fs
		SfxType.footstep.anim_audio_stream_player_name:
			r_signal = signals.get_SFX_footstep()
		
		SfxType.footstep_light.anim_audio_stream_player_name:
			r_signal = signals.get_SFX_footstep()
			r_signal_data = {SfxType.modifier_key: SfxType.Modifier.light}

		SfxType.footstep_scrape.anim_audio_stream_player_name:
			r_signal = signals.get_SFX_footstep_scrape()
		
		##
		SfxType.launch.anim_audio_stream_player_name:
			r_signal = signals.get_SFX_launch()
		
		SfxType.land.anim_audio_stream_player_name:
			r_signal = signals.get_SFX_land()
		
		SfxType.whoosh.anim_audio_stream_player_name:
			r_signal = signals.get_SFX_whoosh()
		
		## weapon
		SfxType.whoosh_weapon.anim_audio_stream_player_name:
			r_signal = weapon_whoosh_signal
		
		_:
			__log_warn(true, "Unknown audio_stream_player_name", "", "no emit", audio_stream_player_name)
			return

	r_signal_data["audio_stream_player_name"] = audio_stream_player_name
	r_signal_data["stream_name"] = audio_track_data.stream_name
	
	emit_sfx_signal(r_signal, r_signal_data)


func _process(delta: float) -> void:
	var curr_anim := anim_manager.get_curr_anim()
	if curr_anim == null:
		return
		
	# handle animation change - reset tracking
	if curr_anim != _last_anim:
		var _last_anim_msg := pp.anim_n(_last_anim.anim_id) if _last_anim else "[-x-]"
		__log_extra("ANIM_CHANGE",
			"prev", _last_anim_msg, "-> new", pp.anim_n(curr_anim.anim_id), "| reset time tracking")
		
		_last_checked_time = 0.0
		_last_anim = curr_anim
		return
	
	var curr_time := anim_manager.get_curr_anim_effective_time_spent()

	# handle loop wrap - reset tracking
	if curr_time < _last_checked_time:
		__log_extra("LOOP_WRAP", "anim", pp.anim_n(curr_anim.anim_id),
			"time prev/curr", _last_checked_time, curr_time, "| reset time tracking")
		
		# check the "Gap" at the end of the previous loop
		_check_audio_tracks(curr_anim, _last_checked_time, curr_anim.duration)

		_last_checked_time = 0.0
	
	# Check for crossed Audio keys (normal window or new loop start)
	_check_audio_tracks(curr_anim, _last_checked_time, curr_time)
	
	_last_checked_time = curr_time


func _check_audio_tracks(anim: AnimationData, from_time: float, to_time: float) -> void:
	var timestamps: Array[float] = anim.get_audio_tracks_timestamps_sorted()
	
	for timestamp in timestamps:
		if timestamp > to_time:
			break # future events, stop iterating
			
		if _is_time_in_window(timestamp, from_time, to_time):
			if anim_manager.is_blending():
				var weight := anim_manager.get_curr_blend_percentage()
				if weight < MIN_WEIGHT:
					__log_("Audio Event skipped✖️", timestamp, "weight", weight, "<", MIN_WEIGHT)
					continue

			var audio_track_data_list := anim.get_audio_tracks_data_by_timestamp(timestamp)
			
			if not audio_track_data_list or audio_track_data_list.is_empty():
				__log_warn(true, "not audio_track_data_list or audio_track_data_list.is_empty()", "", "", "audio_track_data_list", audio_track_data_list, "timestamp", timestamp)
				continue

			# __log_("Audio Track Data(s) crossed🎵", timestamp, "| window:", pp.in_sq(pp.s(from_time, "->", to_time)))
			
			for data: AudioTrackData in audio_track_data_list:
				_emit_signal_based_on_track_data(data)


# ensure 0.0 start times are caught
func _is_time_in_window(val: float, start: float, end: float) -> bool:
	if start == 0.0:
		return val >= start and val <= end
	else:
		return val > start and val <= end


## __LOG
# region

func is_player() -> bool:
	return true

func pp_name() -> String:
	return "AnimSFXSignalEmitter"

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0

var __LOG_EXTRA: bool = false

func __log_extra(prefix: String, ...parts):
	if __LOG_EXTRA: __log_(prefix, pp.list_(parts))

# endregion


# region: first implementation with markers

## NOTE: testing but try some conventions to follow:
##
## order important: SFX + main type + modifiers
## e.g: 
## 	 'SFX_' + 'footstep' + 'light' | here 'light' - quality
##   'SFX_' + 'whoosh' + 'weapon' | here 'weapon' - where come from
##
## in case of hit, source + target: 'SFX_' + 'hit_' + 'weapon' + 'ground' 
## (if all entities matter. also not sure this would be used)
##
# class SFX:
# 	const GLOBAL_PREFIX := "SFX"

# 	# types
# 	const FOOTSTEP_PREFIX := GLOBAL_PREFIX + "_" + SFX_MainTypes.footstep
# 	const WHOOSH_PREFIX := GLOBAL_PREFIX + "_" + SFX_MainTypes.whoosh
# 	const LAUNCH_PREFIX := GLOBAL_PREFIX + "_" + SFX_MainTypes.launch
# 	const LAND_PREFIX := GLOBAL_PREFIX + "_" + SFX_MainTypes.land
# 	const HIT_WEAPON_PREFIX := GLOBAL_PREFIX + "_" + SFX_MainTypes.hit_weapon
# 	const HIT_WHOOSH_WEAPON_PREFIX := GLOBAL_PREFIX + "_" + SFX_MainTypes.whoosh_weapon
	
# 	# modifiers
# 	const FOOTSTEP_LIGHT_PREFIX := FOOTSTEP_PREFIX + "_" + SFX_MainTypes.Modifier.light

# 	const HIT_WEAPON_GROUND_PREFIX := HIT_WEAPON_PREFIX + "_" + "ground"

# func _emit_signal_based_on_marker(marker_name: String) -> void:
# 	var r_signal: Signal
# 	var r_data: Dictionary = {}
# 	if marker_name.begins_with(MarkerName.SFX.FOOTSTEP_PREFIX):
# 		if marker_name.begins_with(MarkerName.SFX.FOOTSTEP_LIGHT_PREFIX):
# 			r_signal = signals.get_SFX_footstep()
# 			r_data = {"modifier": SFX_MainTypes.Modifier.light}
# 		else:
# 			r_signal = signals.get_SFX_footstep()
# 	elif marker_name.begins_with(MarkerName.SFX.LAUNCH_PREFIX):
# 		r_signal = signals.get_SFX_launch()
# 	elif marker_name.begins_with(MarkerName.SFX.LAND_PREFIX):
# 		r_signal = signals.get_SFX_land()
# 	elif marker_name.begins_with(MarkerName.SFX.WHOOSH_PREFIX):
# 		r_signal = signals.get_SFX_whoosh()
# 	elif marker_name.begins_with(MarkerName.SFX.HIT_WEAPON_PREFIX):
# 		r_signal = signals.get_SFX_hit_weapon()
# 	else:
# 		__log_warn(true, "Unknown SFX marker", "", "ignored", "marker_name:", marker_name)
# 		return

# 	emit_sfx_signal(r_signal, r_data)


# func _check_sfx_markers(anim: AnimationData, from_time: float, to_time: float) -> void:
# 	var sfx_markers := anim.get_markers_by_prefix(MarkerName.SFX.GLOBAL_PREFIX)
	
# 	for marker: AnimMarker in sfx_markers:
# 		if _is_time_in_window(marker.time, from_time, to_time):
# 			# If < MIN_WEIGHT, anim is not dominant yet
# 			if anim_manager.is_blending():
# 				var weight := anim_manager.get_curr_blend_percentage()
# 				if weight < MIN_WEIGHT:
# 					__log_("Marker skipped✖️", marker, "weight", weight, "<", MIN_WEIGHT)
# 					continue

# 			__log_("Marker crossed🚶🏻‍♀️", marker, "| window:", pp.in_sq(pp.s(from_time, "->", to_time)))
# 			_emit_signal_based_on_marker(marker.marker_name)
# endregion
