extends LegsBehavior


## RunLegs behaviour is also a SM. It consists of idle and run (also can be start and end animations)

## `LegsBehavior` states manages `LegsActions`, and legs actions are instantiated once and live in a shared pool 
##  instead of being a copy per behavior. 
## => Our SMs don't have duplicates in their states. 
##    We can use `walk_stop` and `idle` in both `run_locomotion` and  `walk_locomotion` cycles. 
##    Duplicated is a line telling that idle is used here in supported_actions


const START_THRESHOLD := 0.25 # tweak
const IDLE_COMMITMENT := 0.12 # seconds
const RUN_START_COMMITMENT := 0.2 # seconds


func _ready() -> void:
	var supported = {
		MotionType.IDLE: Leg.Act.idle,
		MotionType.START: Leg.Act.run,
		MotionType.LOOP: Leg.Act.run,
		MotionType.STOP: Leg.Act.run,
	}
	
	supported_actions = SupportedActions.new(supported)
		

func choose_action(input: InputPackage, delta: float) -> LNextActionVerdict:
	var is_moving := input.input_direction.length() >= START_THRESHOLD
	var curr_action = legs_sm.current_action
	var next_action = supported_actions.get_by_motion(curr_action.motion_type)

	match curr_action.motion_type:
		MotionType.IDLE:
			if is_moving and curr_action.progress() > IDLE_COMMITMENT:
				next_action = Leg.Act.run
				print_.lsm_beh_ch(behavior_name, curr_action.motion_type, is_moving, pp.compare_w("prog >", "IDLE_COMMIT", IDLE_COMMITMENT), next_action)
	
		# MotionType.START:
		# 	if is_moving:
		# 		if current_action.DURATION / current_action.SPEED_SCALE - current_action.get_progress() < 0.1: # tweak may be
		# 			switch_action_to(Leg.Act.legs_action_run, input)
		# 			return
		# 	else:
		# 		if current_action.get_progress() > RUN_START_COMMITMENT:
		# 			switch_action_to(Leg.Act.legs_action_idle, input) # run end later
		MotionType.LOOP:
			if not is_moving:
				next_action = Leg.Act.idle
				print_.lsm_beh_ch(behavior_name, curr_action.motion_type, is_moving, "", next_action)
	
	return LNextActionVerdict.new(next_action)


func choose_initial_action(input: InputPackage) -> LNextActionVerdict:
	var curr_action = legs_sm.current_action
	var initial_action_name := ""
	
	initial_action_name = supported_actions.get_by_motion(curr_action.motion_type)
	print_.lsm_beh("INITIAL", pp.s("based on curr_act motion", curr_action.motion_type, "->", initial_action_name))
	return LNextActionVerdict.new(initial_action_name)
