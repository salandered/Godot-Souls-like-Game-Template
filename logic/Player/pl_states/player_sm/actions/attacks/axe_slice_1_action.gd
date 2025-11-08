extends BaseAttackAction


func initialise_implementation() -> void:
	hit_damage = 10

	blend_time.set_by_prev_action({
		PS.Act.axe_slice_2: 0.6,
	})

	start_time_offset.set_by_prev_action({
		PS.Act.axe_slice_2: 0.4,
	})


func get_active_weapon_names() -> Array[String]:
	return default_get_active_weapon_names()
