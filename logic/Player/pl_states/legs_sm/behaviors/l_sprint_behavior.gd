extends LegsBehavior


const START_THRESHOLD := 0.25 # WARNING: have NO influence while playing with keyboard
const IDLE_COMMITMENT := 0.12 # seconds
const RUN_START_COMMITMENT := 0.2 # seconds


func _ready() -> void:
	var supported = {
		MotionType.IDLE: Leg.Act.idle,
		MotionType.START: Leg.Act.idle_to_sprint,
		MotionType.LOOP: Leg.Act.sprint,
		MotionType.STOP: Leg.Act.sprint,
	}
	
	supported_actions = SupportedActions.new(supported)
		

func choose_action(input: InputPackage, delta: float) -> LNextActionVerdict:
	var is_moving := input.input_direction.length() >= START_THRESHOLD
	var curr_action = legs_sm.current_action
	var next_action = supported_actions.get_by_motion(curr_action.motion_type)

	match curr_action.motion_type:
		MotionType.IDLE:
			if is_moving and curr_action.progress() > IDLE_COMMITMENT:
				next_action = Leg.Act.idle_to_sprint
				print_.lsm_beh_ch(behavior_name, curr_action.motion_type, is_moving, pp.compare_w("prog >", "IDLE_COMMIT", IDLE_COMMITMENT), next_action)
	
		MotionType.START:
			if is_moving:
				if curr_action.time_remaining_for_smooth_switch(Leg.Act.sprint) < 0.05:
					next_action = Leg.Act.sprint
					print_.lsm_beh_ch(behavior_name, curr_action.motion_type, is_moving, "time for smooth sw < 0.05", next_action)
			else:
				if curr_action.progress() > RUN_START_COMMITMENT:
					next_action = Leg.Act.idle
					print_.lsm_beh_ch(behavior_name, curr_action.motion_type, is_moving, pp.compare_w("prog >", "RUN_START_COMMIT", RUN_START_COMMITMENT), next_action)
		MotionType.LOOP:
			if not is_moving:
				next_action = Leg.Act.idle
				print_.lsm_beh_ch(behavior_name, curr_action.motion_type, is_moving, "", next_action)

	return LNextActionVerdict.new(next_action)


var _dev_test = 0.05

func choose_initial_action(input: InputPackage) -> LNextActionVerdict:
	var curr_action = legs_sm.current_action
	var initial_action_name := ""
	
	initial_action_name = supported_actions.get_by_motion(curr_action.motion_type)
	# if curr_action.action_name == Leg.Act.run and curr_action.works_less_than(_dev_test):
		# initial_action_name = Leg.Act.idle_to_sprint
	print_.lsm_beh("INITIAL", pp.s("based on curr_act motion", curr_action.motion_type, "->", initial_action_name))
	return LNextActionVerdict.new(initial_action_name)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("t1"):
		_dev_test -= 0.05

	if event.is_action_pressed("t2"):
		_dev_test += 0.05
