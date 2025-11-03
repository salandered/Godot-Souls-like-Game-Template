extends BasePHEAttackSeries
## collects attacks which are not connected logically
class_name PHEAttackPickSingleSeries


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 7


func get_attack_series_list() -> Array:
	return [
		[PHES.Leaf.attack_up],
		[PHES.Leaf.attack_down],
		[PHES.Leaf.attack_up, PHES.Leaf.attack_down],
		[PHES.Leaf.attack_360_high]
	]


func pick_series_idx() -> int:
	var _idx := 0
	if not me.angry_raised:
		_idx = ra.ipick_weighted({
			0: 0.0,
			1: 0.9,
			2: 0.05,
			3: 0.5
		})
	else:
		_idx = ra.ipick_weighted({
			0: 0.9,
			1: 0.0,
			2: 0.4,
			3: 0.0,
	})

	return _idx

func condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	return default_condition_to_next_switch(current_substate)
	
func condition_to_end(current_substate: BasePHELeaf) -> bool:
	return default_condition_to_end(current_substate)
