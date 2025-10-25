@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_grid.png")

extends BaseAnimationContainer
## for simplicity this container is used for all characters.
## if native_player dont have animation name from _animations, it will simply skip it
class_name AnimationContainer


var _anim_by_id := {}


## MAIN INTERFACE
func get_by_anim_id(anim_id: String) -> AnimationData:
	return u.safe_get_dict_key(_anim_by_id, anim_id, "AnimationContainer.get_by_anim_id")


## native_player - player's player, se's player, etc
func _accept_animations(_animations: Array[AnimationData], native_player: AnimationPlayer) -> void:
	for anim: AnimationData in _animations:
		# get native anim
		if not native_player.has_animation(anim.anim_id):
			continue

		var native_anim: Animation = native_player.get_animation(anim.anim_id)

		# NOTE: i think it's safer to duplicate, since different characters may rely on the same resource
		anim.native_anim = native_anim.duplicate()
		
		# name
		anim.anim_name = native_anim.resource_name

		# is looping
		anim.is_looping = (native_anim.loop_mode == Animation.LOOP_LINEAR)

		# timings
		__enrich_with_end_start_times(anim)
		
		# all markers # todo: this can be used before __enrich_with_end_start_times
		var markers := __get_animation_markers(anim.native_anim)
		anim._markers = markers

		# Build the track cache for this animation
		anim._track_path_to_idx = __build_track_cache(anim.native_anim)

		_anim_by_id[anim.anim_id] = anim


	# VALIDATION
	var invalid_animations := []
	for anim in _anim_by_id.values():
		if not AnimationData.__validate_anim(anim):
			invalid_animations.append(anim.anim_name)
		else:
			print_.container("", anim.anim_name + " is valid")

	if invalid_animations.size() > 0:
		print_.warn("Found %d invalid animations: %s" % [invalid_animations.size(), ", ".join(invalid_animations)])


static func __build_track_cache(native_anim: Animation) -> Dictionary:
	var cache := {"pos": {}, "rot": {}}
	for i in range(native_anim.get_track_count()):
		var path: String = native_anim.track_get_path(i)
		var type: int = native_anim.track_get_type(i)
		
		if type == Animation.TYPE_POSITION_3D:
			cache["pos"][path] = i
		elif type == Animation.TYPE_ROTATION_3D:
			cache["rot"][path] = i
	return cache


func __enrich_with_end_start_times(anim: AnimationData):
	var native_anim := anim.native_anim

	var _start_time: float = 0.0
	var _end_time: float = native_anim.length
	var _duration := 0.0

	var _has_start_marker: bool = native_anim.has_marker(Marker.Name_.START)
	var _has_end_marker: bool = native_anim.has_marker(Marker.Name_.END)

	if anim.is_looping:
		# WARNING: The animation is always considered to run for its full length to loop correctly.
		#    - 'end' marker is ignored for looping _animations. 
		#    - 'start' marker does not influence the duration!
		if _has_start_marker:
			_start_time = native_anim.get_marker_time(Marker.Name_.START)
		_duration = native_anim.length
	else:
		if _has_start_marker:
			_start_time = native_anim.get_marker_time(Marker.Name_.START)
		if _has_end_marker:
			_end_time = native_anim.get_marker_time(Marker.Name_.END)
		if _start_time > _end_time:
			print_.warn("markers: _start_time > _end_time, _end_time will be ignored")
			_end_time = native_anim.length
		_duration = _end_time - _start_time

	anim._start_time = _start_time
	anim._end_time = _end_time
	anim.duration = _duration


static func __get_animation_markers(animation: Animation) -> Dictionary:
	## Returns dict {marker_name: Marker instance}
	var markers_dict: Dictionary = {}
	
	var marker_names: PackedStringArray = animation.get_marker_names()
	
	# Create Marker instances for each marker
	for marker_name in marker_names:
		var marker_time: float = animation.get_marker_time(marker_name)
		
		var marker := Marker.new(marker_time, marker_name)
		markers_dict[marker_name] = marker
	
	return markers_dict
