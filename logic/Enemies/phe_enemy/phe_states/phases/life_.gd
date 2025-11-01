extends BasePHEComposite


var loco_for = PHEHelpers.WillDoFor.new(3, 9, PHEState.combat_loco)

func get_supported_substates() -> Array[String]:
	return [
			PHEState.still_life_phase,
			PHEState.combat_loco,
			PHEState.combat_attacking,
			PHEState.Leaf.death,
		]


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	## STATE MATCH
	match current_substate.state_name:
		PHEState.Leaf.death:
			# anti pattern, we dont do multiple returns in check_substate_transition 
			# but death is worth it
			return VerdictPH.new(_next_state, _reason)

		PHEState.still_life_phase:
			if current_substate.is_ended():
				_reason = "still_life_phase is ended"
				_next_state = PHEState.combat_loco
			else:
				_reason = "still_life_phase not ended"

		PHEState.combat_loco:
			if dist_to_player_less(PHEConfig.COMBAT_RAD): # and ra.chance(0.5):
				_reason = "dist-to-pl < COMBAT_RAD"
				_next_state = PHEState.combat_attacking
			elif loco_for.is_done() \
				and dist_to_player_greater(PHEConfig.GAP_CLOSER_RAD + 0.2) \
				and ra.chance(0.3 if not me.angry_raised else 0.6):
					_reason = "loco_for is done and dist > GAP_CLOSER_RAD+0.2 and flipped"
					_next_state = PHEState.combat_attacking # gap closer
			else:
				_reason = "dist > and loco_for not done"

		PHEState.combat_attacking:
			if current_substate.is_ended():
				if dist_to_player_less(PHEConfig.COMBAT_RAD if not me.angry_raised else PHEConfig.ORBIT_RAD):
					_reason = "combat_attacking is ended, but still in COMBAT_RAD, will flip on loco or attacking again"
					_next_state = ra.spick_weighted({
						PHEState.combat_loco: 0.5 if not me.angry_raised else 0.3,
						PHEState.combat_attacking: 0.5 if not me.angry_raised else 0.7})
				else:
					_reason = "combat_attacking is ended"
					_next_state = PHEState.combat_loco

		_:
			__log_forgot_implement(current_substate.state_name, "check_substate_transition", "combat_loco")
			_next_state = PHEState.combat_loco

	loco_for.auto_update(delta, current_substate.state_name, _next_state)

	## CHANGE STYLE: for now just a bunch of cheap ways to stick with angry
	if phe_feelings.health < phe_feelings.max_health * PHEConfig.PHASE_SWITCH_HP_TRESHOLD:
		me.angry_raised = true


	## FATIGUE 
	# NOTE: unique to life. Would be here for now
	if me.fatigue_raised:
		_next_state = PHEState.combat_loco # safest for now
		_reason += em.pin + "Declined: Some state raised 'fatigue_raised', we switch to " + _next_state
		me.fatigue_raised = false


	## DEATH
	if phe_feelings.health < 1:
		_reason = "health < 1"
		_next_state = PHEState.Leaf.death

	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = PHEState.still_life_phase
	_reason = "initial life_ state"
	return VerdictPH.new(_next_state, _reason)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("t2"):
		me.angry_raised = not me.angry_raised
		print("!!!", me.angry_raised, me.angry_raised)
