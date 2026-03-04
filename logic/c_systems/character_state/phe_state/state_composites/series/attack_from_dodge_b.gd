extends BasePHEAttackSeries


func initialize() -> void:
	SWITCH_ANIM_BEFORE = 0.3
	PL_DIST_TO_END = 10


var attack_series_list: Array[Array] = [
		[PHES.Leaf.dodge_B, PHES.Leaf.attack_360_low],
		[PHES.Leaf.dodge_B, PHES.Leaf.sword_slide],
		[PHES.Leaf.dodge_B, PHES.Leaf.dodge_B, PHES.Leaf.gap_closer],
		[PHES.Leaf.dodge_B, PHES.Leaf.phase_switch],
		[PHES.Leaf.phase_switch], # funny thing
	]

func get_attack_series_list() -> Array[Array]:
	return attack_series_list


func pick_series_idx() -> int:
	var switch_boost := 0.03 if dist_to_player_less(config.COMBAT_RAD()) else 0.01

	var _idx := ra.ipick_weighted({
		0: fvalue_angry(0.9, 0.2),
		1: fvalue_angry(0.05, 0.4),
		2: fvalue_angry(0.1, 0.4),
		3: fvalue_angry(0.0, 0.01),
		4: fvalue_angry(0.0, 0.0 + switch_boost),
	})
	return _idx


func condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	if current_substate.state_name in all_the_dodges and current_substate.is_ended():
		return true

	return default_condition_to_next_switch(current_substate)
	
func condition_to_end(current_substate: BasePHELeaf) -> bool:
	return condition_to_next_switch(current_substate)
