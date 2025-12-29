extends BaseAttackAction


func initialise_implementation() -> void:
	hit_damage = 15


	blend_time.set_by_prev_action({
		PS.Act.sword_slash_1: 0.3,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.sword_slash_1: 0.3,
	})


	extra_root_speed_Z.set_by_prev_action({
		PS.Act.sword_slash_1: - 1.0
		})