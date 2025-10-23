extends LegsBehavior


const IDLE_COMMIT := 0.14 # seconds
var TO_STOP_DELAY: float = 0.16

var _non_moving_timer: DelayTimer = DelayTimer.new()


func _ready():
	_non_moving_timer.initialise(TO_STOP_DELAY)


func on_enter_behavior(input_: InputPackage):
	_non_moving_timer.reset()


func choose_action(input_: InputPackage, delta: float) -> LNextActionVerdict:
	var curr_action := get_curr_action()
	var curr_motion_type := curr_action.motion_type
	var next_action_name := supported_actions.convert_to_supported(curr_action)

	match curr_motion_type:
		MotionType.IDLE:
			if is_moving(input_) and curr_action.works_longer_than(IDLE_COMMIT):
				var decision := _decide_move_action(input_, delta)
				next_action_name = decision.name
				__log_decision_data(input_, decision.reason, next_action_name)


		MotionType.LOOP:
			next_action_name = _from_LOOP_decision(input_, delta, next_action_name)

		
		MotionType.STOP, MotionType.START:
			pass
	
	return LNextActionVerdict.new(next_action_name)


func _from_LOOP_decision(input_: InputPackage, delta: float, next_action_name) -> String:
	if is_moving(input_) or is_reverse_moving(input_):
		var decision := _decide_move_action(input_, delta)
		next_action_name = decision.name
		if next_action_name != get_curr_action().action_name:
			__log_decision_data(input_, decision.reason, next_action_name)
		_non_moving_timer.reset()
	
	elif not is_moving(input_):
		if _non_moving_timer.update(delta):
			next_action_name = supported_actions.default_by_motion(MotionType.STOP)
			__log_decision_data(input_, "", next_action_name)

	return next_action_name


func _decide_move_action(input_: InputPackage, delta: float) -> Dictionary:
	var next_action_name: String = supported_actions.by_name(Leg.Act.strafe)
	var reason: String = "All movement -> strafe (8-dir)"
	
	return {"name": next_action_name, "reason": reason}
