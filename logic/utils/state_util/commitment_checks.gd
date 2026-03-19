extends RefCounted
class_name CommitCheck


const MIN_TIME_REMAINING := 0.2


static func works_longer_than_fatigue(state: BasePHEComposite) -> bool:
	if state.fatigue == -1:
		return false
	if state.works_longer_than(state.fatigue):
		return true
	return false

static func works_less_than_commitment(state: BasePHEComposite) -> bool:
	if state.commitment == -1:
		return false
	if state.works_less_than(state.commitment):
		return true
	return false


static func works_longer_than_fatigue_leaf(state: BasePHELeaf) -> bool:
	if state.fatigue == -1:
		return false
	if state.works_longer_than(state.fatigue):
		return true
	return false


static func works_less_than_commitment_leaf(state: BasePHELeaf) -> bool:
	if state.commitment == -1:
		return false

	if not state.anim.is_looping:
		return not _is_commitment_done_for_non_loop_anim(state)

	if state.works_less_than(state.commitment):
		return true
		
	return false


static func _is_commitment_done_for_non_loop_anim(state: BasePHELeaf) -> bool:
	var _result: bool = false
	var _reason: String = ""

	var _allows_switch_marker_name := MarkerName.ALLOWS_SWITCH

	var _allows_switch_marker_exists := state.anim.does_marker_exist(_allows_switch_marker_name)


	if _allows_switch_marker_exists:
		# -0.1 means 0.1 before the marker is ok
		if state.passed_marker(_allows_switch_marker_name, -0.15):
			if state.__LOG_B(): _reason = "passed_marker" + _allows_switch_marker_name
			_result = true
		else:
			if state.__LOG_B(): _reason = "not passed_marker " + _allows_switch_marker_name
			_result = false

	## no marker, then check time remaining
	else:
		if state.time_remaining() < MIN_TIME_REMAINING:
			if state.__LOG_B(): _reason = pp.s("time remaining <", MIN_TIME_REMAINING)
			_result = true
		else:
			if state.__LOG_B(): _reason = pp.s("time remaining >=", MIN_TIME_REMAINING)
			_result = false

	if state.__LOG_B(): __log_non_loop(_result, _reason, state)
	return _result


static func __log_non_loop(result: bool, reason: String, state: BasePHELeaf):
	var _msg := "commit check (non-loop):"
	var _result_msg := "works < commit" if result else "works > commit"
	if result == true:
		state.__log_phe(_msg, reason, "->", _result_msg)
