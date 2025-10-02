extends LegsAction

var ANGULAR_SPEED: float = 4


func on_exit_action() -> void:
	var final_rm_speed = animator_manager.get_root_velocity().length()
	legs_sm.transfer_data.fill(action_name, {"rm_speed": final_rm_speed})


func update(input: InputPackage, delta: float):
	process_input_vector(input, delta)
	_move_with_root(delta)


func process_input_vector(input: InputPackage, delta: float):
	var input_direction := velocity_by_input(input, delta).normalized()
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= ANGULAR_SPEED * delta:
		player.rotate_y(sign(angle) * ANGULAR_SPEED * delta)
	else:
		player.rotate_y(angle)

func _move_with_root(delta: float) -> void:
	var root_vel := animator_manager.get_root_velocity()
	player.velocity = player.get_quaternion() * root_vel
