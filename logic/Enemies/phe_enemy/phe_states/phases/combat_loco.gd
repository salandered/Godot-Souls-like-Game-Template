extends BasePHEComposite


var idle_for = PHEHelpers.WillDoFor.new(0.8, 2.5, PHEState.Leaf.combat_idle)
var not_dodge_for = PHEHelpers.WillNotDoFor.new(0.2, 0.4, PHEState.dodge_series)


func get_supported_substates() -> Array[String]:
	return [
			PHEState.Leaf.pursue,
			PHEState.Leaf.slow_pursue,
			PHEState.Leaf.orbit,
			PHEState.Leaf.combat_idle,
			PHEState.dodge_series,
			PHEState.Leaf.jump_towards,
			
		]


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	var dist := distance_to_player()

	match current_substate.state_name:
		PHEState.Leaf.pursue:
			_reason = "stay in 'pursue' until we get well within the next range"
			if dist < PHEConfig.ORBIT_RAD:
				_reason = "Reached orbit range, slowing down"
				_next_state = ra.spick_weighted({PHEState.Leaf.slow_pursue: 0.5, PHEState.Leaf.orbit: 0.5})
		
		PHEState.Leaf.slow_pursue:
			if dist >= PHEConfig.REAL_FAR:
				_next_state = PHEState.Leaf.pursue
				_reason = "dist >= REAL_FAR"
			elif dist < PHEConfig.ORBIT_RAD:
				_reason = "dist < ORBIT_RAD"
				if ra.coinflip() and not me.angry_raised:
					_next_state = PHEState.Leaf.combat_idle
				else:
					_next_state = PHEState.Leaf.orbit
			else:
				_reason = "slow pursue forever"

		PHEState.Leaf.orbit:
			# Stay in 'orbit' until the player *leaves* the orbit buffer
			if dist >= PHEConfig.SLOW_PURSUIT_RAD:
				_next_state = PHEState.Leaf.slow_pursue
				_reason = "player left orbit range, slow pursuing"
			elif works_longer_than(6.0 if not me.angry_raised else 2.0):
				_reason = "orbit so long"
				_next_state = PHEState.Leaf.slow_pursue if not me.angry_raised else PHEState.Leaf.jump_towards
			else:
				_reason = "orbiting, dist < SLOW_PURSUIT_RAD and we like it"
		PHEState.Leaf.combat_idle:
			if idle_for.is_done():
				_reason = "Idle time finished => _distance_to_pursue_sbs"
				var _verdict = _distance_to_pursue_sbs(_next_state, _reason)
				_next_state = _verdict.next_state
				_reason += "|" + _verdict.get_reason()
			elif dist < PHEConfig.COMBAT_RAD:
				_reason = "Idle not finished but < COMBAT_RAD"
				_next_state = PHEState.dodge_series
			else:
				_reason = "Idling while we can"
	
		PHEState.dodge_series, PHEState.Leaf.jump_towards:
			if current_substate.is_ended():
				_reason = "dodge or jump_towards ended => _distance_to_pursue_sbs"
				var _verdict = _distance_to_pursue_sbs(_next_state, _reason)
				_next_state = _verdict.next_state
				_reason += "|" + _verdict.get_reason()
			else:
				_reason = "current_substate not ended"

		_:
			__log_forgot_implement(current_substate.state_name, "check_substate_transition", "_distance_to_pursue_sbs")
			var _verdict = _distance_to_pursue_sbs(_next_state, _reason)
			_next_state = _verdict.next_state
			_reason += "|" + _verdict.get_reason()

	idle_for.auto_update(delta, current_substate.state_name, _next_state)
	not_dodge_for.auto_update(delta, current_substate.state_name, _next_state)

	return VerdictPH.new(_next_state, _reason)


func _distance_to_pursue_sbs(_next_state, _reason) -> VerdictPH:
	if dist_to_player_greater(PHEConfig.REAL_FAR):
		_reason = "dist > REAL_FAR "
		_next_state = ra.spick_weighted({
				PHEState.Leaf.jump_towards: 0.1 if not me.angry_raised else 0.7,
				PHEState.Leaf.pursue: 0.9
			})
	elif dist_to_player_greater(PHEConfig.SLOW_PURSUIT_RAD):
		_reason = "dist > SLOW_PURSUIT_RAD "
		_next_state = ra.spick_weighted({
			PHEState.Leaf.jump_towards: 0.1,
			PHEState.Leaf.slow_pursue: 0.9 if not me.angry_raised else 0.0,
			PHEState.Leaf.pursue: 0.0 if not me.angry_raised else 0.9
		})
	elif dist_to_player_greater(PHEConfig.ORBIT_RAD):
		_reason = "dist > ORBIT_RAD "
		_next_state = ra.spick_weighted({
			PHEState.Leaf.slow_pursue: 0.4 if not me.angry_raised else 0.0,
			PHEState.Leaf.pursue: 0.0 if not me.angry_raised else 0.4,
			PHEState.Leaf.orbit: 0.6})
	elif dist_to_player_greater(PHEConfig.SUPER_CLOSE):
		_reason = "ORBIT_RAD > pl dist > SUPER_CLOSE -> flip orbit/dodge"
		_next_state = ra.spick_weighted({PHEState.dodge_series: 0.3, PHEState.Leaf.orbit: 0.7})
	else:
		_reason = "dist < SUPER_CLOSE"
		if not_dodge_for.is_done():
			_next_state = PHEState.dodge_series
		else:
			_reason += " not_dodge_for not done then orbit"
			_next_state = PHEState.Leaf.orbit
	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	var _verdict = _distance_to_pursue_sbs(_next_state, _reason)
	_next_state = _verdict.next_state
	_reason = _verdict._reason
	return VerdictPH.new(_next_state, _reason)
