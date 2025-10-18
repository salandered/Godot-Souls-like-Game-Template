extends LegsBehavior

const IDLE_COMMIT := 0.12 # seconds
var TO_STOP_DELAY: float = 0.2

var _non_moving_timer: DelayTimer = DelayTimer.new()


# func _ready():
# 	_non_moving_timer.initialise(TO_STOP_DELAY)
	

# func choose_action(input_: InputPackage, delta: float) -> LNextActionVerdict:
# 	var curr_action = legs_sm.current_action
# 	var curr_motion_type = curr_action.motion_type
# 	var next_action_name = supported_actions.by_name(Leg.Act.dodge)

# 	# match curr_motion_type:
# 	# 	MotionType.IDLE:
# 	# 		if is_moving(input_) and curr_action.works_longer_than(IDLE_COMMIT):
# 	# 			next_action_name = supported_actions.by_name(Leg.Act.dodge)
# 	# 			__log_decision_data(input_, "works > idle_commit", next_action_name)
			
# 	# 	MotionType.LOOP: # LOOP is dodge
# 	# 		if curr_action.time_remaining() <= 0.0:
# 	# 			next_action_name = supported_actions.default_by_motion(MotionType.IDLE)
# 	# 			__log_decision_data(input_, "time_remaining <= 0", next_action_name)
# 	# 		else:
# 	# 			pass

# 	# 	MotionType.STOP, MotionType.START:
# 	# 		__log_decision_data(input_, "mt pass", next_action_name)
				
# 	return LNextActionVerdict.new(next_action_name)
