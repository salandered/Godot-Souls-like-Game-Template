extends BaseLegsTurn


func initialise() -> void:
	super.initialise()
	INCREASE_ROTATION = 1.1

	# APEX
	TURN_180_APEX_TIME = anim.get_marker_time_by_name(MarkerName.TURN_180_APEX, Constants.BIG_MEANINGLESS_NUMBER)

	blend_time.set_by_prev_action({
		Leg.Act.sprint_to_idle: 0.4,
	})


func on_enter_action(input_: InputPackage) -> void:
	initial_rotation = get_player().quaternion
	__log_ent("Initial rotation (quaternion)", initial_rotation)

	# TURN DATA
	var _target_angle := calculate_target_angle_by_input(input_)
	var _turn_dir := turn_direction_by_target_angle(_target_angle)
	curr_turn.initialise(_target_angle, _turn_dir)


	

func update(input_: InputPackage, delta: float):
	if not curr_turn.turn_completed:
		var rotation_delta := get_animator_manager().get_root_rotation()
		var result := pm().apply_root_rotation(rotation_delta * INCREASE_ROTATION, curr_turn.target_angle, curr_turn.accum_rotation)
		curr_turn.update(result.completed, result.accum_rot)
			
	if time_spent() < TURN_180_APEX_TIME:
		var root_vel := get_animator_manager().get_root_velocity()
		pm().set_velocity(initial_rotation * root_vel)
	else:
		pm().move_with_input_vector(input_, delta)


func animate(): # ▶️
	if curr_turn.is_turn_dir_right():
		anim = anim_container.get_by_anim_id(A.loco.fast_turn_180_R)
	else:
		anim = anim_container.get_by_anim_id(A.loco.fast_turn_180_L)

	set_anim_to_play()
