# extends LegsAction

# @export var tracking_angular_speed : float = 10

# var cycle_spectre : Dictionary = {
# 	Vector2(0, 1) : "LocJog/F",
# 	(Vector2(-1, 0) + Vector2(0, 1)).normalized() : "LocJog/FL",
# 	Vector2(-1, 0) : "LocJog/L",
# 	(Vector2(-1, 0) + Vector2(0, -1)).normalized() : "LocJog/BL",
# 	Vector2(0, -1) : "LocJog/B",
# 	(Vector2(1, 0) + Vector2(0, -1)).normalized() : "LocJog/BR",
# 	Vector2(1, 0) : "LocJog/R",
# 	(Vector2(0, 1) + Vector2(1, 0)).normalized() : "LocJog/FR",
# }

# func update(input : InputPackage, delta : float):
# 	process_input_vector(input, delta)
# 	if combat.current_camera_mode == combat.CameraMode.FREE:
# 		legs_animator.input_vector = input.get_vector2()
# 	else:
# 		legs_animator.input_vector = input.get_vector2().rotated(
# 			player.basis.z.signed_angle_to(combat.direction_to_target(), Vector3.UP)
# 		)

# 	move_with_root(delta)
# 	#set_leg_stage()

# func move_with_root(_delta : float):
# 	var current_rotation : Quaternion
# 	if combat.current_camera_mode == combat.CameraMode.FREE:
# 		current_rotation = camera.get_quaternion()
# 	else:
# 		current_rotation = player.get_quaternion()
# 	var velocity : Vector3 = current_rotation * legs_animator.calculate_root_velocity()
# 	player.set_velocity(velocity)
# 	#seek_land(delta)
# 	player.move_and_slide()
extends Node
# func process_input_vector(_input : InputPackage, delta : float):
# 	if combat.current_camera_mode == combat.CameraMode.FREE:
# 		var input_direction = camera.basis.z
# 		var face_direction = player.basis.z
# 		var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
# 		var new_z = player.basis.z.rotated(Vector3.UP, clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))
# 		var new_x = -new_z.cross(Vector3.UP)
# 		player.basis = Basis(new_x, Vector3.UP, new_z).orthonormalized()
# 	else:
# 		var input_direction = combat.direction_to_target()
# 		var face_direction = player.basis.z
# 		var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
# 		var new_z = player.basis.z.rotated(Vector3.UP, clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))
# 		var new_x = -new_z.cross(Vector3.UP)
# 		player.basis = Basis(new_x, Vector3.UP, new_z).orthonormalized()


# # TODO magic numbers to blending params?
# func setup_animator(previous_action : LegsAction, _input : InputPackage):
# 	if previous_action.legs_animator == legs_animator: # ie both are LegsLocomotion of Locomotion
# 		if previous_action.action_name == "jog_loco_start":
# 			legs_animator.transition(cycle_spectre, 0)
# 		else:
# 			legs_animator.transition(cycle_spectre, 0.2)
