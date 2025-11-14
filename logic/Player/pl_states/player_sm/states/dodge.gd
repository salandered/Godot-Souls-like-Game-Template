extends BasePlayerState


func check_transition(input_: InputPackage) -> PLVerdict:
	if curr_state_action.passed_marker(MarkerName.ALLOWS_SWITCH_TO_ATTACK):
		if queued_state.is_set_to(PS.attack_from_dodge):
			__log_psm_check("passed_marker ALLOWS_SWITCH_TO_ATTACK and 'attack_from_dodge' queued
				 => switch to it right now (will override switches_to_queue()")
			# or may be try set force state to make this less raw
			return PLVerdict.new(PS.attack_from_dodge)
	
	if curr_state_action.passed_marker(MarkerName.TO_RUN):
		if not queued_state.is_set_to(PS.dodge):
			__log_psm_check("passed_marker TO_RUN => choosing best input")
			var verdict := best_next_state_from_input(input_)
			return verdict
		else:
			__log_psm_check("passed_marker TO_RUN but we have another dodge queued => wait")
			

	return PLVerdict.new("")


func on_enter_state(input_: InputPackage) -> void:
	pass
