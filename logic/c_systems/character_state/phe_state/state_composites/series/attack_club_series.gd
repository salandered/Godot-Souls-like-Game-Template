extends BasePHEAttackSeries


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 7


var attack_series_list: Array[Array] = [
		[PHES.Leaf.club_part_1],
		[PHES.Leaf.club_part_1, PHES.Leaf.club_part_2],
		[PHES.Leaf.club_part_1, PHES.Leaf.club_part_2, PHES.Leaf.club_part_3_4],
		[PHES.Leaf.club_part_1, PHES.Leaf.club_part_2, PHES.Leaf.attack_360_high],
		[PHES.Leaf.club_part_1, PHES.Leaf.club_part_2, PHES.Leaf.club_part_3_4, PHES.Leaf.attack_360_high]
	]

func get_attack_series_list() -> Array[Array]:
	return attack_series_list


var pick_weight: Dictionary[int, float] = {
		0: 0.2,
		1: 0.4,
		2: 0.4,
		3: 0.2,
		4: 0.05
	}

func pick_series_idx() -> int:
	var _idx := ra.ipick_weighted(pick_weight)
	return _idx


func condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	var _r := current_substate.time_remaining() < SWITCH_ANIM_BEFORE
	# print_.dev("condition_to_next_switch", current_substate.time_remaining())
	if _r:
		var _oh := current_substate.time_remaining()
		# print_.dev("condition_to_next_switch", "_r", _r, "curr_sbs.ts", current_substate.time_remaining(), "SWITCH_ANIM_BEFORE", SWITCH_ANIM_BEFORE)
	return _r
	
func condition_to_end(current_substate: BasePHELeaf) -> bool:
	return default_condition_to_end(current_substate)
