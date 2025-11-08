extends BasePlayerState


func check_transition(input_: InputPackage) -> PLVerdict:
	if not get_player().is_on_floor():
		return PLVerdict.new(PS.midair)

		
	if curr_state_action.time_remaining() <= 0.2:
		var verdict := best_next_state_from_input(input_)
		__log_psm_check("time_remaining < 0.0 => choosing best input")
		return verdict
			
	return PLVerdict.new("")
