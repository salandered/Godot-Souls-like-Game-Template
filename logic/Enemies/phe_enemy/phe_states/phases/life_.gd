extends BasePHEComposite


var loco_for = PHEHelpers.WillDoFor.new(3, 9, PHEState.combat_loco)


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	match current_substate.state_name:
		var _state_name when phe_feelings.health < 1:
			_reason = "health < 1"
			_next_state = PHEState.Leaf.death

		PHEState.still_life_phase:
			if current_substate.is_ended():
				_reason = "still_life_phase is ended"
				loco_for.set_random()
				_next_state = PHEState.combat_loco

		PHEState.combat_loco:
			if dist_to_player_less(PHEConfig.COMBAT_RAD) and ra.chance(0.5):
				_reason = "dist-to-pl < COMBAT_RAD and flipped"
				_next_state = PHEState.combat_phase
			elif loco_for.is_done(current_substate) and dist_to_player_greater(PHEConfig.GAP_CLOSER_RAD + 0.2):
				_reason = pp.s("loco_for is done and dist > GAP_CLOSER_RAD+0.2")
				_next_state = PHEState.combat_phase # gap closer


		PHEState.combat_phase:
			if current_substate.is_ended():
				_reason = "combat_phase is ended"
				loco_for.set_random()
				_next_state = PHEState.combat_loco
	# later
	# 	if phe_feelings.health < phe_feelings.max_health * phase_switch_hp_treshold:
	# 		return VerdictPH.new(PHEState.combat_phase_angry)

	# NOTE: unique to life
	if me.fatigue_raised:
		_next_state = PHEState.combat_loco # safest for now
		_reason += em.pin + "Declined: Some state raised 'fatigue_raised', we switch to " + _next_state
		me.fatigue_raised = false

	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = PHEState.still_life_phase
	_reason = "initial life_ state"
	return VerdictPH.new(_next_state, _reason)
