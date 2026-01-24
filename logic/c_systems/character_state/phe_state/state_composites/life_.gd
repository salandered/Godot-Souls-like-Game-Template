extends BasePHEComposite


func get_supported_substates() -> Array[String]:
	return [
			PHES.still_life_phase,
			PHES.combat_phase,
			PHES.death_phase,
			PHES.Leaf.midair
		]


func is_ended() -> bool:
	return false


func _check_started_falling(current_substate: BasePHEState) -> bool:
	if me.get_area_awareness().is_on_floor():
		return false
	if me.get_area_awareness().is_almost_on_floor():
		return false
	if not current_substate.is_apply_gravity():
		return false
	if current_substate.state_name == PHES.death_phase:
		return false
	if current_substate.state_name == PHES.still_life_phase:
		return false
	if current_substate.state_name == PHES.Leaf.midair:
		return false
	return true


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	## NOTE: _external_events are unique to life. Thats why here we don't immediately use match current_substate.state_name
	var _external_events: bool = false
	var _switch_on_same: bool = false
	var _override_commit: bool = false


	var is_started_falling: bool = _check_started_falling(current_substate)
	if is_started_falling:
		if __ELA(): _reason += "Floor lost (falling)"
		_next_state = PHES.Leaf.midair
		_override_commit = true
		_external_events = true


	# Would be here for now
	#       WL is force switch to combat_phase
	elif me.fatigue_raised:
		if __ELA(): _reason += em.pin + "Declined: Some state raised 'fatigue_raised', we switch to " + _next_state
		_next_state = PHES.combat_phase
		_switch_on_same = true
		_override_commit = true
		me.fatigue_raised = false
		_external_events = true


	if not _external_events:
		match current_substate.state_name:
			PHES.still_life_phase:
				if current_substate.is_ended():
					if __ELA(): _reason += "still_life_phase is ended"
					_next_state = PHES.combat_phase
				else:
					if __ELA(): _reason += "still_life_phase not ended"

			PHES.combat_phase:
				if phe_feelings.is_zero_health():
					if __ELA(): _reason += "health < 1"
					_next_state = PHES.death_phase
			
			PHES.death_phase:
				pass

			PHES.Leaf.midair:
				if current_substate.is_ended():
					if __ELA(): _reason += "landed"
					_next_state = PHES.combat_phase
			_:
				__log_forgot_implement(current_substate.state_name, "check_substate_transition", "combat_phase")
				_next_state = PHES.combat_phase


	return VerdictPH.new(_next_state, _reason, _switch_on_same, _override_commit)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = PHES.still_life_phase
	if __ELA(): _reason += "initial life_ state"
	return VerdictPH.new(_next_state, _reason)
