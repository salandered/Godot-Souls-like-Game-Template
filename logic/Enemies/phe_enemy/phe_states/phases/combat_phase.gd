extends BasePHEComposite


var loco_for := PHEHelpers.WillDoFor.new(3, 9, PHEState.combat_loco)
var attacking_for := PHEHelpers.WillDoFor.new(4, 7, PHEState.combat_attacking)


var __monitors: Array[PHEHelpers.MonitorFor] = [
	loco_for,
	attacking_for,
]


func get_supported_substates() -> Array[String]:
	return [
			PHEState.combat_loco,
			PHEState.combat_attacking,
		]


func is_ended() -> bool:
	return false


func on_exit_state() -> void:
	u.reset_all(__monitors)


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	var dist = distance_to_player()
	
	match current_substate.state_name:
		PHEState.combat_loco:
			if loco_for.is_done():
				_reason += "loco_for is done | "
				if dist > config.GAP_CLOSER_RAD() + 0.4 \
					and ra.chance(0.05 if not me.angry_raised else 0.6):
					_reason = "loco_for is done and dist > GAP_CLOSER_RAD+eps and flipped"
					_next_state = PHEState.combat_attacking # gap closer
				elif dist < config.COMBAT_RAD():
					_reason = "dist < COMBAT_RAD"
					_next_state = PHEState.combat_attacking
				else:
					_reason = "COMBAT_RAD < dist < GAP_CLOSER_RAD+eps - keep loco"
			else:
				_reason += "loco_for not done"

		PHEState.combat_attacking:
			if current_substate.is_ended() and attacking_for.is_done():
				_reason += "curr sbs is ended and attackingFor done | "
				if dist > config.TOO_FAR():
					_reason += "dist > TOO_FAR"
					_next_state = PHEState.combat_loco
				elif dist > config.COMBAT_RAD():
					_reason += "dist > COMBAT_RAD"
					_next_state = PHEState.combat_loco
				else:
					_reason = "dist < COMBAT_RAD"
					_next_state = ra.spick_weighted({
						PHEState.combat_loco: 0.5 if not me.angry_raised else 0.3,
						PHEState.combat_attacking: 0.5 if not me.angry_raised else 0.7})
			else:
				_reason += pp.s("attacking while we can. Context: currSbs isEnded / attackFor is done", current_substate.is_ended(), attacking_for.is_done())

		_:
			__log_forgot_implement(current_substate.state_name, "check_substate_transition", "combat_loco")
			_next_state = PHEState.combat_loco

	if not me.angry_raised:
		loco_for.calibrate_min_max(6, 11)
		attacking_for.calibrate_min_max(3, 5)
	else:
		loco_for.calibrate_min_max(3, 8)
		attacking_for.calibrate_min_max(4, 7)


	_auto_update_monitors(__monitors, delta, current_substate.state_name, _next_state, "upd")

	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = PHEState.combat_loco
	_reason = "initial is combat_loco"

	# we set "x" as 'unknown' state. it doesnt really matter, it's not a real name
	_auto_update_monitors(__monitors, 0.0, "x", _next_state, "choose_initial_substate")
	return VerdictPH.new(_next_state, _reason)
