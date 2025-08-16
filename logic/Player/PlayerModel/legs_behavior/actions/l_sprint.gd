extends LegsAction

@export var tracking_angular_speed: float = 10


func update(input: InputPackage, delta: float):
	process_input_vector(input, delta)

	player.move_and_slide()


func process_input_vector(input: InputPackage, delta: float):
	var input_direction := velocity_by_input(input, delta).normalized()
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= tracking_angular_speed * delta:
		player.velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * TURN_SPEED
		player.rotate_y(sign(angle) * tracking_angular_speed * delta)
	else:
		player.velocity = face_direction.rotated(Vector3.UP, angle) * SPEED
		player.rotate_y(angle)
# region FAIR

# func update(input: InputPackage, delta: float):
# 	process_input_vector(input, delta)
# 	move_with_root(delta)
	
	
# func move_with_root(_delta: float):
# 	var current_rotation = player.get_quaternion()
# 	var velocity: Vector3 = current_rotation * legs_animator.calculate_root_velocity()
# 	player.set_velocity(velocity)
# 	player.move_and_slide()

# func process_input_vector(input: InputPackage, delta: float):
# 	# to mute errors, i ll rewrite it with my camera
# 	var input_direction = Vector3.FORWARD
# 	#var input_direction = (camera.basis * input.get_vector3()).normalized()
# 	var face_direction = player.basis.z
# 	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
# 	var new_z = player.basis.z.rotated(Vector3.UP, clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))
# 	var new_x = - new_z.cross(Vector3.UP)
# 	player.basis = Basis(new_x, Vector3.UP, new_z).orthonormalized()

# # TODO strange twitch for one frame when switching animations
# func animate(previous_action: LegsAction, _input: InputPackage):
# 	if previous_action.legs_animator == legs_animator: # ie both are simple of AnimatorModifier t
# 		legs_animator.play(animation, 0.35)
# 	else:
# 		legs_animator.play(animation, 0)
# 		# legs_anim_settings.play(anim_settings, 0.35)

# endregion
