extends BasePHEComposite


var loco_for := PHEHelpers.WillDoFor.new(3, 9, PHES.combat_loco)
var attacking_for := PHEHelpers.WillDoFor.new(4, 7, PHES.combat_attacking)


var __monitors: Array[PHEHelpers.MonitorFor] = [
	loco_for,
	attacking_for,
]


func get_supported_substates() -> Array[String]:
	return [
			PHES.combat_loco,
			PHES.combat_attacking,
			PHES.Leaf.phase_switch
		]


func is_ended() -> bool:
	return false


func on_exit_state() -> void:
	u.reset_all(__monitors)


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	var dist = distance_to_player()
	
	match current_substate.state_name:
		PHES.Leaf.phase_switch:
			if current_substate.is_ended():
				_reason += "in phase_switch 🕹️"
				_next_state = PHES.combat_loco
		PHES.combat_loco:
			# _next_state = PHES.combat_attacking ## DANGER DEV
			if _phase_switch_check():
				_reason += " loco to phase_switch 🕹️"
				me.angry_raised = true
				_next_state = PHES.Leaf.phase_switch
			elif loco_for.is_done(): # and current_substate.is_ended():
				_reason += "loco_for is done | "
				if ra.chance(0.8):
					_reason += "loco_for reset, let's loco again | "
					loco_for.reset()
					_next_state = PHES.combat_loco # gap closer
				elif dist > config.GAP_CLOSER_RAD() + 0.4 \
					and chance_angry(0.01, 0.6):
					_reason = "loco_for is done and dist > GAP_CLOSER_RAD+eps and flipped"
					_next_state = PHES.combat_attacking # gap closer
				elif dist < config.COMBAT_RAD():
					_reason = "dist < COMBAT_RAD"
					_next_state = PHES.combat_attacking
				else:
					_reason = "COMBAT_RAD < dist < GAP_CLOSER_RAD+eps - keep loco"
			else:
				_reason += "loco_for not done | "
				if dist < config.COMBAT_RAD():
					_reason += "dist < COMBAT_RAD | "
					if me.angry_raised:
						_reason += " attack"
						_next_state = PHES.combat_attacking
					elif ra.chance(0.01): # 0.25 chance/sec
						_reason += "small chance we attack"
						_next_state = PHES.combat_attacking

		PHES.combat_attacking:
			if current_substate.is_ended() and attacking_for.is_done():
				_reason += "curr sbs is ended and attackingFor done | "
				if _phase_switch_check():
					_reason += " attack to phase_switch 🕹️"
					me.angry_raised = true
					_next_state = PHES.Leaf.phase_switch
				elif dist > config.TOO_FAR():
					_reason += "dist > TOO_FAR"
					_next_state = PHES.combat_loco
				elif dist > config.COMBAT_RAD():
					_reason += "dist > COMBAT_RAD"
					_next_state = PHES.combat_loco
				else:
					_reason = "dist < COMBAT_RAD"
					_next_state = ra.spick_weighted({
						PHES.combat_loco: fvalue_angry(0.4, 0.2),
						PHES.combat_attacking: fvalue_angry(0.6, 0.8)})
			else:
				_reason += pp.s("attacking while we can. Context: currSbs isEnded / attackFor is done", current_substate.is_ended(), attacking_for.is_done())

		_:
			__log_forgot_implement(current_substate.state_name, "check_substate_transition", "combat_loco")
			_next_state = PHES.combat_loco

	
	if not me.angry_raised:
		loco_for.calibrate_min_max(3, 9)
		attacking_for.calibrate_min_max(3, 5)
	else:
		loco_for.calibrate_min_max(3, 8)
		attacking_for.calibrate_min_max(4, 7)


	_auto_update_monitors(__monitors, delta, current_substate.state_name, _next_state, "upd")

	return VerdictPH.new(_next_state, _reason)


func _phase_switch_check() -> bool:
	# already switched
	if me.angry_raised == true:
		return false
	return phe_feelings.is_lower_phase_switch()


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = PHES.combat_loco
	_reason = "initial is combat_loco"

	# we set "x" as 'unknown' state. it doesnt really matter, it's not a real name
	_auto_update_monitors(__monitors, 0.0, "x", _next_state, "choose_initial_substate")
	return VerdictPH.new(_next_state, _reason)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(RawAction.t2):
		if not me.angry_raised:
			# me.angry_raised = true will be raised by state flow
			phe_feelings._set_specific_health(phe_feelings.get_max_health() * PHEStaticConfig.PHASE_SWITCH_HP_TRESHOLD - 1)
			print("~~~~~ dev PHASE SWITCH to ANGRY")

		else:
			me.angry_raised = false
			phe_feelings._set_specific_health(phe_feelings.get_max_health())
			print("~~~~~ dev PHASE SWITCH TO USUAL")
