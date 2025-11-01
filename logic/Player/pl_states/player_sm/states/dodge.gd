extends PlayerState


func check_transition(input_: InputPackage) -> PLVerdict:
	if not pm().safe_is_on_floor():
		return PLVerdict.new(PS.midair)
	
	if curr_state_action.passed_marker(Marker.Name_.TO_RUN):
		if not queued_state.is_set_to(PS.dodge):
			print_.psm_check_trans(state_name, pp.s("passed_marker TO_RUN => choosing best input"))
			var verdict := best_next_state_from_input(input_)
			return verdict
		else:
			print_.psm_check_trans(state_name, pp.s("passed_marker TO_RUN but we have another dodge queued => wait"))
			

	return PLVerdict.new("")


func on_enter_state(input_: InputPackage) -> void:
	pass
