extends BaseAttackAction


func initialise_implementation() -> void:
	hit_damage = 12

	blend_time.set_by_prev_action({
		Leg.Act.run: 0.4,
		Leg.Act.sprint: 0.4
	})
	start_time_offset.set_specific(anim.get_marker_time_by_name(MarkerName.FROM_RUN, 0.1))

	extra_root_speed_Z.set_by_prev_action({
		Leg.Act.sprint: 2.0
	})
	extra_root_speed_Z.set_specific(DEFAULT_GLOBAL_EXTRA_SPEED_Z)

func get_active_weapon_names() -> Array[String]:
	return default_get_active_weapon_names()


func on_enter_action(input_: InputPackage) -> void:
	_combat_set_hit_data_to_all_weapons()

	var _speed_extra_Z = extra_root_speed_Z.calculate_actual(PREV_ACTION)
	
	var r = calculate_extra_root_speed(_speed_extra_Z)
	_final_extra_speed_Z = r.z
	fade_interpolator.initialise(1.0, 0.0, DEFAULT_FADE_TIME)
