extends OpponentReactionIntention


func is_triggered() -> bool:
	return cant_be_punished() and need_to_reload()


func need_to_reload() -> bool:
	return not beliefs.have_state_charge()


func cant_be_punished() -> bool:
	var release_animation_length = beliefs.shield_throw_projectile_emit_timing()
	var distance = beliefs.distance_to_player()
	distance -= beliefs.shield_throw_arm_length()
	var projectile_travel_time = distance / beliefs.state_speed()
	var punish_time = release_animation_length + projectile_travel_time
	#print(punish_time)
	return punish_time > beliefs.state_restore_duration()
