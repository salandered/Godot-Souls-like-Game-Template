extends BasePHEAttackSeries
## collects attacks which are not connected logically
class_name PHEAttackPickSingleSeries


func initialise() -> void:
	SWITCH_ANIM_BEFORE = 0.2
	PL_DIST_TO_END = 7


var attack_series_list :Array[Array]= [
		[PHES.Leaf.attack_up], # 0
		[PHES.Leaf.attack_down], # 1
		[PHES.Leaf.attack_up, PHES.Leaf.attack_down], # 2
		[PHES.Leaf.attack_360_high], # 3
		[PHES.Leaf.power_up], # 4
		[PHES.Leaf.stab_low] # 5
	]

func get_attack_series_list() -> Array[Array]:
	return attack_series_list


var pick_weight: Dictionary[int, float] = {
			0: 0.0,
			1: 0.9,
			2: 0.05,
			3: 0.5,
			4: 0.0,
			5: 0.5
		}
var angry_pick_weight: Dictionary[int, float] = {
			0: 0.9,
			1: 0.0,
			2: 0.5,
			3: 0.0,
			4: 0.3,
			5: 0.01
	}
	
func pick_series_idx() -> int:
	var _idx := 0
	if not me.angry_raised:
		_idx = ra.ipick_weighted(pick_weight)
	else:
		_idx = ra.ipick_weighted(angry_pick_weight)

	return _idx

func condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	return default_condition_to_next_switch(current_substate)
	
func condition_to_end(current_substate: BasePHELeaf) -> bool:
	return default_condition_to_end(current_substate)
