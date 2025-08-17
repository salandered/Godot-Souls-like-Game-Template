extends BasePlayerState


func _ready() -> void:
	SPEED = 1.5
	TURN_SPEED = 1

func check_transition(input: InputPackage):
	if not player.is_on_floor():
		return "midair"
	
	return best_input_that_can_be_paid(input)


func update(_input: InputPackage, _delta: float):
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
