extends LegsBehavior


## RunLegs behaviour is also a SM. It consists of idle and run (also can be start and end animations)

## `LegsBehavior` states manages `LegsActions`, and legs actions are instantiated once and live in a shared pool 
##  instead of being a copy per behavior. 
## => Our SMs don't have duplicates in their states. 
##    We can use `walk_stop` and `idle` in both `run_locomotion` and  `walk_locomotion` cycles. 
##    Duplicated is a line telling that idle is used here in supported_actions


const START_THRESHOLD := 0.25 # tweak
const IDLE_COMMIT := 0.12 # seconds
const START_COMMIT := 0.92 # seconds

	
func choose_action(input: InputPackage, delta: float) -> LNextActionVerdict:
	var is_moving := input.input_direction.length() >= START_THRESHOLD
	var curr_action = legs_sm.current_action
	var curr_motion_type = legs_sm.current_action.motion_type
	var next_action_name = supported_actions.by_motion(curr_motion_type)

	match curr_motion_type:
		MotionType.IDLE:
			if is_moving and curr_action.works_longer_than(IDLE_COMMIT):
				# var target_direction = player.model.player_sm.__velocity_by_input(input, delta).normalized()
				# var angle_to_target = player.basis.z.signed_angle_to(target_direction, Vector3.UP)
				# var turn_direction = sign(angle_to_target)
				# if is_zero_approx(turn_direction): # If input is straight back
					# turn_direction = 1.0 # Default to a left turn for perfect 180s
				# legs_sm.transfer_data.fill("turn_decision", {"direction": turn_direction})
					# 
				next_action_name = supported_actions.by_motion(MotionType.START)
				__log_decision_data(is_moving, pp.compare_w("works >", "commit", IDLE_COMMIT), next_action_name)
	
	
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
			if not is_moving:
				next_action_name = supported_actions.by_motion(MotionType.STOP)
				__log_decision_data(is_moving, "", next_action_name)

	return LNextActionVerdict.new(next_action_name)


# func _input(event):
# 	_dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
# 	_next_anim_correction = u._dev_change_t34_param(event, _next_anim_correction, "_next_anim_correction", 0.02)
