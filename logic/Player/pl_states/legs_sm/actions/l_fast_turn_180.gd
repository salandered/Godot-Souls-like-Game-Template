extends LegsAction


var initial_rotation: Quaternion

var curr_turn: TurnData = TurnData.new()

var FAST_TURN_180_APEX_TIME: float

func on_enter_action(input_: InputPackage) -> void:
	initial_rotation = get_player().quaternion
	prints("Initial rotation (quaternion)", initial_rotation)

	# TURN DATA
	var _target_angle = calculate_target_angle(input_)
	var _turn_dir = turn_direction_by_target_angle(_target_angle)
	curr_turn.initialise(_target_angle, _turn_dir)

	# APEX
	FAST_TURN_180_APEX_TIME = anim.get_marker_time_by_name(Marker.Name.TURN_180_APEX, Constants.BIG_MEANINGLESS_NUMBER)

func on_exit_action() -> void:
	var tranfer_turn_data = {}
	tranfer_turn_data["turn_data"] = curr_turn.to_dict()
	tranfer_turn_data["rm_speed"] = get_player().velocity.length()
	
	legs_sm.fill_tranfer_data(tranfer_turn_data)

	__log_turn_exit()


func update(input_: InputPackage, delta: float):
	if not curr_turn.turn_completed:
		var rotation_delta = animator_manager.get_root_rotation()
		var result = pm().apply_root_rotation(rotation_delta, curr_turn.target_angle, curr_turn.accum_rotation)
		curr_turn.update(result.completed, result.accum_rot)
			
	if time_spent() < FAST_TURN_180_APEX_TIME:
		var root_vel = animator_manager.get_root_velocity()
		get_player().velocity = initial_rotation * root_vel
	else:
		pm().move_with_input_vector(input_, delta)


func animate(): # ▶️
	var blend_time := 0.2

	if curr_turn.is_turn_dir_right():
		anim = anim_container.get_by_name(A.move.fast_turn_180_R)
	else:
		anim = anim_container.get_by_name(A.move.fast_turn_180_L)

	__log_anim(blend_time)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time)


func __log_turn_exit():
	var _final_rotation = get_player().quaternion.angle_to(initial_rotation)
	var _error_angle = curr_turn.accum_rotation - curr_turn.target_angle
	prints("\t accum rotation", pp.rad2deg(curr_turn.accum_rotation), " fin rotation", pp.rad2deg(_final_rotation),
		" Target:", pp.rad2deg(curr_turn.target_angle), " Error:", pp.rad2deg(_error_angle))
