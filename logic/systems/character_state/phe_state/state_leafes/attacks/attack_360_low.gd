extends BasePHEAttack


func initialize_implementation() -> void:
	start_time_offset.set_by_prev_action({
		PHES.Leaf.dodge_B: 0.1,
	})
	hit_damage = 25
