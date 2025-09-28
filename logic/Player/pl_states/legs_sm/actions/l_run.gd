extends LegsAction

var ANGULAR_SPEED: float = 12
@export var acceleration_curve: Curve

var current_speed_t: float = 0.0 # [0,1] progress along curve
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
		current_speed_t = min(current_speed_t + delta / acceleration_time, 1.0)
	else:
		current_speed_t = max(current_speed_t - delta / acceleration_time, 0.0)
	var speed_multiplier = acceleration_curve.sample(current_speed_t)
	# print(" current_speed_t: ", pp.round_01(current_speed_t), "   speed_multiplier: ", pp.round_01(speed_multiplier))
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= ANGULAR_SPEED * delta:
		player.velocity = face_direction.rotated(Vector3.UP, sign(angle) * ANGULAR_SPEED * delta) * TURN_SPEED * speed_multiplier
		player.rotate_y(sign(angle) * ANGULAR_SPEED * delta)
	else:
		player.velocity = face_direction.rotated(Vector3.UP, angle) * SPEED * speed_multiplier
		player.rotate_y(angle)

	legs_sm.legs_animator.set_global_speed_scale(player.velocity.length() / SPEED)
	
	# region: FAIR LOGIC
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

var blend = 0.2

## overrides for start_from
func animate(): # ▶️
	# TODO: here we use start_from form adjusting run animation.
	# i think this data should be in animation, not a state (leg action in this case)
	# so state or action knows not an anim name as string, but a more complex structure.
	# and changing animation should change its paramerers like start_from 
	print_.lsm_action(action_name + em.play, "animation " + anim_name, 8)
	legs_sm.legs_animator.set_anim_to_play(anim_name, blend)

func on_exit_action():
	# print_.lsm_action(action_name, "exit: reset_speed_scale", 3)
	legs_sm.legs_animator.reset_global_speed_scale()
	current_speed_t = 0
	
func _input(event):
	if event.is_action_released("dev_speed_up"):
		SPEED += 6
	if event.is_action_released("dev_speed_down"):
		SPEED -= 6

	# if event.is_action_released("t1"):
	# 	start_from += 0.05
	# 	print("blend time ", start_from)
	# if event.is_action_released("t2"):
	# 	start_from -= 0.05
	# 	print("blend time ", start_from)

	if event.is_action_released("t3"):
		blend += 0.1
		print("blend time ", blend)
	if event.is_action_released("t4"):
		blend -= 0.1
		print("blend time ", blend)

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
