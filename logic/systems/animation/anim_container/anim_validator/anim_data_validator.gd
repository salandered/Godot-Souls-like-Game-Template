extends RefCountedStaticLogger
class_name AnimDataValidator


static func validate_anim(anim_data: AnimationData, param_prefixes: Array[String], param_tracks: Array[String], required_markers: Dictionary[String, Array]) -> bool:
	# base field validation (not null)
	if anim_data.anim_id == null:
		return false
	if anim_data.anim_name == null:
		return false
	if anim_data.native_anim == null:
		return false

	# TODO: add validation, that marker time is within anim_data duration. 
	if anim_data._markers == null: # (no markers is fine, but then it would be empty dict)
		return false

	var _required_markers: Variant = required_markers.get(anim_data.anim_id)
	if _required_markers == null:
		pass
		# prints("_required_markers is null for", anim_data.anim_id)
	else:
		for marker_name: String in TypeCast.array_of_string(_required_markers):
			if not anim_data.does_marker_exist(marker_name):
				__log_warn_assert(pp.s("required marker", pp.in_q(marker_name), "not found!"), anim_data.anim_id)
	

	if anim_data._audio_tracks == null: # (no data is fine, but then it would be empty dict)
		return false

	if len(anim_data._audio_tracks) != len(anim_data._audio_tracks_timestamps_sorted):
		return false


	# specific field validation
	if anim_data.duration <= 0:
		return false
	if anim_data.speed_scale <= 0:
		return false

	# native anim tracks data (experimental)
	if not _validate_track_values(anim_data, param_prefixes, param_tracks):
		__log_warn("Animation '%s' has invalid track values!" % anim_data.anim_name)
		return false
	
	return true


static func _validate_track_values(anim: AnimationData, param_prefixes: Array[String], param_tracks: Array[String]) -> bool:
	var all_valid := true
	
	for param_name: String in param_tracks:
		for param_prefix in param_prefixes:
			var track_name := param_prefix + param_name
			var track_idx := anim.native_anim.find_track(track_name, Animation.TYPE_VALUE)
			
			if track_idx == -1:
				continue # Track not existing is OK
			
			var key_count := anim.native_anim.track_get_key_count(track_idx)
			if key_count == 0:
				__log_warn("Track '%s' exists but has no keys" % param_name)
				continue
			
			# Check first key (frame 0 area)
			var first_value: Variant = anim.native_anim.track_get_key_value(track_idx, 0)
			if first_value == null:
				__log_warn("Track '%s' has null value at first key! Fix in animation editor." % param_name)
				all_valid = false
			elif not first_value is bool:
				__log_warn("Track '%s' first key is not boolean: %s (%s)" % [param_name, str(first_value), type_string(typeof(first_value))])
		
	return all_valid
