extends BasePHEState
class_name PHECombatPhase

var GAP_CLOSER_RAD: float = 8.5
var SCAREOFF_RAD: float = 1.7


func is_ended() -> bool:
	return _attack_ended()


func _attack_ended() -> bool:
	var current_substate_ = get_current_substate()
	var _r: bool = true # safer to assume it's ended by default
	match current_substate_.state_name:
		PHEState.Leaf.gap_closer_attack, PHEState.Leaf.scare_off:
			if current_substate_.time_remaining() > 0.2:
				_r = false
		PHEState.attack_club_series:
			_r = current_substate_.is_ended()
	return _r


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	if distance_to_player() >= GAP_CLOSER_RAD:
		_reason = "distance_to_player() > GAP_CLOSER_RAD " + str(GAP_CLOSER_RAD)
		_next_state = PHEState.Leaf.gap_closer_attack
	elif distance_to_player() <= SCAREOFF_RAD:
		_reason = "distance_to_player() < SCAREOFF_RAD " + str(SCAREOFF_RAD)
		_next_state = PHEState.Leaf.scare_off
	else:
		_reason = pp.round_01(distance_to_player()) + " dist < gap-closer and > scare-off"
		_next_state = PHEState.attack_club_series

	return VerdictPH.new(_next_state, _reason)
