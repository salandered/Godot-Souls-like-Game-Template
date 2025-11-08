extends BasePHEAttackSeries


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 7


func get_attack_series_list() -> Array:
	return [
		[PHES.Leaf.attack_360_high],
		[PHES.Leaf.attack_360_low],
		[PHES.Leaf.attack_360_high, PHES.Leaf.attack_360_low],
	]


func pick_series_idx() -> int:
	var _idx := 0
	if not me.angry_raised:
		_idx = ra.ipick_weighted({
			0: 0.8,
			1: 0.0,
			2: 0.0,
		})
	else:
		_idx = ra.ipick_weighted({
			0: 0.0,
			1: 0.3,
			2: 0.7,
	})
	return _idx


func condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	if attack_in_series_passed_marker(
			2,
			current_substate,
			PHES.Leaf.attack_360_high,
			MarkerName.EARLY_SERIES_SWITCH):
		return true
	return default_condition_to_next_switch(current_substate)
	
	
func condition_to_end(current_substate: BasePHELeaf) -> bool:
	return default_condition_to_end(current_substate)
