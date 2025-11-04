extends BaseAttackAction


func initialise() -> void:
	hit_damage = 10

	default_sp.ANGULAR_SPEED = 8

	blend_time.set_by_prev_action({
		PS.Act.sword_slash_2: 0.2,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.sword_slash_2: 0.3,
	})


