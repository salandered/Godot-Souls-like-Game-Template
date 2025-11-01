extends BasePHEAttackSeries


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.3
	PL_DIST_TO_END = 10


func get_attack_series_list() -> Array:
	return [
		[PHEState.Leaf.dodge, PHEState.Leaf.attack_360_low],
		[PHEState.Leaf.dodge, PHEState.Leaf.sword_slide],
	]


func pick_series_idx() -> int:
	var _idx = ra.ipick_weighted({
		0: 0.3 if not me.angry_raised else 0.6,
		1: 0.7 if not me.angry_raised else 0.6,
	})
	return _idx
