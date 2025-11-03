extends BasePHEComposite


func get_supported_substates() -> Array[String]:
	return [
			PHEState.Leaf.death,
		]


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	match current_substate.state_name:
		PHEState.Leaf.death:
			if current_substate.is_ended():
				__log_upd("We died")
				# me.queue_free()

	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = PHEState.Leaf.death
	_reason = "only death"
	return VerdictPH.new(_next_state, _reason)
