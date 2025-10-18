extends PlayerState

# region: FAIR LOGIC for process input vector
#if combat.current_camera_mode == combat.CameraMode.FREE:
	#var input_direction = camera.basis.z
	#var face_direction = player.basis.z
	#var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	#var new_z = player.basis.z.rotated(Vector3.UP, clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))
	#var new_x = - new_z.cross(Vector3.UP)
	#player.basis = Basis(new_x, Vector3.UP, new_z).orthonormalized()
#else:
	#var input_direction = combat.direction_to_target()
	#var face_direction = player.basis.z
	#var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	#var new_z = player.basis.z.rotated(Vector3.UP, clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))
	#var new_x = - new_z.cross(Vector3.UP)
	#player.basis = Basis(new_x, Vector3.UP, new_z).orthonormalized()
# endregion

# region: FAIR LOGIC
# func move_with_root(_delta: float):
	#var current_rotation: Quaternion
	#if combat.current_camera_mode == combat.CameraMode.FREE:
		#current_rotation = camera.get_quaternion()
	#else:
		#current_rotation = player.get_quaternion()
	#var velocity: Vector3 = current_rotation * legs_animator.calculate_root_velocity()
	#player.set_velocity(velocity)
	#player.move_and_slide()

# func setup_animator(previous_action: LegsAction, input_: InputPackage):
	#if previous_action.legs_animator == legs_animator: # ie both are LegsLocomotion of Locomotion
		#if previous_action.action_name == "run_loco_start":
			#legs_animator.transition(cycle_spectre, 0)
		#else:
			#legs_animator.transition(cycle_spectre, 0.2)
# endregion
