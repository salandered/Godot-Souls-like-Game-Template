extends BasePlayerState

var emitted_wave: bool = false

func check_transition(input_: InputPackage) -> PLVerdict:
	if curr_state_action.passed_marker(MarkerName.ALLOWS_SWITCH_TO_ATTACK):
		if queued_state.is_set_to(PS.stab_attack_2):
			__log_psm_check("passed_marker ALLOWS_SWITCH_TO_ATTACK and 'stab_attack_2' queued
				 => switch to it right now (will override switches_to_queue()")
			# or may be try set force state to make this less raw
			return PLVerdict.new(PS.stab_attack_2)
	
	if curr_state_action.passed_marker(MarkerName.TO_RUN):
		# if not emitted_wave:
			# get_player().SIG_land_wave.emit(get_player().global_position, AirWave2.AnimID.big_explode)
			# emitted_wave = true
		if not queued_state.is_set_to(PS.dodge):
			__log_psm_check("passed_marker TO_RUN => choosing best input")
			var verdict := best_next_state_from_input(input_)
			return verdict
		else:
			__log_psm_check("passed_marker TO_RUN but we have another dodge queued => wait")
			

	return PLVerdict.new("")
