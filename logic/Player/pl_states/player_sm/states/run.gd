extends PlayerState


func check_transition(input: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		return PLVerdict.new(PS.midair)
	return best_next_state_from_input(input)
