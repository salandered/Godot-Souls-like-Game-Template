extends SkeletonModifier3D
# class_name PlayerModifierAnimator

# var derivative_delta: float = 0.02 # what ?


##################################################

# region: root history

# [from tutorial]
# func calculate_root_velocity() -> Vector3:
# 	var resulting_velocity: Vectors3
# 	var adjustment_delta: float = Time.get_unix_time_from_system() - last_update
# 	var curr_now: float = fmod(curr_progress + adjustment_delta, curr_cycle_length)

# 	resulting_velocity = lerp(curr_right_anim.get_root_velocity(curr_now), curr_left_anim.get_root_velocity(curr_now), curr_direction)

# 	if is_blending_spectres:
# 		var prev_now: float = fmod(prev_progress + adjustment_delta, prev_cycle_length)
# 		var prev_velocity = lerp(prev_right_anim.get_root_velocity(prev_now), prev_left_anim.get_root_velocity(prev_now), prev_direction)
# endregion

# region: [as it was with backend animation, attack state exmample]
# func move_with_root(custom_delta: float):
# 	var delta_pos = current_action.get_root_position_delta(custom_delta)
# 	delta_pos.y = 0
# 	player.velocity = player.get_quaternion() * delta_pos / custom_delta
# 	if not player.is_on_floor():
# 		player.velocity.y -= u.gravity * custom_delta
# 		forced_state = PS.midair

# WHERE:
# func get_root_position_delta(delta_time: float) -> Vector3:
# 	return states_data_repo.get_root_delta_pos(backend_animation, get_progress(), delta_time)

# WHERE
# # func get_root_delta_pos(animation: String, progress: float, custom_delta: float) -> Vector3: 
# 	var data = _get_animation(animation) 
# 	var track = data.find_track("StatesDatabase:root_position", Animation.TYPE_VALUE) 
# 	if data.track_get_key_count(track) <= 1: # 0 or 1. 
# 		return Vector3.ZERO 
# 	var previous_pos = data.value_track_interpolate(track, progress - custom_delta) 
# 	var current_pos = data.value_track_interpolate(track, progress) 
# 	var delta_pos = current_pos - previous_pos 
# 	return delta_pos
# endregion
