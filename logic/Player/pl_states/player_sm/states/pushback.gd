extends BasePlayerState


func check_transition(input_: InputPackage) -> PLVerdict:
	if not get_player().is_on_floor():
		return PLVerdict.new(PS.midair)

		
	if curr_state_action.passed_marker(MarkerName.ALLOWS_SWITCH):
		var verdict := best_next_state_from_input(input_)
		__log_psm_check("passed marker ALLOWS_SWITCH => choosing best input")
		return verdict
			
	return PLVerdict.new("")
