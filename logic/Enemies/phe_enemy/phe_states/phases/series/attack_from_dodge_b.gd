extends BasePHEAttackSeries


var all_the_dodges := [PHEState.Leaf.dodge_R, PHEState.Leaf.dodge_L, PHEState.Leaf.dodge_F, PHEState.Leaf.dodge_B]


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.3
	PL_DIST_TO_END = 10


func get_attack_series_list() -> Array:
	return [
		[PHEState.Leaf.dodge_B, PHEState.Leaf.attack_360_low],
		[PHEState.Leaf.dodge_B, PHEState.Leaf.sword_slide],
	]


func pick_series_idx() -> int:
	var _idx := ra.ipick_weighted({
		0: 0.9 if not me.angry_raised else 0.2,
		1: 0.05 if not me.angry_raised else 0.8,
	})
	return _idx


func condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	var allow_switch_marker := Marker.Name_.ALLOWS_SWITCH

	if current_substate.state_name in all_the_dodges and current_substate.is_ended():
		return true

	return default_condition_to_next_switch(current_substate)
	
func condition_to_end(current_substate: BasePHELeaf) -> bool:
	return condition_to_next_switch(current_substate)
