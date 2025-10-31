extends BasePHEComposite
class_name PHECombatPhase


func is_ended() -> bool:
	return _attack_ended()


func _attack_ended() -> bool:
	var current_substate_ = get_current_substate()
	var _r: bool = true # safer to assume it's ended by default
	match current_substate_.state_name:
		PHEState.Leaf.gap_closer_attack, PHEState.Leaf.scare_off:
			if current_substate_.time_remaining() > 0.25:
				_r = false
		PHEState.attack_club_series:
			_r = current_substate_.is_ended()
		PHEState.attack_pick_single:
			_r = current_substate_.is_ended()
	return _r


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	if dist_to_player_greater(PHEConfig.GAP_CLOSER_RAD):
		_reason = "pl_dist_greater_than GAP_CLOSER_RAD " + str(PHEConfig.GAP_CLOSER_RAD)
		_next_state = PHEState.Leaf.gap_closer_attack
	elif dist_to_player_less(PHEConfig.SUPER_CLOSE):
		_reason = "pl_dist_less_than SUPER_CLOSE " + str(PHEConfig.SUPER_CLOSE)
		_next_state = ra.spick_weighted({PHEState.attack_club_series: 0.3, PHEState.Leaf.scare_off: 0.7})

	else:
		_reason = "SUPER_CLOSE < dist < GAP_CLOSER_RAD"
		_next_state = ra.spick_weighted({PHEState.attack_club_series: 0.6, PHEState.Leaf.scare_off: 0.4})
	return VerdictPH.new(_next_state, _reason)
