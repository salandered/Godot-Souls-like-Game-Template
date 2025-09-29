@tool
@icon("res://-assets-/x_misc/x_icons/icon_grid.png")

extends AnimationContainer
class_name PlayerAnimationContainer

@onready var native_player: AnimationPlayer = %NativeAnimator


var _animations = [
	# loco
	AnimationData.new(A.combat_idle),
	AnimationData.new(A.combat_walk),
	AnimationData.new(A.combat_walk_start),
	AnimationData.new(A.combat_sprint_start),
	AnimationData.new(A.combat_walk_back),
	AnimationData.new(A.combat_run),
	AnimationData.new(A.combat_sprint),
	AnimationData.new(A.run_L),
	AnimationData.new(A.run_R),
	# loco jump
	AnimationData.new(A.midair),
	AnimationData.new(A.jump_run),
	AnimationData.new(A.jump_sprint),
	AnimationData.new(A.landing_run),
	AnimationData.new(A.landing_sprint),
	AnimationData.new(A.jump_idle),
	AnimationData.new(A.roll),
	#
	AnimationData.new(A.death),
	# fight
	AnimationData.new(A.longsword_1),
	AnimationData.new(A.longsword_2, 0, 0, 0, 0.85),
	AnimationData.new(A.withdraw),
	AnimationData.new(A.block_forward),
	AnimationData.new(A.block_reaction),
	AnimationData.new(A.hit_reaction),
	AnimationData.new(A.pushback),
	AnimationData.new(A.staggered),
	AnimationData.new(A.parry),
	AnimationData.new(A.parried),
	AnimationData.new(A.riposte_attack),
	AnimationData.new(A.shield_throw),
	AnimationData.new(A.shield_throw_reload),
	AnimationData.new(A.idle_longsword),
	#
	AnimationData.new(A.idle_longsword),
]

var _anim_by_name := {}


## MAIN INTERFACE
func get_by_name(anim_name: String) -> AnimationData:
	return u.safe_get_dict_key(_anim_by_name, anim_name, "")


func _accept_animations() -> void:
	for anim: AnimationData in _animations:
		# get native anim
		if not ua.assert_has_animation(native_player, anim.anim_name, false):
			continue
		var native_anim: Animation = native_player.get_animation(anim.anim_name)
		anim.native_anim = native_anim
		
		# is looping
		anim.is_looping = (native_anim.loop_mode == Animation.LOOP_LINEAR)

		# timings
		__enrich_with_end_start_times(anim)

		# all markers # todo: this can be used before __enrich_with_end_start_times
		var markers = __get_animation_markers(anim.native_anim)
		anim.markers = markers

		_anim_by_name[anim.anim_name] = anim

		if anim.anim_name == A.longsword_1:
			print("~~", anim._to_string())
	_anim_by_name[A.fake_anim] = AnimationData.new(A.fake_anim, 0, 1, 1)


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

	anim.start_time = _start_time
	anim.end_time = _end_time
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
