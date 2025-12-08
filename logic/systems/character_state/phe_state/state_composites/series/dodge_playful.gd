extends BasePHEAttackSeries


var all_the_dodges: Array[String] = [PHES.Leaf.dodge_R, PHES.Leaf.dodge_L, PHES.Leaf.dodge_F, PHES.Leaf.dodge_B]

func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 16 # practically don't end


func get_attack_series_list() -> Array:
	return [
		[PHES.Leaf.dodge_L],
		[PHES.Leaf.dodge_R],
		[PHES.Leaf.dodge_F, PHES.Leaf.dodge_B],
		[PHES.Leaf.dodge_B],
	]


func pick_series_idx() -> int:
	var idx_2_chance := 0.0 if distance_to_player() < config.DODGE_RAD() else 0.2
	var _idx := ra.ipick_weighted({
		0: 0.4,
		1: 0.4,
		2: idx_2_chance,
		3: 0.0
	})
	# if somehow happended we are too close, no dodge forward etc
	if dist_to_player_less(config.COMBAT_RAD() - 0.1):
		_idx = 3
	return _idx


func condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	if current_substate.state_name in all_the_dodges and current_substate.is_ended():
		return true

	return default_condition_to_next_switch(current_substate)
	
func condition_to_end(current_substate: BasePHELeaf) -> bool:
	return condition_to_next_switch(current_substate)