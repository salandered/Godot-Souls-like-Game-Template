extends BaseAttackAction


func initialise_implementation() -> void:
	hit_damage = 10


	blend_time.set_by_prev_action({
		PS.Act.sword_slash_2: 0.2,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.sword_slash_2: 0.3,
	})

	extra_root_speed_Z.set_by_prev_action({
		PS.Act.sword_slash_1: - 1.0
		})
	# GLOBAL_EXTRA_SPEED = 0.0


func get_active_weapon_names() -> Array[String]:
	return default_get_active_weapon_names()
