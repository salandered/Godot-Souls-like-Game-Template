@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_grid.png")

extends BaseAnimationContainer
## for simplicity this container is used for all characters
##      in the future _animations may be unique per character, 
## 		while _accept_animations will be separated to a single logic piece
class_name AnimationContainer


var _animations = [
	## loco
	AnimationData.new(A.move.idle),
	AnimationData.new(A.move.idle_to_sprint),
	AnimationData.new(A.move.sprint_to_idle, 0.85),
	AnimationData.new(A.move.run),
	AnimationData.new(A.move.sprint),
	AnimationData.new(A.move.turn_180_R, 1.0, true),
	AnimationData.new(A.move.turn_180_L, 1.0, true),
	AnimationData.new(A.move.fast_turn_180_R, 1.0, true),
	AnimationData.new(A.move.fast_turn_180_L, 1.0, true),
	# loco strafe
	# AnimationData.new(A.combat_walk_f, 1.1),
	# AnimationData.new(A.combat_walk_b, 1.1),
	AnimationData.new(A.strafe.combat_run_f, 1.0),
	AnimationData.new(A.strafe.combat_run_b, 1.0),
	AnimationData.new(A.strafe.strafe_R, 0.8),
	AnimationData.new(A.strafe.strafe_L, 0.8),

	# loco dodge
	AnimationData.new(A.dodge.dodge_R),
	AnimationData.new(A.dodge.dodge_L),
	AnimationData.new(A.dodge.dodge_F),
	AnimationData.new(A.dodge.dodge_B),

	# loco jump
	AnimationData.new(A.air.midair),
	AnimationData.new(A.air.small_jump_run),
	AnimationData.new(A.air.jump_sprint),
	AnimationData.new(A.air.landing_sprint),
	AnimationData.new(A.air.jump_idle),
	AnimationData.new(A.roll),
	#
	AnimationData.new(A.death),

	## fight
	# fight attacks
	AnimationData.new(A.attack.axe_slice_1),
	AnimationData.new(A.attack.axe_slice_2, 0.85),
	# 
	AnimationData.new(A.combat.hit_reaction),
	AnimationData.new(A.combat.staggered),
	AnimationData.new(A.combat.parry),
	AnimationData.new(A.combat.parried),
	AnimationData.new(A.combat.riposte_attack),
	AnimationData.new(A.combat.idle_longsword),
]

var _anim_by_name := {}


## MAIN INTERFACE
func get_by_name(anim_name: String) -> AnimationData:
	return u.safe_get_dict_key(_anim_by_name, anim_name, "AnimationContainer.get_by_name")

## native_player - player's player, se's player, etc
func _accept_animations(native_player: AnimationPlayer) -> void:
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
		var markers = __get_animation_markers(anim.native_anim)
		anim._markers = markers

		_anim_by_name[anim.anim_id] = anim


	# TODO: for double action. It should not play it at all
	_anim_by_name[A.fake_anim] = _anim_by_name[A.air.midair]


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

	var _has_start_marker: bool = native_anim.has_marker(Marker.Name.START)
	var _has_end_marker: bool = native_anim.has_marker(Marker.Name.END)

	if anim.is_looping:
		# WARNING: The animation is always considered to run for its full length to loop correctly.
		#    - 'end' marker is ignored for looping _animations. 
		#    - 'start' marker does not influence the duration!
		if _has_start_marker:
			_start_time = native_anim.get_marker_time(Marker.Name.START)
		_duration = native_anim.length
	else:
		if _has_start_marker:
			_start_time = native_anim.get_marker_time(Marker.Name.START)
		if _has_end_marker:
			_end_time = native_anim.get_marker_time(Marker.Name.END)
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
		
		var marker = Marker.new(marker_time, marker_name)
		markers_dict[marker_name] = marker
	
	return markers_dict
