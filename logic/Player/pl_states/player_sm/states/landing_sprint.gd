# landing_run.gd - running landing
extends BasePlayerState


func check_transition(input_: InputPackage) -> PLVerdict:
	if curr_state_action.passed_marker(MarkerName.RUN_AGAIN):
		__log_time_spent()
		if pm().safe_is_on_floor():
			__log_psm_check("passed_marker RUN_AGAIN and is_on_floor => best_next_state")
			var _verdict = best_next_state_from_input(input_)
			if _verdict.next_state in [PS.run, PS.idle]:
				return PLVerdict.new(PS.sprint)
			else:
				return _verdict
		elif area_awareness.floor_dist_under_landing_height():
			__log_psm_check("passed_marker RUN_AGAIN but NOT on_floor BUT close => lets wait :(")
			return PLVerdict.new("")
		else:
			__log_psm_check("passed_marker RUN_AGAIN but NOT on_floor AND not even close => midair")
			return PLVerdict.new(PS.midair)
	else:
		return PLVerdict.new("")
