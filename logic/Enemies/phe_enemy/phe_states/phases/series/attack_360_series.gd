extends BasePHEAttackSeries


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 7


func get_attack_series_list() -> Array:
	return [
		[PHEState.Leaf.attack_360_high],
		[PHEState.Leaf.attack_360_low],
		[PHEState.Leaf.attack_360_high, PHEState.Leaf.attack_360_low],
	]


func pick_series_idx() -> int:
	var _idx = ra.ipick_weighted({
		0: 0.4,
		1: 0.4,
		2: 0.2,
	})
	return _idx
