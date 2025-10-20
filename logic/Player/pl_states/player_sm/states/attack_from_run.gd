extends AttackState


## overrides 
func check_transition(input_: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		return PLVerdict.new(PS.midair)

	var verdict = best_next_state_from_input(input_)
	
	if curr_state_action.passed_marker(Marker.Name.ALLOWS_SWITCH):
		if verdict.next_state != PS.idle:
			print_.psm_check_trans(state_name, pp.s("passed marker ALLOWS_SWITCH => chose best non idle input"))
			return verdict

	if curr_state_action.passed_marker(Marker.Name.TO_IDLE):
		print_.psm_check_trans(state_name, pp.s("passed_marker TO_IDLE => best_next_state"))
		return verdict
	
	return PLVerdict.new("")
