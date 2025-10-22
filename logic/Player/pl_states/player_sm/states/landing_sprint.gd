# landing_run.gd - running landing
extends PlayerState


func check_transition(input_: InputPackage) -> PLVerdict:
	if curr_state_action.passed_marker(Marker.Name.RUN_AGAIN):
		__log_psm_check("passed_marker RUN_AGAIN => run")
		__log_psm_check("state was running for ", time_spent())
		__log_psm_check("action was running for ", curr_state_action.time_spent())
		return PLVerdict.new(PS.run)
	
	return PLVerdict.new("")
