extends BasePHEAttackSeries
class_name PHEAttackClubSeries


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 7


func get_attack_series_list() -> Array:
	return [
		[PHEState.Leaf.club_part_1],
		[PHEState.Leaf.club_part_1, PHEState.Leaf.club_part_2],
		[PHEState.Leaf.club_part_1, PHEState.Leaf.club_part_2, PHEState.Leaf.club_part_3_4]
	]


func pick_series_idx() -> int:
	var _idx = ra.ipick_weighted({
		0: 0.2,
		1: 0.4,
		2: 0.4
	})
	return _idx
