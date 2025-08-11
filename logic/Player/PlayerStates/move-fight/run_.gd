extends BasePlayerState


func _ready():
	SPEED = 3.0
	TURN_SPEED = 2

func default_lifecycle(input: InputPackage):
	if not player.is_on_floor():
		return "midair"
	
	return best_input_that_can_be_paid(input)


func update(input: InputPackage, _delta: float):
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
	# _velocity.limit_length(SPEED) ?
	animator.set_speed_scale(player.velocity.length() / SPEED)

# prev 
# func rotate(_velocity: Vector3, delta: float):
# 	var face_direction := player.basis.z
# 	var desired_direction := _velocity.normalized()
# 	var angle := face_direction.signed_angle_to(desired_direction.slide(Vector3.UP), Vector3.UP)
# 	if abs(angle) >= ANGULAR_SPEED * delta:
# 		_velocity = face_direction.rotated(Vector3.UP, sign(angle) * ANGULAR_SPEED * delta) * TURN_SPEED
# 	return _velocity.limit_length(SPEED)
# endregion

func on_exit_state():
	animator.set_speed_scale(1)


func _input(event):
	if event.is_action_released("dev_speed_up"):
		SPEED += 10
	if event.is_action_released("dev_speed_down"):
		SPEED -= 10