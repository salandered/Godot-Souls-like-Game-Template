extends PlayerState

## we have a main state called run, and it uses the legs behavior called run_legs. 

## in container set for run state legs_behavior = RunLegs Node

func update(input: InputPackage, delta: float):
	current_action.update(input, delta)


func transition_logic(input: InputPackage) -> String:
	if not player.is_on_floor():
		return "midair"
	return best_input_that_can_be_paid(input)
