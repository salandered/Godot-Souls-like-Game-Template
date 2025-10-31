extends BasePHEAttackSeries
class_name PHEAttackClubSeries


func initialise() -> void:
	attack_series_list = [
		[PHEState.Leaf.club_part_1],
		[PHEState.Leaf.club_part_1, PHEState.Leaf.club_part_2],
		[PHEState.Leaf.club_part_1, PHEState.Leaf.club_part_2, PHEState.Leaf.club_part_3_4]
	]

	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 7


func _pick_combo() -> Array[String]:
	var _chosen_index = ra.ipick_weighted({0: 0.2, 1: 0.4, 2: 0.4})
	
	if _chosen_index >= 0 and _chosen_index < attack_series_list.size():
		return attack_series_list[_chosen_index]
	
	# fallback
	__log_warn(true, "_pick_combo: Weighted pick resulted in invalid index.")
	return attack_series_list[0] # safe default
