extends LegsAction


const POSITION_CUTOFF_TIME := 0.5375 # TODO: change to marker

var initial_rotation: Quaternion


var curr_turn: TurnData = TurnData.new()


func on_enter_action(_input: InputPackage) -> void:
	prints(u.fr(), "------- fast turn on enter")
	initial_rotation = player.quaternion
	prints("Initial rotation (quaternion)", initial_rotation)

	# TURN DATA
	var _target_angle = calculate_target_angle(_input)
	var _turn_dir = turn_direction_by_target_angle(_target_angle)
	curr_turn.initialise(_target_angle, _turn_dir)


func on_exit_action() -> void:
	prints(u.fr(), "------- fast turn on exit")
	var tranfer_turn_data = {}
	if not curr_turn.turn_completed:
		tranfer_turn_data["turn_data"] = curr_turn.to_dict()
		prints("\t Exit before complete. Will populate tranfer data")

	var _final_rm_speed = player.velocity.length()
	tranfer_turn_data["rm_speed"] = _final_rm_speed
	
	legs_sm.fill_tranfer_data(tranfer_turn_data)

	__log_turn_exit()


func update(input: InputPackage, delta: float):
	if not curr_turn.turn_completed:
		var rotation_delta = animator_manager.get_root_rotation()
		var result = apply_root_rotation(rotation_delta, curr_turn.target_angle, curr_turn.accum_rotation)
		curr_turn.update(result.completed, result.accum_rot)
			
	if time_spent() < POSITION_CUTOFF_TIME:
		var root_vel = animator_manager.get_root_velocity()
		player.velocity = initial_rotation * root_vel
	else:
		# not rotating is fine if turn animation has root rotation from the first frame to the last.
		move_with_input_vector(input, delta)


func animate(): # ▶️
	var blend_time := 0.2

	## TODO: some universal system for different "sub animations" in one action

	if curr_turn.turn_direction == "right":
		anim = anim_container.get_by_name(A.fast_turn_180_R)
	else:
		anim = anim_container.get_by_name(A.fast_turn_180_L)
	
	__log_anim(blend_time, 0.0)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, 0.0)


func __log_turn_exit():
	var _final_rotation = player.quaternion.angle_to(initial_rotation)
	var _error_angle = curr_turn.accum_rotation - curr_turn.target_angle
	prints("\t accum rotation", pp.rad2deg(curr_turn.accum_rotation), " fin rotation", pp.rad2deg(_final_rotation),
		" Target:", pp.rad2deg(curr_turn.target_angle), " Error:", pp.rad2deg(_error_angle))
