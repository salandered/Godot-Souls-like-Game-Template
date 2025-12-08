extends BaseAttackAction


func initialise_implementation() -> void:
	hit_damage = 8

	blend_time.set_by_prev_action({
		Leg.Act.run: 0.4,
		Leg.Act.sprint: 0.4
	})
	start_time_offset.set_specific(anim.get_marker_time_by_name(MarkerName.FROM_DODGE, 0.1))


func get_active_weapon_names() -> Array[String]:
	return default_get_active_weapon_names()


func on_enter_action(input_: InputPackage) -> void:
	_combat_set_hit_data_to_all_weapons()

	var _speed_extra_Z := DEFAULT_GLOBAL_EXTRA_SPEED_Z
	var _speed_extra_X := DEFAULT_GLOBAL_EXTRA_SPEED_X
	match PREV_ACTION:
		PS.Act.dodge:
			var result = _adjust_extra_speed_to_dodge_direction()
			_speed_extra_Z = result["Z"]
			_speed_extra_X = result["X"]
	
	var r = calculate_extra_root_speed(_speed_extra_Z, _speed_extra_X)
	_final_extra_speed_Z = r.z
	_final_extra_speed_X = r.x
	fade_interpolator.initialise(1.0, 0.0, DEFAULT_FADE_TIME)


func _adjust_extra_speed_to_dodge_direction() -> Dictionary:
	## animator manager treats prev anim as curr because we are in on_enter_action
	var prev_anim_id = get_animator_manager().get_curr_anim().anim_id
	# todo: should not use animations but strafe dir
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
	return {"X": speed_x, "Z": speed_z}