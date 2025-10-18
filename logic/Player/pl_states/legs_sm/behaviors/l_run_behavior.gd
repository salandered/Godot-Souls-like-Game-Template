extends LegsBehavior


const IDLE_COMMIT := 0.12 # seconds
const START_COMMIT := 0.92 # seconds

var TO_STOP_DELAY: float = 0.2
var ANGLE_FOR_U_TURN_MIN = 130.0
var _non_moving_timer: DelayTimer = DelayTimer.new()


func _ready():
	_non_moving_timer.initialise(TO_STOP_DELAY)


func choose_action(input_: InputPackage, delta: float) -> LNextActionVerdict:
	var curr_action = legs_sm.current_action
	var curr_motion_type = legs_sm.current_action.motion_type
	var next_action_name = supported_actions.convert_to_supported(curr_action)

	match curr_motion_type:
		MotionType.IDLE:
			next_action_name = _from_IDLE_decision(input_, delta, next_action_name)

		MotionType.START:
			next_action_name = _from_START_decision(input_, delta, next_action_name)


		MotionType.LOOP:
			next_action_name = _from_LOOP_decision(input_, delta, next_action_name)

				
		MotionType.STOP: # stop in run is idle currently
			pass

	return LNextActionVerdict.new(next_action_name)


func _from_IDLE_decision(input_: InputPackage, delta: float, next_action_name) -> String:
	var curr_action = legs_sm.current_action
	var angle_deg = get_abs_angle_pl_input_deg(input_, delta)

	if is_moving(input_) and curr_action.works_longer_than(IDLE_COMMIT):
		if angle_deg > ANGLE_FOR_U_TURN_MIN:
			next_action_name = supported_actions.by_name(Leg.Act.turn_180)
			__log_decision_data(input_, pp.compare(">", "angle_deg", angle_deg, "", ANGLE_FOR_U_TURN_MIN), next_action_name)
		

		else:
			next_action_name = supported_actions.default_by_motion(MotionType.START)
			__log_decision_data(input_, pp.compare("<", "angle_deg", angle_deg, "", ANGLE_FOR_U_TURN_MIN), next_action_name)
	
	return next_action_name


func _from_START_decision(input_: InputPackage, delta: float, next_action_name) -> String:
	var curr_action = legs_sm.current_action
	if is_moving(input_):
		match curr_action.action_name:
			Leg.Act.turn_180:
				if curr_action.time_remaining_for_smooth_switch(supported_actions.default_by_motion(MotionType.LOOP)) <= 0.0: # if curr_action.time_remaining() <= 0.3: # curr_action.time_remaining_for_smooth_switch(supported_actions.by_motion(MotionType.LOOP)) <= 0.0:
					next_action_name = supported_actions.default_by_motion(MotionType.LOOP)
					__log_decision_data(input_, "time for smooth sw < ", next_action_name)
	else:
		if curr_action.time_remaining() < 0.3:
			next_action_name = supported_actions.default_by_motion(MotionType.IDLE)
			__log_decision_data(input_, pp.compare_w("works >", "commit", START_COMMIT), next_action_name)

	return next_action_name


func _from_LOOP_decision(input_: InputPackage, delta: float, next_action_name) -> String:
	if is_pure_reverse_moving(input_): # and abs_angle_pl_input_greater_than(input_, delta, ANGLE_FOR_U_TURN_MIN):
		next_action_name = supported_actions.by_name(Leg.Act.turn_180)
		__log_decision_data(input_, "", next_action_name)
		_non_moving_timer.reset()

	elif is_moving(input_): # normally nothing to do but we reset a timer
		_non_moving_timer.reset()

	elif not is_moving(input_):
		if _non_moving_timer.update(delta): # not moving / reversing and we waited some time in such condition
			next_action_name = supported_actions.default_by_motion(MotionType.STOP)
			__log_decision_data(input_, "_non_moving_timer expired", next_action_name)
	
	return next_action_name


# func _input(event):
# 	_dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
# 	_next_anim_correction = u._dev_change_t34_param(event, _next_anim_correction, "_next_anim_correction", 0.02)
			# Check if we have valid turn intent
