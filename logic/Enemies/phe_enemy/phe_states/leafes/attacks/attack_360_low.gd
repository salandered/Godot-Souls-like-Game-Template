extends BasePHEAttack


func initialise_implementation() -> void:
	start_time_offset.set_by_prev_action({
		PHEState.Leaf.dodge_B: 0.1,
	})
