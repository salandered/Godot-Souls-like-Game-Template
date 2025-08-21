extends LegsBehavior

var to_walk_treshold: float = 0.5


## RunLegs behaviour is also a SM. It consists of idle and run (also can be start and end animations)

## `LegsBehavior` states have the type called `LegsActions`, and `legs_actions` are instantiated once and live in a shared pool instead of being a copy per behavior. 
## Firstly, this helps to combat pyramidization. Our SMs don't have any doubles in their states. I use `walk_stop` and `idle` in both `run_locomotion` cycle and in `walk_locomotion` cycle. 
## The only doubled logic is line, telling that idle is used here (and same in WalkLegs, for example)

const IDLE_GRACE := 0.12 # seconds
var _idle_timer := 0.0

func _ready() -> void:
	supported_actions = [
		LS.legs_action_idle,
		LS.legs_action_run
		# LS.legs_action_sprint_to_run,
	]

func update(input: InputPackage, delta: float) -> void:
	_choose_action(input, delta)
	legs_sm.current_action.update(input, delta)


func _choose_action(input: InputPackage, delta: float) -> void:
	if input.input_direction != Vector2.ZERO:
		_idle_timer = 0.0
		# avoid redundant switches if your SM doesn't already guard
		switch_action_to(LS.legs_action_run, input)
	else:
		_idle_timer += delta
		if _idle_timer >= IDLE_GRACE:
			switch_action_to(LS.legs_action_idle, input)


func choose_initial_action(input: InputPackage) -> String:
	var initial_action: String
	if input.input_direction != Vector2.ZERO:
		initial_action = LS.legs_action_run
	else:
		initial_action = LS.legs_action_idle
	print_.prefix("LSM Beh INITIAL", "based on input vector -> " + initial_action, 1)
	return initial_action
	# TODO: how to choose_initial_action if we came from double behavior. lets say sprint was using double. 
	# or any loco state like sprint should be in legs now?
	# NOTE: also we can use input.actions! like in sptrint
	# print_.prefix("LSM Beh INITIAL", "using idle choose_initial_action based on " + str(legs_sm.current_action.motion_type), 1)
	# match legs_sm.current_action.motion_type:
	# 	legs_sm.MotionType.IDLE:
	# 		switch_action_to(LS.legs_action_idle, input)
	# 		return
	# 	legs_sm.MotionType.CYCLE:
	# 		switch_action_to(LS.legs_action_run, input)
	# 		return
