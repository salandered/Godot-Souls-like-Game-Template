extends PlayerState


func check_transition(input_: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		PLVerdict.new("midair")
	
	return best_next_state_from_input(input_)
