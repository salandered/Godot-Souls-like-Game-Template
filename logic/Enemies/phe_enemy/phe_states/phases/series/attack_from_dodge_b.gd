extends BasePHEAttackSeries


var all_the_dodges := [PHES.Leaf.dodge_R, PHES.Leaf.dodge_L, PHES.Leaf.dodge_F, PHES.Leaf.dodge_B]


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.3
	PL_DIST_TO_END = 10


func get_attack_series_list() -> Array:
	return [
		[PHES.Leaf.dodge_B, PHES.Leaf.attack_360_low],
		[PHES.Leaf.dodge_B, PHES.Leaf.sword_slide],
		[PHES.Leaf.dodge_B, PHES.Leaf.gap_closer],
	]


func pick_series_idx() -> int:
	var _idx := ra.ipick_weighted({
		0: fvalue_angry(0.9, 0.2),
		1: fvalue_angry(0.05, 0.6),
		2: fvalue_angry(0.1, 0.6),
	})
	return _idx


func condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	var allow_switch_marker := Marker.Name_.ALLOWS_SWITCH

	if current_substate.state_name in all_the_dodges and current_substate.is_ended():
		return true

	return default_condition_to_next_switch(current_substate)
	
func condition_to_end(current_substate: BasePHELeaf) -> bool:
	return condition_to_next_switch(current_substate)
