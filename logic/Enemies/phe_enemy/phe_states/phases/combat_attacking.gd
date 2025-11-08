extends BasePHEComposite
class_name PHECombatAttacking


func get_supported_substates() -> Array[String]:
	return [
			PHES.Leaf.gap_closer,
			PHES.Leaf.scare_off,
			PHES.Leaf.attack_up,
			PHES.attack_club_series,
			PHES.attack_pick_single,
			PHES.attack_from_dodge_b,
			PHES.attack_with_dodge_f,
			PHES.attack_360_series,
		]


var to_next_iteration := SimpleTimer.new()


func is_ended() -> bool:
	return _attack_ended()


func _attack_ended() -> bool:
	var current_substate_ := get_current_substate()
	if current_substate_:
		# NOTE: just works because all supported sbs are attacks with tuned is_ended()
		var _current_substate_is_ended := current_substate_.is_ended()
		return _current_substate_is_ended
	else:
		__log_warn_v2(true, "no current_substate_", "_attack_ended", "return true")
		return true


func on_enter_state() -> void:
	to_next_iteration.turn_off()
	

func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	var _switch_on_same := false
	var _override_commit := false
	
	if not _attack_ended():
		_reason = "in the middle of attack, not doing anything"
		return VerdictPH.new(_next_state, _reason)
	else:
		_reason += pp.s("attack is ended. we wait several frames and launch next iteration |")
		if not to_next_iteration.is_initialised():
			_reason += pp.s("we set a timer, while return empty verdict | ")
			to_next_iteration.initialise(0.05)
			return VerdictPH.new(_next_state, _reason)
		elif to_next_iteration.update(delta):
			to_next_iteration.turn_off()
			var _verdict := choose_initial_substate(_next_state, _reason)
			_next_state = _verdict.next_state
			_reason += pp.s("timer completed, we launch next iteration!", _verdict.get_reason())
			_switch_on_same = true
			_override_commit = true

		
	return VerdictPH.new(_next_state, _reason, _switch_on_same, _override_commit)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	var dist := distance_to_player()
	if dist > config.GAP_CLOSER_RAD():
		_reason = "pl_dist_greater_than GAP_CLOSER_RAD"
		_next_state = ra.spick_weighted({
			PHES.Leaf.gap_closer: fvalue_angry(0.4, 0.9),
			PHES.attack_with_dodge_f: fvalue_angry(0.01, 0.15)})
	elif dist > config.ORBIT_RAD():
		_next_state = PHES.attack_with_dodge_f
	elif dist > config.COMBAT_RAD():
		_next_state = ra.spick_weighted({
			PHES.attack_360_series: 0.5,
			PHES.attack_pick_single: 0.5})
	elif dist > config.TOO_CLOSE():
		_reason = "SUPER_CLOSE < dist < GAP_CLOSER_RAD"
		_next_state = ra.spick_weighted({
			state_angry(PHES.attack_club_series, PHES.attack_360_series): 0.7,
			PHES.attack_pick_single: fvalue_angry(0.4, 0.5),
			PHES.Leaf.scare_off: 0.2,
			PHES.attack_from_dodge_b: fvalue_angry(0.0, 0.4)})
	else:
		_reason = "dist < SUPER_CLOSE"
		_next_state = ra.spick_weighted({
			PHES.attack_from_dodge_b: fvalue_angry(0.1, 0.5),
			state_angry(PHES.Leaf.scare_off, PHES.attack_360_series): fvalue_angry(0.6, 0.5),
			PHES.attack_pick_single: fvalue_angry(0.3, 0.3)}
		)
	return VerdictPH.new(_next_state, _reason)
