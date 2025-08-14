# extends LegsAction

# # TODO add start-stop support

# @export var animation : String = "LocSprint/F"
# @export var tracking_angular_speed : float = 10

# func update(input : InputPackage, delta : float):
# 	process_input_vector(input, delta)
# 	move_with_root(delta)
# 	#set_leg_stage()
extends Node
# func move_with_root(_delta : float):
# 	var current_rotation = player.get_quaternion()
# 	var velocity : Vector3 = current_rotation * legs_animator.calculate_root_velocity()
# 	player.set_velocity(velocity)
# 	#seek_land(delta)
# 	player.move_and_slide()

# func process_input_vector(input : InputPackage, delta : float):
# 	var input_direction = (camera.basis * input.get_vector3()).normalized()
# 	var face_direction = player.basis.z
# 	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
# 	var new_z = player.basis.z.rotated(Vector3.UP, clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))
# 	var new_x = -new_z.cross(Vector3.UP)
# 	player.basis = Basis(new_x, Vector3.UP, new_z).orthonormalized()

# # TODO strange twitch for ine frame when switching animations
# func setup_animator(previous_action : LegsAction, _input : InputPackage):
# 	if previous_action.legs_animator == legs_animator: # ie both are simple of AnimatorModifier t
# 		legs_animator.play(animation, 0.35)
# 	else:
# 		legs_animator.play(animation, 0)
# 		legs_anim_settings.play(anim_settings, 0.35)
