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
	supported_actions = [
		LS.legs_action_idle,
		LS.legs_action_run_start,
		LS.legs_action_run,
	]

func update(input: InputPackage, delta: float) -> void:
	_choose_action(input, delta)
	legs_sm.current_action.update(input, delta)


func _choose_action(input: InputPackage, delta: float) -> void:
	var is_moving := input.input_direction.length() >= START_THRESHOLD
	var current_action = legs_sm.current_action

	if current_action.action_name == LS.legs_action_idle:
		if is_moving and current_action.get_progress() > IDLE_COMMITMENT:
			# switch_action_to(LS.legs_action_run_start, input)
			switch_action_to(LS.legs_action_run, input)
			return
	
	if current_action.action_name == LS.legs_action_run_start:
		if is_moving:
			if current_action.DURATION / current_action.SPEED_SCALE - current_action.get_progress() < 0.1: # tweak may be
				switch_action_to(LS.legs_action_run, input)
				return
		else:
			if current_action.get_progress() > RUN_START_COMMITMENT:
				switch_action_to(LS.legs_action_idle, input) # run end later

	if current_action.action_name == LS.legs_action_run:
		if not is_moving:
			switch_action_to(LS.legs_action_idle, input) # run end later
	
	# region: first version
	# if input.input_direction != Vector2.ZERO:
	# 	_idle_timer = 0.0
	# 	switch_action_to(LS.legs_action_run, input)
	# else:
	# 	_idle_timer += delta
	# 	if _idle_timer >= IDLE_COMMITMENT:
	# 		switch_action_to(LS.legs_action_idle, input)
	# endregion


func choose_initial_action(input: InputPackage) -> String:
	var initial_action: String
	if input.input_direction != Vector2.ZERO:
		initial_action = LS.legs_action_run
	else:
		initial_action = LS.legs_action_idle
	print_.lsm_beh(" INITIAL", "based on input vector -> " + initial_action, 2)
	return initial_action
	
	# NOTE Quesion: how to choose_initial_action if we came from double behavior. lets say sprint was using double. 
	# or any loco state like sprint should be in legs now? Well i think yes
	# NOTE: also we can use input.actions. like in sprint. but should we
	
	# [another approach]
	# print_.lsm_beh(" INITIAL", "using idle choose_initial_action based on " + str(legs_sm.current_action.motion_type), 1)
	# match legs_sm.current_action.motion_type:
	# 	legs_sm.MotionType.IDLE:
	# 		switch_action_to(LS.legs_action_idle, input)
	# 		return
	# 	legs_sm.MotionType.CYCLE:
	# 		switch_action_to(LS.legs_action_run, input)
	# 		return
