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

	match PREV_ACTION:
		Leg.Act.run: # run is not supported right now
			GLOBAL_EXTRA_SPEED = 1
			FADE_TIME = 0.3
		Leg.Act.sprint:
			GLOBAL_EXTRA_SPEED = 2
			FADE_TIME = 0.4
	
	var _inherited_speed := pm().get_curr_velocity_len()
	var _start_time_offset = start_time_offset.calculate_actual(PREV_ACTION)
	var root_start_speed := get_animator_manager().calculate_animation_start_root_velocity(anim, _start_time_offset, true)
	extra_speed = max(0.0, _inherited_speed - root_start_speed + GLOBAL_EXTRA_SPEED)
	fade_interpolator.initialise(1.0, 0.0, FADE_TIME)
	__log_action_ent("inheritedSp", _inherited_speed, " rootStartSp", root_start_speed, " extraSp", extra_speed)


func update(input_: InputPackage, delta: float):
	if tracks_input_vector():
		pm().rotate_with_input_vector(input_, delta)
	
	# var root_vel := get_animator_manager().get_root_velocity(true, false)
	var fade_factor := fade_interpolator.get_current_value()
	var extra_vel_local := Vector3(0, 0, extra_speed * fade_factor) # Animation +Z
	
	pm().move_with_root(delta, extra_vel_local, true, false)
	
	# if fade_factor > 0.0:
	# 	__log_action(
	# 		"RootVel.z: %.2f, Fade: %.2f, ExtraVel.z: %.2f, FinLocal.z: %.2f, FinalGlSp: %.2f" %
	# 		[root_vel.z, fade_factor, extra_vel_local.z, final_local_vel.z, get_curr_speed()])
	fade_interpolator.update(delta)
	player_sm.combat.update_is_attacking(weapon_hurts())
