extends LegsBehavior

var to_walk_treshold: float = 0.5

## RunLegs behaviour is also a SM. It consists of idle and run (also can be start and end animations)

## `LegsBehavior` states have the type called `LegsActions`, and `legs_actions` are instantiated once and live in a shared pool instead of being a copy per behavior. 
## Firstly, this helps to combat pyramidization. Our SMs don't have any doubles in their states. I use `walk_stop` and `idle` in both `run_locomotion` cycle and in `walk_locomotion` cycle. 
## The only doubled logic is line, telling that idle is used here (and same in WalkLegs, for example)


func _ready() -> void:
	used_actions = [
		PS.legs_action_idle,
		PS.legs_action_run,
	]

func update(input: InputPackage, delta: float):
	_choose_action(input)
	legs_sm.current_action.update(input, delta)


func _choose_action(input: InputPackage):
	if input.actions.has(PS.run):
		switch_action_to(PS.legs_action_run, input)
	else:
		switch_action_to(PS.legs_action_idle, input)


func on_enter_behavior(input: InputPackage):
	## If it so happens that the previous behavior used one of our states, 
	## we don't bother switching it and instead work directly from here, analysing the next input. 
	if not used_actions.has(legs_sm.current_action.action_name):
		_choose_initial_action(input)

func _choose_initial_action(input: InputPackage):
	match legs_sm.current_action.motion_type:
		legs_sm.MotionType.IDLE:
			switch_action_to(PS.legs_action_run, input)
			return
		legs_sm.MotionType.CYCLE:
			switch_action_to(PS.legs_action_run, input)
			return
