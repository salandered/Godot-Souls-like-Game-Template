extends BasePlayerState
## WALK


# region: future reference
# func _ready() -> void:
# 	SPEED = 1.5
# 	TURN_SPEED = 1

# func check_transition(input_: InputPackage):
# 	if not player.is_on_floor():
# 		return PLVerdict.new("midair"
	
# 	return best_input_that_can_be_paid(input_)


# func update(input_: InputPackage, _delta: float):
# 	player.move_and_slide()

# func process_input_vector(input_: InputPackage, delta: float):
# 	var input_direction := velocity_by_input(input_, delta).normalized()
# 	var face_direction = player.basis.z
# 	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
# 	if abs(angle) >= tracking_angular_speed * delta:
# 		player.velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * TURN_SPEED
# 		player.rotate_y(sign(angle) * tracking_angular_speed * delta)
# 	else:
# 		player.velocity = face_direction.rotated(Vector3.UP, angle) * SPEED
# 		player.rotate_y(angle)


# func update(input_: InputPackage, delta : float):
# 	check_animation_settings()

# # we are but a parrot state
# func check_animation_settings():
# 	if torso_anim_settings.current_animation != legs.legs_anim_settings.current_animation:
# 		torso_anim_settings.play(legs.legs_anim_settings.current_animation, 0.35)

# func transition_logic(input_: InputPackage) -> String:
# 	input = translate_actions_to_behaviours(input_)
# 	return best_input_that_can_be_paid(input_)

# func translate_actions_to_behaviours(input : InputPackage) -> InputPackage:
# 	# todo smth like append default locomotion mode there
# 	input.behaviour_names.append("jog")
# 	input = map_with_dictionary(input_, behaviour_map)
# 	return input


# func choose_initial_behaviour(_input : InputPackage):
# 	simple_torso.sync_and_follow(legs.simple_animator, 0.15)
# endregion