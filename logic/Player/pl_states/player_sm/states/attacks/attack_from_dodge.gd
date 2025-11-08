extends AttackState


## overrides
func check_transition(input_: InputPackage) -> PLVerdict:
	if not get_player().is_on_floor():
		return PLVerdict.new(PS.midair)

	
	if curr_state_action.passed_marker(MarkerName.ALLOWS_SWITCH):
		var verdict := best_next_state_from_input(input_)
		if verdict.next_state != PS.idle:
			__log_psm_check("passed marker ALLOWS_SWITCH => chose best non idle input")
			return verdict

	if curr_state_action.passed_marker(MarkerName.TO_IDLE):
		var verdict := best_next_state_from_input(input_)
		__log_psm_check("passed_marker TO_IDLE => best_next_state")
		return verdict

	if curr_state_action.time_remaining() <= 0.0:
		var verdict := best_next_state_from_input(input_)
		__log_psm_check("time_remaining < 0.0 => choosing best input")
		return verdict
	
	return PLVerdict.new("")
