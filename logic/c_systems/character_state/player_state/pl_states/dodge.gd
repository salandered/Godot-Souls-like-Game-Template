extends BasePlayerState

var emitted_wave: bool = false

func check_transition(input_: InputPackage) -> PLVerdict:
	if curr_state_action.passed_marker(MarkerName.ALLOWS_SWITCH_TO_ATTACK):
		if queued_state.is_set_to(PS.attack_from_dodge):
			__log_psm_check("passed_marker ALLOWS_SWITCH_TO_ATTACK and 'attack_from_dodge' queued
				 => switch to it right now (will override switches_to_queue()")
			# or may be try set force state to make this less raw
			return PLVerdict.new(PS.attack_from_dodge)
	
	if curr_state_action.passed_marker(MarkerName.TO_RUN):
		# if not emitted_wave:
			# get_player().SIG_land_wave.emit(get_player().global_position, "explode")
			# emitted_wave = true
		if not queued_state.is_set_to(PS.dodge):
			__log_psm_check("passed_marker TO_RUN => choosing best input")
			var verdict := best_next_state_from_input(input_)
			return verdict
		else:
			__log_psm_check("passed_marker TO_RUN but we have another dodge queued => wait")
			

	return PLVerdict.new("")


func on_enter_state(input_: InputPackage) -> void:
	get_player().hit_box_torso.shrink_hitbox(0.8, 0.4)
	emitted_wave = false


func on_exit_state() -> void:
	get_player().hit_box_torso.restore_hitbox()
