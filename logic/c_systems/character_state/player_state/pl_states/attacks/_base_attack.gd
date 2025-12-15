extends BasePlayerState
class_name AttackState


func check_transition(input_: InputPackage) -> PLVerdict:
	if curr_state_action.passed_marker(MarkerName.ALLOWS_SWITCH):
	# this reads as: if we are at the end of attack anim (> ALLOWS_SWITCH but < DURATION)
	# and there is a best input which is not idle, we can switch to it. 
	# => we dont wait for the exact end of the current anim
		var verdict := best_next_state_from_input(input_)
		if verdict.next_state != PS.idle:
			__log_psm_check("passed marker", MarkerName.ALLOWS_SWITCH, "=> chose best non idle input")
			return verdict

	if curr_state_action.time_remaining() <= 0.1:
		var verdict := best_next_state_from_input(input_)
		__log_psm_check("time_remaining < 0.0 => choosing best input")
		return verdict
			
	return PLVerdict.new("")
