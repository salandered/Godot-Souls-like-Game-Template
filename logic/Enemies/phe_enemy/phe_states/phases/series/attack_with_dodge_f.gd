extends BasePHEAttackSeries


var all_the_dodges := [PHEState.Leaf.dodge_R, PHEState.Leaf.dodge_L, PHEState.Leaf.dodge_F, PHEState.Leaf.dodge_B]


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 12


func get_attack_series_list() -> Array:
	return [
		[PHEState.Leaf.dodge_F, PHEState.Leaf.dodge_F],
		[PHEState.Leaf.dodge_F, PHEState.Leaf.sword_slide],
		[PHEState.Leaf.dodge_R, PHEState.Leaf.dodge_R, PHEState.Leaf.sword_slide],
	]


func pick_series_idx() -> int:
	var _idx = 0 if not me.angry_raised else 1
	if distance_to_player() < config.COMBAT_RAD():
		_idx = 2
	return _idx


func condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	if current_substate.state_name in all_the_dodges and current_substate.is_ended():
		return true

	return default_condition_to_next_switch(current_substate)
	
func condition_to_end(current_substate: BasePHELeaf) -> bool:
	return condition_to_next_switch(current_substate)
