extends PlayerState


# func initialise() -> void:

	
func check_transition(input_: InputPackage) -> PLVerdict:
	if curr_state_action.passed_marker(Marker.Name.JUMP_START_END):
		__log_psm_check("passed_marker JUMP_START_END => midair")
		return PLVerdict.new(PS.midair)


	return PLVerdict.new("")
