extends BasePHEAttackSeries


var all_the_dodges: Array[String] = [PHES.Leaf.dodge_R, PHES.Leaf.dodge_L, PHES.Leaf.dodge_F, PHES.Leaf.dodge_B]


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 12


func get_attack_series_list() -> Array:
	return [
		[PHES.Leaf.dodge_F, PHES.Leaf.sword_slide],
		[PHES.Leaf.dodge_R, PHES.Leaf.sword_slide],
		[PHES.Leaf.dodge_F, PHES.Leaf.stab_low],
	]


func pick_series_idx() -> int:
	var dist := distance_to_player()
	var _idx := 0
	if dist > config.CLOSE_TO_ORBIT() and not me.angry_raised:
		_idx = 2
	if dist < config.COMBAT_RAD():
		_idx = 1
	return _idx


func condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	if current_substate.state_name in all_the_dodges and current_substate.is_ended():
		return true

	return default_condition_to_next_switch(current_substate)
	
func condition_to_end(current_substate: BasePHELeaf) -> bool:
	return condition_to_next_switch(current_substate)
