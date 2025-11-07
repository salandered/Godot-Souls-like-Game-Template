extends BaseAttackAction


func initialise_implementation() -> void:
	hit_damage = 12

	blend_time.set_by_prev_action({
		Leg.Act.run: 0.4,
		Leg.Act.sprint: 0.4
	})
	start_time_offset.set_specific(anim.get_marker_time_by_name(Marker.Name_.FROM_RUN, 0.1))


func on_enter_action(input_: InputPackage) -> void:
	player_sm.combat.set_hit_data_to_active_weapon(hit_damage, anim.anim_id)

	var _actual_global_speed_extra_z := DEFAULT_GLOBAL_EXTRA_SPEED_Z
	var _actual_global_speed_extra_x := DEFAULT_GLOBAL_EXTRA_SPEED_X
	var _actual_fade_time := DEFAULT_FADE_TIME
	match PREV_ACTION:
		Leg.Act.run: # run is not supported right now
			_actual_global_speed_extra_z = 1
			_actual_fade_time = 0.3
		Leg.Act.sprint:
			_actual_global_speed_extra_z = 2
			_actual_fade_time = 0.4
		_:
			_actual_global_speed_extra_z = 1
			_actual_fade_time = 0.4
	
	_final_extra_speed_z = _calculate_final_speed_z(_actual_global_speed_extra_z)
	fade_interpolator.initialise(1.0, 0.0, _actual_fade_time)
