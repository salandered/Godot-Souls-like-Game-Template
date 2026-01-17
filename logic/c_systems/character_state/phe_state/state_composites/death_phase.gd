extends BasePHEComposite


func get_supported_substates() -> Array[String]:
	return [
			PHES.Leaf.death,
		]


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	match current_substate.state_name:
		PHES.Leaf.death:
			if current_substate.is_ended():
				if __ELA(): __log_upd("death animation at its end")

	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = PHES.Leaf.death
	if __ELA(): _reason += "only death"
	return VerdictPH.new(_next_state, _reason)
