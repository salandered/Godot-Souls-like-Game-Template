extends LegsAction

var ANGULAR_SPEED: float = 12
@export var acceleration_curve: Curve

var curr_speed_time: float = 0.0 # [0,1] progress along curve
var acceleration_time: float = 0.5 # How long to reach full speed

func _ready():
	SPEED = 3.0
	TURN_SPEED = 2

func update(input: InputPackage, delta: float):
	process_input_vector(input, delta)


func process_input_vector(input: InputPackage, delta: float):
	var input_direction := velocity_by_input(input, delta).normalized()

	# Handle acceleration
	if input_direction.length() > 0:
		curr_speed_time = min(curr_speed_time + delta / acceleration_time, 1.0)
	else:
		curr_speed_time = max(curr_speed_time - delta / acceleration_time, 0.0)

	var CURVE_SPEED = acceleration_curve.sample(curr_speed_time)
	print(pp.ts(" curr_speed_time: ", curr_speed_time, " CURVE_SPEED", CURVE_SPEED))
	
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= ANGULAR_SPEED * delta:
		var face_dir_rotated := face_direction.rotated(Vector3.UP, sign(angle) * ANGULAR_SPEED * delta)
		player.velocity = face_dir_rotated * TURN_SPEED * CURVE_SPEED
		player.rotate_y(sign(angle) * ANGULAR_SPEED * delta)
	else:
		var face_dir_rotated := face_direction.rotated(Vector3.UP, angle)
		player.velocity = face_dir_rotated * SPEED * CURVE_SPEED
		player.rotate_y(angle)

	animator_manager.set_global_speed_scale(player.velocity.length() / SPEED)
	

## overrides for blend tests
var blend = 0.3 # WORKED GOOD!!
func animate(): # ▶️
	print_.lsm_action(action_name + "▶️", "animation " + anim_name, 8)
	
	animator_manager.set_anim_to_play(anim_name, blend)

func on_exit_action():
	animator_manager.reset_global_speed_scale()
	curr_speed_time = 0
	
func _input(event):
	if event.is_action_released("dev_speed_up"):
		SPEED += 6
	if event.is_action_released("dev_speed_down"):
		SPEED -= 6

	if event.is_action_released("t3"):
		blend += 0.1
		print("blend time ", blend)
	if event.is_action_released("t4"):
		blend -= 0.1
		print("blend time ", blend)


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

# func setup_animator(previous_action: LegsAction, _input: InputPackage):
	#if previous_action.legs_animator == legs_animator: # ie both are LegsLocomotion of Locomotion
		#if previous_action.action_name == "run_loco_start":
			#legs_animator.transition(cycle_spectre, 0)
		#else:
			#legs_animator.transition(cycle_spectre, 0.2)
# endregion
