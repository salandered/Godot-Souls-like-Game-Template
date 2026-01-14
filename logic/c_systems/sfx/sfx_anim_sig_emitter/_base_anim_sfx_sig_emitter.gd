@abstract
class_name BaseAnimSFXSignalEmitter
extends NodeCharacterSystem

## Monitors animation playback and emits SFX signal_container when AudioTrackKey keys are crossed


var _last_checked_time: float = 0.0
var _last_anim: AnimationData = null


var sad_container: BaseSADContainer

var signal_container: BaseSignalContainer

var ENABLED: bool = true ## DEV DANGER


var _audio_track_throttler: EventThrottler


@abstract func get_anim_manager() -> BaseAnimatorManager

func disable():
	ENABLED = false

func enable():
	ENABLED = true


func __hard_dependencies() -> Array[Object]:
	return [
		sad_container,
		signal_container
	]


func initialise(sad_container_: BaseSADContainer, signal_container_: BaseSignalContainer):
	self.sad_container = sad_container_
	self.signal_container = signal_container_

	self._audio_track_throttler = EventThrottler.new(0.4, 2.0, 3.0, "AudioTrackKey")

	__perform_validation()


func emit_sfx_signal(signal_data: SignalData, payload: Dictionary[String, Variant]) -> void:
	u.safe_emit(signal_data, payload)
	
	# if payload.get("anim_id") in [PHEA.attack.scare_off, A.attack.sword_slash_1]:
		# __log_("EMIT", signal_data, "with data", pp.dict_(payload, false, true))


func _emit_signal_based_on_track_data(audio_track_data: AudioTrackKey, anim: AnimationData) -> void:
	var asp_name := audio_track_data.get_anim_asp_name()

	var r_signal_payload: Dictionary[String, Variant] = {}

	var sfx_anim_data := sad_container.get_by_anim_sfx_asp_name(asp_name)
	if not sfx_anim_data:
		return
	var signal_data := signal_container.get_by_sig_id(sfx_anim_data.signal_id)
	if not signal_data:
		return
		
	r_signal_payload["asp_name"] = asp_name
	r_signal_payload["stream_name"] = audio_track_data.stream_name
	r_signal_payload["timestamp"] = audio_track_data.timestamp
	r_signal_payload["anim_id"] = anim.anim_id
	
	emit_sfx_signal(signal_data, r_signal_payload)


func _process(delta: float) -> void:
	if not ENABLED or not __validation_ok():
		return
	
	var curr_anim := get_anim_manager().get_curr_anim()
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
	
	var curr_time := get_anim_manager().get_curr_anim_effective_time_spent()

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
			var audio_track_data_list := anim.get_audio_tracks_data_by_timestamp(timestamp)
			
			if not audio_track_data_list or audio_track_data_list.is_empty():
				__log_warn_soft(pp.s("not audio_tr_data_list or its empty:", audio_track_data_list, "tmstmp", timestamp))
				continue

			# __log_("Audio Track Data(s) crossed🎵", timestamp, "| window:", pp.in_sq(pp.s(from_time, "->", to_time)))
			
			for item: AudioTrackKey in audio_track_data_list:
				var unique_id := item.get_instance_id()
				if not item.track_enabled:
					continue

				if _audio_track_throttler.is_throttled(unique_id):
					__log_extra("THROTTLED", "Skipping", item.get_anim_asp_name())
					continue
				
				_emit_signal_based_on_track_data(item, anim)
				_audio_track_throttler.record_event(unique_id)


# endregion


# ensure 0.0 start times are caught
func _is_time_in_window(val: float, start: float, end: float) -> bool:
	if start == 0.0:
		return val >= start and val <= end
	else:
		return val > start and val <= end


## __LOG
# region


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0

var __LOG_EXTRA: bool = false

func __log_extra(prefix: String, ...parts):
	if __LOG_EXTRA: __log_(prefix, pp.list_(parts))

# endregion


# region # idea for weight
# if _is_time_in_window(timestamp, from_time, to_time):
		# TODO: need it or not; probably not
		# var MIN_WEIGHT := 0.0
		# if get_anim_manager().is_blending():
		# 	var weight := get_anim_manager().get_curr_blend_percentage()
		# 	if weight < MIN_WEIGHT:
		# 		__log_("Audio Event skipped✖️", timestamp, "weight", weight, "<", MIN_WEIGHT)
		# 		continue

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
# 			r_signal = signal_container.get_SFX_footstep()
# 			r_data = {"modifier": SFX_MainTypes.Modifier.light}
# 		else:
# 			r_signal = signal_container.get_SFX_footstep()
# 	elif marker_name.begins_with(MarkerName.SFX.LAUNCH_PREFIX):
# 		r_signal = signal_container.get_SFX_launch()
# 	elif marker_name.begins_with(MarkerName.SFX.LAND_PREFIX):
# 		r_signal = signal_container.get_SFX_land()
# 	elif marker_name.begins_with(MarkerName.SFX.WHOOSH_PREFIX):
# 		r_signal = signal_container.get_SFX_whoosh()
# 	elif marker_name.begins_with(MarkerName.SFX.HIT_WEAPON_PREFIX):
# 		r_signal = signal_container.get_SFX_hit_weapon()
# 	else:
# 		__log_error( "Unknown SFX marker", "", "ignored", "marker_name:", marker_name)
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
