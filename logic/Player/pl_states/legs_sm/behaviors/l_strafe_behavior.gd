extends LegsBehavior

const ANGLE_FOR_FORWARD_WALK = 45.0 - 5
const ANGLE_FOR_BACKWARD_WALK = 135.0 + 5
const IDLE_COMMIT := 0.12 # seconds
var TO_STOP_DELAY: float = 0.2

var _non_moving_timer: DelayTimer = DelayTimer.new()

func _ready():
	_non_moving_timer.initialise(TO_STOP_DELAY)


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
	var action_name: String
	var reason: String

	if input.reverse_data.is_reversed:
		reason = "Reversal detected"
		
		if input.reverse_data.is_reversed_strafe(): # A-D
			action_name = supported_actions.default_by_motion(MotionType.LOOP) # strafe
			reason += " (Horizontal) => Strafe"
		else: # W-S
			action_name = supported_actions.by_name(Leg.Act.combat_walk_forward)
			reason += " (Vertical) => Forward"

	else:
		var angle_deg = get_abs_angle_pl_input_deg(input, delta)
		if angle_deg < ANGLE_FOR_FORWARD_WALK:
			action_name = supported_actions.by_name(Leg.Act.combat_walk_forward)
			reason = "Angle %s < %s" % [pp.round_01(angle_deg), ANGLE_FOR_FORWARD_WALK]
		elif angle_deg > ANGLE_FOR_BACKWARD_WALK:
			action_name = supported_actions.by_name(Leg.Act.combat_walk_back)
			reason = "Angle %s > %s" % [pp.round_01(angle_deg), ANGLE_FOR_BACKWARD_WALK]
		else:
			action_name = supported_actions.default_by_motion(MotionType.LOOP) # strafe
			reason = "%s <= %s <= %s" % [ANGLE_FOR_FORWARD_WALK, pp.round_01(angle_deg), ANGLE_FOR_BACKWARD_WALK]

	return {"name": action_name, "reason": reason}
