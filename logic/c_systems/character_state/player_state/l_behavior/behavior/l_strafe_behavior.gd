extends LegsBehavior


const IDLE_COMMIT := 0.14 # seconds
var TO_STOP_DELAY: float = 0.16

var _non_moving_timer: SimpleTimer = SimpleTimer.new()
var ANGLE_FOR_U_TURN_MIN := 110.0

func _ready() -> void:
	_non_moving_timer.initialise(TO_STOP_DELAY)


func on_enter_behavior(input_: InputPackage):
	_non_moving_timer.reset()


func choose_action(input_: InputPackage, delta: float) -> LNextActionVerdict:
	var curr_action := get_curr_action()
	var curr_action_name := get_curr_action().action_name
	var prev_action_name := get_prev_action().action_name
	var curr_motion_type := curr_action.motion_type
	var next_action_name := supported_actions.convert_to_supported(curr_action)

	match curr_motion_type:
		MotionType.IDLE:
			next_action_name = _from_IDLE_decision(input_, delta, next_action_name)
			

		MotionType.LOOP:
			next_action_name = _from_LOOP_decision(input_, delta, next_action_name)
		
		MotionType.START:
			next_action_name = _from_START_decision(input_, delta, next_action_name)
		
		MotionType.STOP:
			pass
	
	return LNextActionVerdict.new(next_action_name)


func _from_IDLE_decision(input_: InputPackage, delta: float, next_action_name: String) -> String:
	var curr_action := get_curr_action()
	
	var angle_deg := rad_to_deg(absf(pm().get_signed_angle_pl_target()))

	if is_moving(input_) and curr_action.works_longer_than(IDLE_COMMIT):
		if angle_deg > ANGLE_FOR_U_TURN_MIN:
			next_action_name = supported_actions.by_name(Leg.Act.turn_180)
			if __ELA(): __log_decision_data(input_, next_action_name, "angle_deg", angle_deg, ">", "", ANGLE_FOR_U_TURN_MIN)
	
		elif is_moving(input_) and curr_action.works_longer_than(IDLE_COMMIT):
			next_action_name = supported_actions.by_name(Leg.Act.strafe)
			if __ELA(): __log_decision_data(input_, next_action_name, "All movement -> strafe (8-dir)")


	return next_action_name

func _from_START_decision(input_: InputPackage, delta: float, next_action_name: String) -> String:
	var curr_action := get_curr_action()
	if is_moving(input_):
		match curr_action.action_name:
			Leg.Act.turn_180:
				if curr_action.time_remaining_for_smooth_switch(supported_actions.default_by_motion(MotionType.LOOP)) <= 0.0:
					next_action_name = supported_actions.default_by_motion(MotionType.LOOP)
					if __ELA(): __log_decision_data(input_, next_action_name, "time for smooth sw < ")
	elif not is_moving(input_):
		if _non_moving_timer.update(delta):
			next_action_name = supported_actions.default_by_motion(MotionType.STOP)
			if __ELA(): __log_decision_data(input_, next_action_name, "")

	return next_action_name


func _from_LOOP_decision(input_: InputPackage, delta: float, next_action_name: String) -> String:
	if is_moving(input_) or is_reverse_moving(input_):
		next_action_name = supported_actions.by_name(Leg.Act.strafe)
		if next_action_name != get_curr_action().action_name:
			if __ELA(): __log_decision_data(input_, next_action_name, "All movement -> strafe (8-dir)")
		_non_moving_timer.reset()
	
	elif not is_moving(input_):
		if _non_moving_timer.update(delta):
			next_action_name = supported_actions.default_by_motion(MotionType.STOP)
			if __ELA(): __log_decision_data(input_, next_action_name, "")

	return next_action_name
