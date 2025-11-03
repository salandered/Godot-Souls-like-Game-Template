extends LegsAction

# @export var accel_from_apex_curve: Curve


var initial_rotation: Quaternion

# var speed_curve_from_apex = EaseCurveInterpolator.new()

# var curr_turn: TurnData = TurnData.new()

# var INCREASE_ROTATION: float = 1.0


# var ROOT_OK = 1.2994

# func on_enter_action(input_: InputPackage) -> void:
# 	initial_rotation = get_player().quaternion
# 	prints("Initial rotation (quaternion)", initial_rotation)
	
# 	# TURN DATA
# 	var _target_angle = calculate_target_angle(input_)
# 	var _turn_dir = turn_direction_by_target_angle(_target_angle)
# 	curr_turn.initialise(_target_angle, _turn_dir)

# 	# SPEED CONFIG
# 	# speed_curve_from_apex.initialise(accel_from_apex_curve, 0.3)

# func on_exit_action() -> void:
# 	var tranfer_turn_data = {}
# 	tranfer_turn_data["turn_data"] = curr_turn.to_dict()
# 	tranfer_turn_data["rm_speed"] = get_player().velocity.length()
	
# 	legs_sm.fill_tranfer_data(tranfer_turn_data)

# 	# speed_curve_from_apex.reset()

# 	__log_turn_exit()


# func update(input_: InputPackage, delta: float):
# 	var SPEED_MULT = 1.0
# 	if not curr_turn.turn_completed:
# 		var rotation_delta = animator_manager.get_root_rotation()
# 		var result = apply_root_rotation(rotation_delta * INCREASE_ROTATION, curr_turn.target_angle, curr_turn.accum_rotation)
# 		curr_turn.update(result.completed, result.accum_rot)
			
# 	if time_spent() < anim.get_marker_time_by_name(Marker.Name.GIVE_UP_RM):
# 		var root_vel = animator_manager.get_root_velocity()
# 		get_player().velocity = initial_rotation * root_vel
# 		prints("~~b4", time_spent(), SPEED_MULT, get_player().velocity.length())
# 	else:
# 		# SPEED_MULT = speed_curve_from_apex.update(delta)
# 		prints("~~90~~~ time, eff time, sp mult pl.vel.len", time_spent(), effective_time_spent(), SPEED_MULT, get_player().velocity.length())
# 		move_with_input_vector(input_, delta, SpeedConfig.new(default_sp, SPEED_MULT))


# func animate(): # ▶️
# 	var blend_time := 0.2
# 	var start_time_offset := 0.4
# 	## TODO: some universal system for different "sub animations" in one action
# 	if curr_turn.is_turn_dir_right:
# 		anim = anim_container.get_by_name(A.turn_90_to_run_R)
# 	else:
# 		anim = anim_container.get_by_name(A.turn_90_to_run_L)
	
# 	__log_anim(blend_time, start_time_offset)
# 	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_time_offset)


# func __log_turn_exit():
# 	var _final_rotation = get_player().quaternion.angle_to(initial_rotation)
# 	var _error_angle = curr_turn.accum_rotation - curr_turn.target_angle
# 	prints("\t accum rotation", pp.rad2deg(curr_turn.accum_rotation), " fin rotation", pp.rad2deg(_final_rotation),
# 		" Target:", pp.rad2deg(curr_turn.target_angle), " Error:", pp.rad2deg(_error_angle))


## run beh would be 

			# Leg.Act.turn_90_to_run:
			# 	if curr_action.effective_time_spent() >= curr_action.anim.get_marker_time_by_name(Marker.Name.TURN_COMPLETE, 0.5):
			# 		next_action_name = supported_actions.default_by_motion(MotionType.LOOP)
			# 		__log_decision_data(input_, "effective_time_spent > TURN_90_TO_RUN_COMPLETE", next_action_name)

## 

		# elif abs_angle_pl_input_greater_between(input_, delta, ANGLE_FOR_90_TURN_MIN, ANGLE_FOR_90_TURN_MAX):
		# 	next_action_name = supported_actions.by_name(Leg.Act.turn_90_to_run)
		# 	__log_decision_data(input_, pp.s("Angle between", ANGLE_FOR_90_TURN_MIN, ANGLE_FOR_90_TURN_MAX), next_action_name)
