extends LegsAction

@export var tracking_angular_speed: float = 12


func _ready():
	SPEED = 3.0
	TURN_SPEED = 2

func update(input: InputPackage, delta: float):
	process_input_vector(input, delta)


func process_input_vector(input: InputPackage, delta: float):
	var input_direction := velocity_by_input(input, delta).normalized()
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= tracking_angular_speed * delta:
		player.velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * TURN_SPEED # SPEED or TURN_SPEED?
		player.rotate_y(sign(angle) * tracking_angular_speed * delta)
	else:
		player.velocity = face_direction.rotated(Vector3.UP, angle) * SPEED
		player.rotate_y(angle)
	# _velocity.limit_lensgth(SPEED) ?
	# legs_sm.legs_animator.set_speed_scale(player.velocity.length() / SPEED)

	# region FAIR LOGIC
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


func on_exit_action():
	print_.lsm_action("", "exit: reset_speed_scale", 3)
	# legs_sm.legs_animator.reset_speed_scale()
	
func _input(event):
	if event.is_action_released("dev_speed_up"):
		SPEED += 10
	if event.is_action_released("dev_speed_down"):
		SPEED -= 10

# region FAIR LOGIC
# func move_with_root(_delta: float):
# 	pass # rewrite this with my setup
	# region FAIR LOGIC
	#var current_rotation: Quaternion
	#if combat.current_camera_mode == combat.CameraMode.FREE:
		#current_rotation = camera.get_quaternion()
	#else:
		#current_rotation = player.get_quaternion()
	#var velocity: Vector3 = current_rotation * legs_animator.calculate_root_velocity()
	#player.set_velocity(velocity)
	#player.move_and_slide()

# func setup_animator(previous_action: LegsAction, _input: InputPackage):
# 	pass
	# dont know how it works with new animators from the roadmap
	#if previous_action.legs_animator == legs_animator: # ie both are LegsLocomotion of Locomotion
		#if previous_action.action_name == "run_loco_start":
			#legs_animator.transition(cycle_spectre, 0)
		#else:
			#legs_animator.transition(cycle_spectre, 0.2)
# endregion
