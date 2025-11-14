extends BasePlayerState


func check_transition(input_: InputPackage) -> PLVerdict:
	return best_next_state_from_input(input_)
