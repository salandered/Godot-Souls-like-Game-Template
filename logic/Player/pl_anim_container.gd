@tool
@icon("res://-assets-/x_misc/x_icons/icon_grid.png")

extends AnimationContainer
class_name PlayerAnimationContainer

@onready var native_player: AnimationPlayer = %NativeAnimator


var _animations = [
	# loco
	AnimationData.new(A.idle),
	AnimationData.new(A.walk),
	AnimationData.new(A.idle_to_sprint),
	AnimationData.new(A.idle_turn_to_run_L, 1.0, true),
	AnimationData.new(A.sprint_to_idle, 0.85),
	AnimationData.new(A.run),
	AnimationData.new(A.sprint),
	# AnimationData.new(A.run_L),
	AnimationData.new(A.run_R),
	AnimationData.new(A.turn_180_R, 1.0, true),
	AnimationData.new(A.turn_180_L, 1.0, true),
	AnimationData.new(A.fast_turn_180_R, 1.0, true),
	AnimationData.new(A.fast_turn_180_L, 1.0, true),
	# loco jump
	AnimationData.new(A.midair),
	AnimationData.new(A.small_jump_run),
	AnimationData.new(A.jump_sprint),
	AnimationData.new(A.landing_sprint),
	AnimationData.new(A.jump_idle),
	AnimationData.new(A.roll),
	#
	AnimationData.new(A.death),
	# fight
	AnimationData.new(A.longsword_1),
	AnimationData.new(A.longsword_2, 0.85),
	AnimationData.new(A.hit_reaction),
	AnimationData.new(A.staggered),
	AnimationData.new(A.parry),
	AnimationData.new(A.parried),
	AnimationData.new(A.riposte_attack),
	AnimationData.new(A.idle_longsword),
]

var _anim_by_name := {}


## MAIN INTERFACE
func get_by_name(anim_name: String) -> AnimationData:
	return u.safe_get_dict_key(_anim_by_name, anim_name, "PlayerAnimationContainer.get_by_name")


func _accept_animations() -> void:
	for anim: AnimationData in _animations:
		# get native anim
		if not ua.assert_has_animation(native_player, anim.anim_id, false):
			continue
		var native_anim: Animation = native_player.get_animation(anim.anim_id)
		anim.native_anim = native_anim
		
		# name
		anim.anim_name = native_anim.resource_name

		# is looping
		anim.is_looping = (native_anim.loop_mode == Animation.LOOP_LINEAR)

		# timings
		__enrich_with_end_start_times(anim)
		if anim.anim_id == A.run or anim.anim_id == A.sprint:
			print()
		# all markers # todo: this can be used before __enrich_with_end_start_times
		var markers = __get_animation_markers(anim.native_anim)
		anim.markers = markers

		_anim_by_name[anim.anim_id] = anim

		if anim.anim_id == A.longsword_1:
			print("~~", anim._to_string())
	

	# TODO: for double action. It should not play it at all
	_anim_by_name[A.fake_anim] = _anim_by_name[A.midair]


	# VALIDATION
	var invalid_animations := []
	for anim in _anim_by_name.values():
		if not AnimationData.__validate_anim(anim):
			invalid_animations.append(anim.anim_name)
		else:
			print(anim.anim_name + " is valid")

	if invalid_animations.size() > 0:
		print_.warn("Found %d invalid animations: %s" % [invalid_animations.size(), ", ".join(invalid_animations)])


func __enrich_with_end_start_times(anim: AnimationData):
	var native_anim = anim.native_anim

	var _start_time: float = 0.0
	var _end_time: float = native_anim.length
	var _duration = 0

	var _has_start_marker: bool = native_anim.has_marker(M.MarkerName.START)
	var _has_end_marker: bool = native_anim.has_marker(M.MarkerName.END)

	if anim.is_looping:
		# WARNING: The animation is always considered to run for its full length to loop correctly.
		#    - 'end' marker is ignored for looping _animations. 
		#    - 'start' marker does not influence the duration!
		if _has_start_marker:
			_start_time = native_anim.get_marker_time(M.MarkerName.START)
		_duration = native_anim.length
	else:
		if _has_start_marker:
			_start_time = native_anim.get_marker_time(M.MarkerName.START)
		if _has_end_marker:
			_end_time = native_anim.get_marker_time(M.MarkerName.END)
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
		
		var marker = M.Marker.new(marker_time, marker_name)
		markers_dict[marker_name] = marker
	
	return markers_dict
