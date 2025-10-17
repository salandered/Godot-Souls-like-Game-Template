extends LegsBehavior


const IDLE_COMMIT := 0.12 # seconds
var TO_STOP_DELAY: float = 0.2
var TO_FORWARD_BACK_DELAY: float = 0.15
var TO_STRAFE_DELAY: float = 0.15

var _non_moving_timer: DelayTimer = DelayTimer.new()
var _to_strafe_timer: DelayTimer = DelayTimer.new()
var _to_vert_move_timer: DelayTimer = DelayTimer.new()

func _ready():
	_non_moving_timer.initialise(TO_STOP_DELAY)
	_to_strafe_timer.initialise(TO_STRAFE_DELAY)
	_to_vert_move_timer.initialise(TO_FORWARD_BACK_DELAY)


func choose_action(input: InputPackage, delta: float) -> LNextActionVerdict:
	var curr_action = legs_sm.current_action
	var curr_motion_type = curr_action.motion_type
	var next_action_name = supported_actions.convert_to_supported(curr_action)

	match curr_motion_type:
		MotionType.IDLE:
			if is_moving(input) and curr_action.works_longer_than(IDLE_COMMIT):
				var decision = _decide_move_action(input, delta)
				next_action_name = decision.name
				__log_decision_data(input, decision.reason, next_action_name)


		MotionType.LOOP:
			next_action_name = _from_LOOP_decision(input, delta, next_action_name)

		
		MotionType.STOP, MotionType.START:
			pass
	
	return LNextActionVerdict.new(next_action_name)


func _from_LOOP_decision(input: InputPackage, delta: float, next_action_name) -> String:
	if is_moving(input) or is_reverse_moving(input):
		var decision = _decide_move_action(input, delta)
		next_action_name = decision.name
		if next_action_name != legs_sm.current_action.action_name:
			__log_decision_data(input, decision.reason, next_action_name)
		_non_moving_timer.reset()
	
	elif not is_moving(input):
		if _non_moving_timer.update(delta):
			next_action_name = supported_actions.default_by_motion(MotionType.STOP)
			__log_decision_data(input, "", next_action_name)

	return next_action_name


func _decide_move_action(input: InputPackage, delta: float) -> Dictionary:
	var next_action_name: String
	var reason: String = ""

	if is_reverse_moving(input):
		reason = "Reversal detected"
		
		if input.reverse_data.is_reversed_strafe(): # A-D
			next_action_name = supported_actions.by_name(Leg.Act.strafe)
			reason += " (Horizontal) => Strafe"
		else: # W-S
			next_action_name = supported_actions.by_name(Leg.Act.vert_locked_run)
			reason += " (Vertical) => Combat Walk"

	else:
		var input_vec = input.input_direction

		if abs(input_vec.y) > abs(input_vec.x):
			# Vertical dominant - combat walk
			next_action_name = supported_actions.by_name(Leg.Act.vert_locked_run)
			reason = "Input: Combat Walk (vertical dominant)"
		else:
			# Horizontal dominant - strafe
			next_action_name = supported_actions.by_name(Leg.Act.strafe)
			reason = "Input: Strafe (horizontal dominant)"
	
	# TIMERS
	if next_action_name == supported_actions.by_name(Leg.Act.strafe):
		if not _to_strafe_timer.update(delta):
			reason += pp.s("\n\t\t\t", next_action_name, em.gray_x, "UPD declined: timer. Would be current")
			next_action_name = legs_sm.current_action.action_name
		else:
			_to_strafe_timer.reset()
			_to_vert_move_timer.reset()

	if next_action_name == supported_actions.by_name(Leg.Act.vert_locked_run):
		if not _to_vert_move_timer.update(delta):
			reason += pp.s("\n\t\t\t", next_action_name, em.gray_x, "UPD declined: timer. Would be current")
			next_action_name = legs_sm.current_action.action_name
		else:
			_to_vert_move_timer.reset()
			_to_strafe_timer.reset()

		## first vesion with angles
		# const ANGLE_FOR_FORWARD_WALK = 45.0 - 5
		# const ANGLE_FOR_BACKWARD_WALK = 135.0 + 5
		# var angle_deg = get_abs_angle_pl_input_deg(input, delta)
		# if angle_deg < ANGLE_FOR_FORWARD_WALK:
		# 	action_name = supported_actions.by_name(Leg.Act.combat_walk_forward)
		# 	reason = "Angle %s < %s" % [pp.round_01(angle_deg), ANGLE_FOR_FORWARD_WALK]
		# elif angle_deg > ANGLE_FOR_BACKWARD_WALK:
		# 	action_name = supported_actions.by_name(Leg.Act.combat_walk_back)
		# 	reason = "Angle %s > %s" % [pp.round_01(angle_deg), ANGLE_FOR_BACKWARD_WALK]
		# else:
		# 	action_name = supported_actions.default_by_motion(MotionType.LOOP) # strafe
		# 	reason = "%s <= %s <= %s" % [ANGLE_FOR_FORWARD_WALK, pp.round_01(angle_deg), ANGLE_FOR_BACKWARD_WALK]

	return {"name": next_action_name, "reason": reason}
