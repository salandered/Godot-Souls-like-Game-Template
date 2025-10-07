extends LegsBehavior


const START_THRESHOLD := 0.25 # tweak
const IDLE_COMMIT := 0.12 # seconds
const START_COMMIT := 0.92 # seconds

var stop_delay: float = 0.1
var _stop_timer: DelayTimer = DelayTimer.new()


func _ready():
	_stop_timer.initialise(stop_delay)


func choose_action(input: InputPackage, delta: float) -> LNextActionVerdict:
	var is_moving := input.input_direction.length() >= START_THRESHOLD
	var curr_action = legs_sm.current_action
	var curr_motion_type = legs_sm.current_action.motion_type
	var next_action_name = supported_actions.by_motion(curr_motion_type)

	match curr_motion_type:
		MotionType.IDLE:
			if is_moving and curr_action.works_longer_than(IDLE_COMMIT):
				var angle = player.model.__angle_between_player_and_input(input, delta)
				if abs(angle) > deg_to_rad(130.0):
					next_action_name = supported_actions.by_motion(MotionType.START)
					__log_decision_data(is_moving, "Angle > 150 deg", next_action_name)
				else:
					next_action_name = supported_actions.by_motion(MotionType.LOOP)
					__log_decision_data(is_moving, "Angle <= 150 deg", next_action_name)
	
	
		MotionType.START:
			if is_moving:
				if curr_action.time_remaining() <= 0.3: # curr_action.time_remaining_for_smooth_switch(supported_actions.by_motion(MotionType.LOOP)) <= 0.0:
					next_action_name = supported_actions.by_motion(MotionType.LOOP)
					__log_decision_data(is_moving, "time for smooth sw < 0.05", next_action_name)
			else:
				if curr_action.time_remaining() < 0.3:
					next_action_name = supported_actions.by_motion(MotionType.IDLE)
					__log_decision_data(is_moving, pp.compare_w("works >", "commit", START_COMMIT), next_action_name)
		

		MotionType.LOOP:
			if is_moving:
				if input.reverse_data.is_reversed:
					next_action_name = supported_actions.by_motion(MotionType.START) # TURN
					__log_decision_data(is_moving, "Reversing: %s" % input.reverse_data, next_action_name)
			
				_stop_timer.reset()
			else:
				if input.reverse_data.is_reversed:
					next_action_name = supported_actions.by_motion(MotionType.START) # TURN
					__log_decision_data(is_moving, "Reversing: %s" % input.reverse_data, next_action_name)
				else:
					# Normal stop logic when not moving and not reversing
					if _stop_timer.update(delta):
						next_action_name = supported_actions.by_motion(MotionType.STOP)
						__log_decision_data(is_moving, "_stop_timer expired", next_action_name)

	return LNextActionVerdict.new(next_action_name)


# func _input(event):
# 	_dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
# 	_next_anim_correction = u._dev_change_t34_param(event, _next_anim_correction, "_next_anim_correction", 0.02)
			# Check if we have valid turn intent
