extends BasePlayerState


func initialize() -> void:
	APPLY_GRAVITY = false

func check_transition(input_: InputPackage) -> PLVerdict:
	if curr_state_action.passed_marker(MarkerName.JUMP.RUN_AGAIN):
		__log_time_spent()
		if area_awareness.is_almost_on_floor():
			__log_psm_check("passed RUN_AGAIN and is_on_floor => best_next_state")
			var _verdict := best_next_state_from_input(input_)
			if _verdict.next_state in [PS.run, PS.idle]:
				return PLVerdict.new(PS.sprint)
			else:
				return _verdict
		elif area_awareness.floor_dist_under_landing_height():
			if pm().is_actively_falling():
				__log_psm_check("passed RUN_AGAIN but NOT on_floor BUT close and falling => lets wait ...")
				return PLVerdict.new("")
			else:
				__log_psm_check("passed RUN_AGAIN; NOT on_floor; not falling => hard midair and possible problem", em.warn)
				return PLVerdict.new(PS.midair)
		else:
			__log_psm_check("passed RUN_AGAIN but NOT on_floor AND not even close => midair")
			return PLVerdict.new(PS.midair)
	else:
		return PLVerdict.new("")
