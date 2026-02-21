extends BasePHEComposite


func get_supported_substates() -> Array[StringName]:
	return [PHES.life]


func is_ended() -> bool:
	return false


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: StringName, _reason: String) -> VerdictPH:
	if __ELA(): _reason = PHES.life + " is never being transitioned"
	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: StringName, _reason: String) -> VerdictPH:
	_next_state = PHES.life
	if __ELA(): _reason = _next_state + " is only internal state" + " (from top state)"
	return VerdictPH.new(_next_state, _reason)
