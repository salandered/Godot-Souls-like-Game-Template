extends BasePHEAttackSeries
## collects attacks which are not connected logically
class_name PHEAttackPickSingleSeries


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 6


func get_attack_series_list() -> Array:
	return [
		[PHEState.Leaf.attack_up],
		[PHEState.Leaf.attack_down],
		[PHEState.Leaf.attack_up, PHEState.Leaf.attack_down]
	]


func pick_series_idx() -> int:
	var _idx = ra.ipick_weighted({
		0: 0.4 if not me.angry_raised else 0.6,
		1: 0.4 if not me.angry_raised else 0.2,
		2: 0.2 if not me.angry_raised else 0.6,
	})
	return _idx
