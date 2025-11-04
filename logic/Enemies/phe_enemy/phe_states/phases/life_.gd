extends BasePHEComposite


func get_supported_substates() -> Array[String]:
	return [
			PHES.still_life_phase,
			PHES.combat_phase,
			PHES.death_phase,
		]


func is_ended() -> bool:
	return false


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	var _switch_on_same: bool = false
	var _override_commit: bool = false

	match current_substate.state_name:
		PHES.Leaf.death:
			# anti pattern, we dont do multiple returns in check_substate_transition 
			# but death is worth it
			return VerdictPH.new(_next_state, _reason)

		PHES.still_life_phase:
			if current_substate.is_ended():
				_reason = "still_life_phase is ended"
				_next_state = PHES.combat_phase
			else:
				_reason = "still_life_phase not ended"

		PHES.combat_phase:
			if phe_feelings.get_curr_health() < 1:
				_reason = "health < 1"
				_next_state = PHES.death_phase
		
		PHES.death_phase:
			pass

		_:
			__log_forgot_implement(current_substate.state_name, "check_substate_transition", "combat_phase")
			_next_state = PHES.combat_phase


	# NOTE: unique to life. Would be here for now
	#       Fallback is force switch to combat_phase
	if me.fatigue_raised:
		_reason += em.pin + "Declined: Some state raised 'fatigue_raised', we switch to " + _next_state
		_next_state = PHES.combat_phase
		_switch_on_same = true
		_override_commit = true
		me.fatigue_raised = false

	return VerdictPH.new(_next_state, _reason, _switch_on_same, _override_commit)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = PHES.still_life_phase
	_reason = "initial life_ state"
	return VerdictPH.new(_next_state, _reason)
