extends LegsBehavior


const START_THRESHOLD := 0.25 # tweak
const IDLE_COMMITMENT := 0.12 # seconds
const RUN_START_COMMITMENT := 0.2 # seconds


func _ready() -> void:
	supported_actions = [
		LS.legs_action_idle,
		LS.legs_action_run_start,
		LS.legs_action_sprint,
	]

func update(input: InputPackage, delta: float) -> void:
	_choose_action(input, delta)
	legs_sm.current_action.update(input, delta)

func _choose_action(input: InputPackage, delta: float) -> void:
	var is_moving := input.input_direction.length() >= START_THRESHOLD
	var current_action = legs_sm.current_action

	if current_action.action_name == LS.legs_action_idle:
		if is_moving and current_action.get_progress() > IDLE_COMMITMENT:
			switch_action_to(LS.legs_action_run_start, input)
			return
	
	if current_action.action_name == LS.legs_action_run_start:
		if is_moving:
			if current_action.DURATION / current_action.SPEED_SCALE - current_action.get_progress() < 0.08: # tweak may be
				switch_action_to(LS.legs_action_sprint, input)
				return
		else:
			if current_action.get_progress() > RUN_START_COMMITMENT:
				switch_action_to(LS.legs_action_idle, input) # run end later

	if current_action.action_name == LS.legs_action_sprint:
		if not is_moving:
			switch_action_to(LS.legs_action_idle, input) # run end later

func choose_initial_action(input: InputPackage) -> String:
	var initial_action: String
	if input.input_direction != Vector2.ZERO:
		initial_action = LS.legs_action_sprint
	else:
		initial_action = LS.legs_action_idle
	print_.lsm_beh("INITIAL", "based on input vector -> " + initial_action, 2)
	return initial_action