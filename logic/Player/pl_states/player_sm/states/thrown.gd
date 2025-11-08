extends BasePlayerState


func check_transition(input_: InputPackage) -> PLVerdict:
	if not get_player().is_on_floor():
		return PLVerdict.new(PS.midair)

	
	if curr_state_action.passed_marker(MarkerName.TO_RUN):
		var verdict := best_next_state_from_input(input_)
		__log_psm_check("passed_marker TO_RUN => choosing best input")
		return verdict

	
	elif curr_state_action.time_remaining() <= 0.1:
		var verdict := best_next_state_from_input(input_)
		__log_psm_check("time_remaining < 0.0 => choosing best input")
		return verdict


	return PLVerdict.new("")
