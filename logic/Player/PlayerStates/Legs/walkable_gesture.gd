extends LegsBehaviorOld


func transition_legs_state(input, _delta):
	var target_state: String

	if input.input_direction:
		target_state = "walk"
	else:
		target_state = "idle"
	
	if target_state != current_legs_state.state_name:
		change_state(target_state)
