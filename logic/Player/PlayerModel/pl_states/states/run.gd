extends PlayerState

## we have a main state called run, and it uses the legs behavior called run_legs. 

## in container set for run state legs_behavior = RunLegs Node


func on_enter_state(input: InputPackage):
	# i think should be here
	switch_action_to(PS.action_run, input)


func update(input: InputPackage, delta: float):
	_choose_action(input)
	current_action.update(input, delta)

func _choose_action(input: InputPackage):
	if current_action.action_name != legs_sm.current_action.action_name:
		print_.prefix("RUN STATE", "switching action from " + current_action.action_name + " to " + legs_sm.current_action.action_name)
		switch_action_to(legs_sm.current_action.action_name, input)

func transition_logic(input: InputPackage) -> String:
	return best_input_that_can_be_paid(input)
