extends BasePHEAttackSeries


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 16 # practically don't end


func get_attack_series_list() -> Array:
	return [
		[PHEState.Leaf.dodge],
		[PHEState.Leaf.dodge, PHEState.Leaf.dodge],
	]


func pick_series_idx() -> int:
	var _idx = ra.ipick_weighted({
		0: 0.6,
		1: 0.4,
	})
	return _idx
