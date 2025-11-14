extends BasePlayerState


func initialise() -> void:
	APPLY_GRAVITY = false


func check_transition(input_: InputPackage) -> PLVerdict:
	if curr_state_action.passed_marker(MarkerName.JUMP_START_END):
		if area_awareness.floor_dist_under_extreme_landing_height():
			__log_psm_check("passed_marker JUMP_START_END and floor_dist_under_extreme_landing_height", "=> landing_sprint")
			return PLVerdict.new(PS.landing_sprint)
		
		__log_psm_check("passed_marker JUMP_START_END but floor_dist > _extreme_height", "=> midair")
		return PLVerdict.new(PS.midair)

	return PLVerdict.new("")
