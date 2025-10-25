extends BasePHEState


var phase_switch_hp_treshold := 0.5 # % of maximum
var combat_radius: float = 3.5


var pursue_phase_for = PHEHelpers.WillDoFor.new(3, 9, PHEState.pursuing_phase)


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	match current_substate.state_name:
		var _state_name when phe_feelings.health < 1:
			_reason = "health < 1"
			_next_state = PHEState.Leaf.death

		PHEState.still_life_phase:
			if current_substate.is_ended():
				_reason = "still_life_phase is ended"
				pursue_phase_for.set_random()
				_next_state = PHEState.pursuing_phase

		PHEState.pursuing_phase:
			# will_pursue_for = 999999
			if pursue_phase_for.is_done(current_substate) or distance_to_player() < combat_radius:
				_reason = pp.s(pursue_phase_for.__pp_is_done(), "and dist-to-pl < combat_rad", combat_radius)
				_next_state = PHEState.combat_phase
			# gap close please
			elif ra.chance(0.8) and distance_to_player() > 9:
				_reason = pp.s("ra.chance(0.4) and distance_to_player() > 12")
				_next_state = PHEState.combat_phase


		PHEState.combat_phase:
			if current_substate.is_ended():
				_reason = "combat_phase is ended"
				pursue_phase_for.set_random()
				_next_state = PHEState.pursuing_phase
	# later
	# 	if phe_feelings.health < phe_feelings.max_health * phase_switch_hp_treshold:
	# 		return VerdictPH.new(PHEState.combat_phase_angry)

	# NOTE: unique to life
	if me.fatigue_raised:
		_next_state = PHEState.pursuing_phase # safest for now
		_reason += "Declined: Some state raised 'fatigue_raised', we switch to " + _next_state
		me.fatigue_raised = false

	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = PHEState.still_life_phase
	_reason = "initial life_ state"
	return VerdictPH.new(_next_state, _reason)
