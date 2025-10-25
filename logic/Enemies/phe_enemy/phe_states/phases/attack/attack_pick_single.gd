extends BasePHEAttackSeries


func initialise() -> void:
	attack_to_number = {
		PHEState.Leaf.attack_up: 0,
		PHEState.Leaf.attack_down: 1,
		PHEState.Leaf.attack_360_low: 2,
	}

	MIN_ATTACKS_TO_DO = 1
	MAX_ATTACKS_TO_DO = 1


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	var _attack_number = ra.pick_random([0, 1, 2])
	_next_state = _get_i_attack(_attack_number)
	_reason = "picked random attack number " + str(_attack_number)
	return VerdictPH.new(_next_state, _reason)
