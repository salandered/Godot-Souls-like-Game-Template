extends BaseAttackAction


func initialize_implementation() -> void:
	hit_damage = 18

	blend_time.set_by_prev_action({
		PS.Act.axe_slice_2: 0.6,
		PS.Act.axe_slice_3: 0.4,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.axe_slice_2: 0.2,
	})

	extra_root_speed_Z.set_by_prev_action({
		PS.Act.axe_slice_1: - 1.0,
		PS.Act.axe_slice_2: - 1.0,
		PS.Act.axe_slice_3: - 1.0,
		Leg.Act.idle: - 2.0
		})
