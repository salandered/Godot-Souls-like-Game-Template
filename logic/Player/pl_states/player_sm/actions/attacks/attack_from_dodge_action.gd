extends BaseAttackAction


func initialise_implementation() -> void:
	hit_damage = 8

	blend_time.set_by_prev_action({
		Leg.Act.run: 0.4,
		Leg.Act.sprint: 0.4
	})
	start_time_offset.set_specific(anim.get_marker_time_by_name(Marker.Name_.FROM_DODGE, 0.1))


func on_enter_action(input_: InputPackage) -> void:
	player_sm.combat.set_hit_data_to_active_weapon(hit_damage, anim.anim_id)

	var _actual_global_speed_extra_z := DEFAULT_GLOBAL_EXTRA_SPEED_Z
	var _actual_global_speed_extra_x := DEFAULT_GLOBAL_EXTRA_SPEED_X
	var _actual_fade_time := DEFAULT_FADE_TIME
	match PREV_ACTION:
		PS.Act.dodge:
			var result = _adjust_global_extra_speed_to_dodge_direction()
			_actual_global_speed_extra_z = result["Z"]
			_actual_global_speed_extra_x = result["X"]
			_actual_fade_time = result["FADE_TIME"]
	
	_final_extra_speed_z = _calculate_final_speed_z(_actual_global_speed_extra_z)
	_final_extra_speed_x = _calculate_final_speed_x(_actual_global_speed_extra_x)
	fade_interpolator.initialise(1.0, 0.0, _actual_fade_time)


func _adjust_global_extra_speed_to_dodge_direction() -> Dictionary:
	## animator manager treats prev anim as curr because we are in on_enter_action
	var prev_anim_id = get_animator_manager().get_curr_anim().anim_id
	# todo: should not use animations but strafe dir
	var fade_time: float = DEFAULT_FADE_TIME
	var speed_x: float
	var speed_z: float
	if prev_anim_id == A.dodge.dodge_F:
		speed_z = 2
		speed_x = 0.0
	elif prev_anim_id == A.dodge.dodge_B:
		speed_z = -2.5
		speed_x = 0.0
	elif prev_anim_id == A.dodge.dodge_R:
		speed_z = -2.2
		speed_x = -1.5
	elif prev_anim_id == A.dodge.dodge_L:
		speed_z = -2.2
		speed_x = 1.5
	else:
		speed_z = 0.0
		speed_x = 0.0
	return {"X": speed_x, "Z": speed_z, "FADE_TIME": fade_time}