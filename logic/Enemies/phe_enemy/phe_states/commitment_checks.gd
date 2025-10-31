extends RefCounted
class_name CommitCheck


const COMMIT_TIME_FALLBACK := 0.2


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

	if _check_for_non_loop_anim(state):
		return true

	if state.works_less_than(state.commitment):
		return true
		
	return false


## returns true if works_less_than
static func _check_for_non_loop_anim(state: BasePHELeaf) -> bool:
	if state.anim.is_looping:
		return false
		
	var _marker_exists := state.anim.does_marker_exist(Marker.Name_.COMMIT)
	
	if _marker_exists:
		if state.before_marker(Marker.Name_.COMMIT):
			__log_non_loop(true, "before marker " + Marker.Name_.COMMIT, state)
			return true
		else:
			__log_non_loop(false, "after marker " + Marker.Name_.COMMIT, state)
			return false
	else:
		if state.time_remaining() < COMMIT_TIME_FALLBACK:
			__log_non_loop(true, pp.s("time remaining <", COMMIT_TIME_FALLBACK, ), state)
			return true
		else:
			__log_non_loop(false, pp.s("time remaining >=", COMMIT_TIME_FALLBACK), state)
			return false


static func __log_non_loop(result: bool, reason: String, state: BasePHELeaf):
	var _msg := "commit check (non-loop):"
	var _result_msg := "works < commit" if result else "works > commit"
	if result == true:
		state.__log_phe_check(_msg, reason, "->", _result_msg)