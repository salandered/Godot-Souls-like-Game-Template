extends BaseAttackAction


func initialise_implementation() -> void:
	hit_damage = 15


	blend_time.set_by_prev_action({
		PS.Act.sword_slash_1: 0.3,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.sword_slash_1: 0.3,
	})


func get_active_weapon_names() -> Array[String]:
	return default_get_active_weapon_names()
