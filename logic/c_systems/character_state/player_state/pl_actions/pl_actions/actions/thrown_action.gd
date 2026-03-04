extends PlayerAction


@export var flying_x_curve: Curve # bell-curve which ends a little earlier


var curr_throw_pack: ThrowData.Pack

var speed_x_interpolator := HillInterpolator.new()

var _boost_value := 0.0


func initialize() -> void:
	default_sp.ANGULAR_SPEED = 0.1
	start_time_offset.set_specific(anim.get_marker_time_by_name(MarkerName.FROM_RUN, 0.0))


func _locked_and_not_sprint() -> bool:
	# TODO: use actual angle between pl and enemy
	if pm().get_area_awareness().is_camera_locked(): # and not PREV_ACTION == Leg.Act.sprint:
		return true
	return false


func _decide_on_pack_on_enter():
	var _reason: String = ""
	curr_throw_pack = ThrowData.default_pack
	var hit := player_sm.combat.get_last_processed_hit()
	if not hit:
		_reason = "no hit data found => default"
		__log_decide_on_pack(_reason)
		return
		 

	var r_throw_dir := ThrowData.attack_dir_to_throw_dir(hit.attack_dir)
	if not _locked_and_not_sprint():
		r_throw_dir = ThrowData.throw_dir_mirror(r_throw_dir)

	var r_collection: ThrowData.DirCollection = ThrowData.usual_dir_col

	if hit.damage < 25:
		_reason += "hit.damage < 25"
		r_collection = ThrowData.low_dir_col
	
	if PREV_ACTION in [PS.Act.dodge, PS.Act.jump_sprint, PS.Act.landing_sprint, PS.Act.midair] or ra.chance(0.15):
		_reason += "PREV_ACTION is air action"
		r_collection = ThrowData.cool_dir_col

	if hit.anim_id == SITSKA.sit_attack:
		_boost_value = 1.0
		r_throw_dir = ThrowData.ThrowDir.BACK
	else:
		_boost_value = 0.0


	_reason += "r_throw_dir is " + str(r_throw_dir)
	var pack := r_collection.get_pack_by_throw_dir(r_throw_dir)

	curr_throw_pack = pack

	__log_decide_on_pack(_reason)


func _calculate_interpolator_duration(actual_anim: AnimationData) -> float:
	var _start := actual_anim.get_marker_time_by_name(MarkerName.FROM_RUN, 0.0)
	var _end := actual_anim.get_marker_time_by_name(MarkerName.JUMP.LAND_START, 1.0)
	var _dur := (_end - _start) / anim.speed_scale + 0.1 # + 0.1 to be safe
	__log_ent("calculated _interpolator_dur", _dur, "using markers with time", _start, _end)
	return _dur


func on_enter_action(input_: InputPackage):
	_decide_on_pack_on_enter()
	# curr_throw_pack = back_low_throw_pack # DEV WARNING
	anim = anim_container.get_by_anim_id(curr_throw_pack.anim_id)
	start_time_offset.set_specific(anim.get_marker_time_by_name(MarkerName.FROM_RUN, 0.0))

	var _inherited_speed := pm().get_curr_velocity_len()
	var _interpolator_dur := _calculate_interpolator_duration(anim)
	
	speed_x_interpolator.initialize(
		_inherited_speed + curr_throw_pack.extra_start_speed + _boost_value / 2,
		curr_throw_pack.end_speed + _boost_value / 2,
		curr_throw_pack.peak_speed + _boost_value * 2,
		flying_x_curve,
		_interpolator_dur)


func on_exit_action():
	speed_x_interpolator.reset()


func update(input_: InputPackage, delta: float) -> void:
	if pm().get_area_awareness().is_camera_locked() and PREV_ACTION != Leg.Act.sprint:
		pm().look_at_target(delta)
	if before_marker(MarkerName.JUMP.LAND_START):
		var current_speed := speed_x_interpolator.update(delta)
		# __log_upd(speed_x_interpolator._get_progress(), current_speed)
		
		var _curr_world_vector := _get_current_world_vector(get_player().basis)
		pm().set_velocity(_curr_world_vector * current_speed)
	else:
		# If LAND_START placed where root naturally stops, it will play well
		pm().move_with_root(delta)
		# __log_upd(get_player().velocity)

	# later
	# if tracks_input_vector():
		# pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))


func _get_current_world_vector(player_basis: Basis) -> Vector3:
	match curr_throw_pack.direction:
		ThrowData.ThrowDir.RIGHT:
			return -player_basis.x
		ThrowData.ThrowDir.LEFT:
			return player_basis.x
		ThrowData.ThrowDir.BACK:
			return -player_basis.z
	return Vector3.ZERO


func __log_decide_on_pack(_reason: String):
	__log_ent(_reason, "-> set curr pack", curr_throw_pack)
