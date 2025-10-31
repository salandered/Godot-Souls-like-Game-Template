extends BasePHEAttackSeries


func initialise() -> void:
	attack_series_list = [
		[PHEState.Leaf.attack_up],
		[PHEState.Leaf.attack_down],
		[PHEState.Leaf.attack_360_low]
]
