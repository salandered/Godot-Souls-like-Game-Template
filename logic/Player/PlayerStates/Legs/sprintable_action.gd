extends LegsBehaviorOld

## SprintBehavior

func transition_legs_state(input, _delta):
	var target_state: String

	if input.input_direction:
		if input.actions.has("sprint"):
			target_state = "sprint"
		else:
			target_state = "run"
	else:
		target_state = "idle"
	
	if target_state != current_legs_state.state_name:
		change_state(target_state)
