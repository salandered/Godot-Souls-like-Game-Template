extends BasePlayerState
class_name AttackState


func check_transition(input_: InputPackage) -> PLVerdict:
	if not get_player().is_on_floor():
		return PLVerdict.new(PS.midair)

		
	if curr_state_action.passed_marker(Marker.Name_.ALLOWS_SWITCH):
	# this reads as: if we are at the end of attack anim (> ALLOWS_SWITCH but < DURATION)
	# and there is a best input which is not idle, we can switch to it. 
	# => we dont wait for the exact end of the current anim
		var verdict := best_next_state_from_input(input_)
		if verdict.next_state != PS.idle:
			print_.psm_check_trans(state_name, pp.s("passed marker", Marker.Name_.ALLOWS_SWITCH, "=> chose best non idle input"))
			return verdict

	if curr_state_action.time_remaining() <= 0.1:
		var verdict := best_next_state_from_input(input_)
		print_.psm_check_trans(state_name, pp.s("time_remaining < 0.0 => choosing best input"))
		return verdict
			
	return PLVerdict.new("")
