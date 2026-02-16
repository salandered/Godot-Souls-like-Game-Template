extends BasePlayerState


func on_enter_state(input_: InputPackage):
	APPLY_GRAVITY = false

	var hit := combat.get_last_processed_hit()
	if hit.anim_id != SITSKA.sit_attack:
		SigUtils.safe_emit_raw_no_payload(PlayerStats.SIG_thrown)


func check_transition(input_: InputPackage) -> PLVerdict:
	if curr_state_action.passed_marker(MarkerName.JUMP.LAND_START):
		APPLY_GRAVITY = true

	# 
	if curr_state_action.passed_marker(MarkerName.TO_RUN):
		var verdict := best_next_state_from_input(input_)
		__log_psm_check("passed_marker TO_RUN => choosing best input")
		return verdict

	
	elif curr_state_action.time_remaining() <= 0.1:
		var verdict := best_next_state_from_input(input_)
		__log_psm_check("time_remaining < 0.0 => choosing best input")
		return verdict


	return PLVerdict.new("")
