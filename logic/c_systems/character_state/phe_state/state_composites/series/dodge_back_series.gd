extends BasePHEAttackSeries


var all_the_dodges: Array[StringName] = [PHES.Leaf.dodge_R, PHES.Leaf.dodge_L, PHES.Leaf.dodge_F, PHES.Leaf.dodge_B]


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 16 # practically don't end


var attack_series_list: Array[Array] = [
		[PHES.Leaf.dodge_B],
		[PHES.Leaf.dodge_B, PHES.Leaf.dodge_B],
	]

func get_attack_series_list() -> Array[Array]:
	return attack_series_list


func pick_series_idx() -> int:
	var _idx := ra.ipick_weighted({
		0: 0.8,
		1: fvalue_angry(0.05, 0.2),
	})
	if dist_to_player_less(config.CLOSEST() - 0.2):
		_idx = 1
	return _idx


func condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	if current_substate.state_name in all_the_dodges and current_substate.is_ended():
		return true

	return default_condition_to_next_switch(current_substate)
	
func condition_to_end(current_substate: BasePHELeaf) -> bool:
	return condition_to_next_switch(current_substate)
