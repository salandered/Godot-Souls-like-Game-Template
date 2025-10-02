extends LegsBehavior


const START_THRESHOLD := 0.25 # WARNING: have NO influence while playing with keyboard
const IDLE_COMMIT := 0.12 # seconds
const START_COMMIT := 0.2 # seconds

const STOP_RESUME_COMMIT := 0.1 # Can't resume immediately
const STOP_COMMIT := 0.15 # New: how long before can switch from stop


func choose_action(input: InputPackage, delta: float) -> LNextActionVerdict:
	var is_moving := input.input_direction.length() >= START_THRESHOLD
	var curr_action = legs_sm.current_action
	var curr_motion_type = legs_sm.current_action.motion_type
	var next_action_name = supported_actions.by_motion(curr_motion_type)

	match curr_motion_type:
		MotionType.IDLE:
			if is_moving and curr_action.works_longer_than(IDLE_COMMIT):
				next_action_name = supported_actions.by_motion(MotionType.START)
				__log_decision_data(is_moving, pp.compare_w("works >", "commit", IDLE_COMMIT), next_action_name)
	
		MotionType.START:
			if is_moving:
				if curr_action.time_remaining_for_smooth_switch(Leg.Act.sprint) < 0.05:
					next_action_name = supported_actions.by_motion(MotionType.LOOP)
					__log_decision_data(is_moving, "time for smooth sw < 0.05", next_action_name)
			else:
				if curr_action.works_longer_than(START_COMMIT):
					next_action_name = supported_actions.by_motion(MotionType.IDLE)
					__log_decision_data(is_moving, pp.compare_w("works >", "commit", START_COMMIT), next_action_name)
		
		MotionType.LOOP:
			if not is_moving:
				next_action_name = supported_actions.by_motion(MotionType.STOP)
				__log_decision_data(is_moving, "", next_action_name)

		MotionType.STOP:
			if is_moving:
				if curr_action.works_longer_than(STOP_RESUME_COMMIT):
					next_action_name = supported_actions.by_motion(MotionType.LOOP) ## could be START here
					__log_decision_data(is_moving, pp.compare_w("works >", "commit", STOP_RESUME_COMMIT), next_action_name)
			else:
				if curr_action.time_remaining() < 0.5: # curr_action.works_longer_than(STOP_COMMIT) and
					next_action_name = supported_actions.by_motion(MotionType.IDLE)
					__log_decision_data(is_moving, pp.compare_w("time_remaining >", "0.1", STOP_COMMIT), next_action_name)

	return LNextActionVerdict.new(next_action_name)


var _dev_test = 0.05
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("t1"):
		_dev_test -= 0.05

	if event.is_action_pressed("t2"):
		_dev_test += 0.05
