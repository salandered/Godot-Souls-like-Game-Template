extends BasePHEComposite
class_name PHECombatAttacking


func get_supported_substates() -> Array[String]:
	return [
			PHEState.Leaf.gap_closer_attack,
			PHEState.Leaf.fancy_gap_closer,
			PHEState.Leaf.scare_off,
			PHEState.Leaf.attack_up,
			PHEState.attack_club_series,
			PHEState.attack_pick_single,
			PHEState.attack_from_dodge_series,
			PHEState.attack_360_series,
		]


func is_ended() -> bool:
	return _attack_ended()


func _attack_ended() -> bool:
	var current_substate_ = get_current_substate()
	var _r: bool = true # safer to assume it's ended by default
	match current_substate_.state_name:
		# todo consider using is_ended also. then whole function can be just check of is_ended
		PHEState.Leaf.gap_closer_attack, PHEState.Leaf.fancy_gap_closer:
			if current_substate_.time_remaining() > 0.25:
				_r = false
		PHEState.Leaf.scare_off, PHEState.Leaf.attack_up:
			if current_substate_.time_remaining() > 0.2:
				_r = false
		PHEState.attack_club_series, PHEState.attack_pick_single, PHEState.attack_from_dodge_series, PHEState.attack_360_series:
			_r = current_substate_.is_ended()
		_:
			__log_forgot_implement(current_substate_.state_name, "_attack_ended", "return true")
			_r = true
	return _r


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	if not _attack_ended():
		_reason = "in the middle of attack, not doing anything"
		return VerdictPH.new(_next_state, _reason)
	
	var _verdict = choose_initial_substate(_next_state, _reason)
	_next_state = _verdict.next_state
	_reason = _verdict.get_reason()
	_reason += " " + "is ended => launched next iteration"
	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	if dist_to_player_greater(PHEConfig.GAP_CLOSER_RAD):
		_reason = "pl_dist_greater_than GAP_CLOSER_RAD"
		_next_state = ra.spick_weighted({
			PHEState.Leaf.gap_closer_attack: 0.9 if not me.angry_raised else 0.4,
			PHEState.Leaf.fancy_gap_closer: 0.1 if not me.angry_raised else 0.8})
	elif dist_to_player_greater(PHEConfig.SUPER_CLOSE):
		_reason = "SUPER_CLOSE < dist < GAP_CLOSER_RAD"
		_next_state = ra.spick_weighted({
			PHEState.attack_club_series: 0.5,
			PHEState.attack_pick_single: 0.5,
			PHEState.Leaf.scare_off: 0.2})
		if me.angry_raised:
			_next_state = ra.spick_weighted({
				PHEState.attack_360_series: 0.5,
				PHEState.attack_pick_single: 0.5,
				PHEState.Leaf.attack_up: 0.3})
	else:
		_reason = "dist < SUPER_CLOSE"
		_next_state = ra.spick_weighted({
			PHEState.attack_from_dodge_series: 0.5,
			PHEState.Leaf.scare_off: 0.5}
		)
		if me.angry_raised:
			_next_state = ra.spick_weighted({
				PHEState.attack_360_series: 0.6,
				PHEState.Leaf.scare_off: 0.4}
			)
	return VerdictPH.new(_next_state, _reason)
