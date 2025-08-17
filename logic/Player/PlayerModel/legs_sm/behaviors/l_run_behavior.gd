extends LegsBehavior

@export var input_threshold: float = 0.04 # stick deadzone
var to_walk_treshold: float = 0.5


## RunLegs behaviour is also a SM. It consists of idle and run (also can be start and end animations)

## `LegsBehavior` states have the type called `LegsActions`, and `legs_actions` are instantiated once and live in a shared pool instead of being a copy per behavior. 
## Firstly, this helps to combat pyramidization. Our SMs don't have any doubles in their states. I use `walk_stop` and `idle` in both `run_locomotion` cycle and in `walk_locomotion` cycle. 
## The only doubled logic is line, telling that idle is used here (and same in WalkLegs, for example)


func _ready() -> void:
	supported_actions = [
		LS.legs_action_idle,
		LS.legs_action_run,
	]

func update(input: InputPackage, delta: float):
	_choose_action(input)
	legs_sm.current_action.update(input, delta)


func _choose_action(input: InputPackage):
	if input.input_direction != Vector2.ZERO:
		switch_action_to(LS.legs_action_run, input)
	else:
		switch_action_to(LS.legs_action_idle, input)


func choose_initial_action(input: InputPackage):
	print_.prefix("LSM Beh INITIAL", "using idle choose_initial_action based on " + str(legs_sm.current_action.motion_type), 1)
	match legs_sm.current_action.motion_type:
		legs_sm.MotionType.IDLE:
			switch_action_to(LS.legs_action_idle, input)
			return
		legs_sm.MotionType.CYCLE:
			switch_action_to(LS.legs_action_run, input)
			return
