extends BasePHEComposite


var idle_for = PHEHelpers.WillDoFor.new(0.8, 2, PHEState.Leaf.combat_idle)
var another_dodge_cooldown: DelayTimer = DelayTimer.new()


func update(delta: float):
	another_dodge_cooldown.update(delta)


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	var dist := distance_to_player()

	match current_substate.state_name:
		PHEState.Leaf.pursue:
			# stay in 'pursue' until we get well within the next range
			if dist < PHEConfig.ORBIT_RAD:
				_next_state = ra.spick_weighted({PHEState.Leaf.slow_pursue: 0.5, PHEState.Leaf.orbit: 0.5})
				_reason = "Reached orbit range, slowing down"
		
		PHEState.Leaf.slow_pursue:
			if dist >= PHEConfig.REAL_FAR:
				_next_state = PHEState.Leaf.pursue
				_reason = " dist >= PURSUIT_RAD"
			elif dist < PHEConfig.ORBIT_RAD:
				_reason = "dist < ORBIT_RAD"
				if ra.coinflip():
					idle_for.set_random()
					_next_state = PHEState.Leaf.combat_idle
				else:
					_next_state = PHEState.Leaf.orbit

		PHEState.Leaf.orbit:
			# Stay in 'orbit' until the player *leaves* the orbit buffer
			if dist >= PHEConfig.SLOW_PURSUIT_RAD:
				_next_state = PHEState.Leaf.slow_pursue
				_reason = "player left orbit range, slow pursuing"

		PHEState.Leaf.combat_idle:
			if idle_for.is_done(current_substate):
				_reason = "Idle time finished"
				var _verdict = _distance_to_pursue_sbs(_next_state, _reason)
				_next_state = _verdict.next_state
				_reason += " -> " + _verdict._reason
	
		PHEState.Leaf.dodge:
			if current_substate.is_ended():
				_reason = "dodge ended"
				var _verdict = _distance_to_pursue_sbs(_next_state, _reason)
				_next_state = _verdict.next_state
				_reason += " -> " + _verdict._reason
	
	return VerdictPH.new(_next_state, _reason)


func _distance_to_pursue_sbs(_next_state, _reason):
	if dist_to_player_greater(PHEConfig.SLOW_PURSUIT_RAD):
		_next_state = PHEState.Leaf.pursue
		_reason = "pl_dist_greater_than SLOW_PURSUIT_RAD "
	elif dist_to_player_greater(PHEConfig.ORBIT_RAD):
		_reason = "pl_dist_greater_than ORBIT_RAD "
		_next_state = PHEState.Leaf.slow_pursue
	elif dist_to_player_greater(PHEConfig.SUPER_CLOSE):
		_reason = "pl dist > SUPER_CLOSE"
		_next_state = PHEState.Leaf.orbit
	else:
		_reason = "dist < SUPER_CLOSE"
		if not another_dodge_cooldown.is_in_progress():
			_next_state = PHEState.Leaf.dodge
			another_dodge_cooldown.initialise(0.4)
		else:
			_reason += " another_dodge_cooldown"
			_next_state = PHEState.Leaf.orbit
	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	var _verdict = _distance_to_pursue_sbs(_next_state, _reason)
	_next_state = _verdict.next_state
	_reason = _verdict._reason
	return VerdictPH.new(_next_state, _reason)
