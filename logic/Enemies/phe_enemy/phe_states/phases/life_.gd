extends BasePHEComposite


func get_supported_substates() -> Array[String]:
	return [
			PHEState.still_life_phase,
			PHEState.combat_phase,
			PHEState.death_phase,
		]


func is_ended() -> bool:
	return false


func update(delta: float) -> void:
	## CHANGE STYLE: for now just a bunch of cheap ways to stick with angry
	if phe_feelings.health < phe_feelings.max_health * PHEStaticConfig.PHASE_SWITCH_HP_TRESHOLD:
		me.angry_raised = true


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	var _switch_on_same: bool = false
	var _override_commit: bool = false

	match current_substate.state_name:
		PHEState.Leaf.death:
			# anti pattern, we dont do multiple returns in check_substate_transition 
			# but death is worth it
			return VerdictPH.new(_next_state, _reason)

		PHEState.still_life_phase:
			if current_substate.is_ended():
				_reason = "still_life_phase is ended"
				_next_state = PHEState.combat_phase
			else:
				_reason = "still_life_phase not ended"

		PHEState.combat_phase:
			if phe_feelings.health < 1:
				_reason = "health < 1"
				_next_state = PHEState.death_phase

		_:
			__log_forgot_implement(current_substate.state_name, "check_substate_transition", "combat_phase")
			_next_state = PHEState.combat_phase


	# NOTE: unique to life. Would be here for now
	#       Fallback is force switch to combat_phase
	if me.fatigue_raised:
		_reason += em.pin + "Declined: Some state raised 'fatigue_raised', we switch to " + _next_state
		_next_state = PHEState.combat_phase
		_switch_on_same = true
		_override_commit = true
		me.fatigue_raised = false

	return VerdictPH.new(_next_state, _reason, _switch_on_same, _override_commit)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = PHEState.still_life_phase
	_reason = "initial life_ state"
	return VerdictPH.new(_next_state, _reason)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("t2"):
		me.angry_raised = not me.angry_raised
		print("!!!", me.angry_raised, me.angry_raised)
