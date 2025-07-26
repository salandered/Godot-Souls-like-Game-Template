extends BasePlayerState


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	SPEED = 3.0
	TURN_SPEED = 2
	ANGULAR_SPEED = 13

func default_lifecycle(input: InputPackage):
	if not player.is_on_floor():
		return "midair"
	
	return best_input_that_can_be_paid(input)


func update(_input: InputPackage, _delta: float):
	var _velocity := velocity_by_input(_input, _delta)
	_velocity = rotate(_velocity, _delta)
	player.velocity = _velocity

	animator.speed_scale = player.velocity.length() / SPEED
	player.look_at(player.global_position - player.velocity)
	player.move_and_slide()


func rotate(_velocity: Vector3, delta: float):
	var face_direction := player.basis.z
	var desired_direction := _velocity.normalized()
	var angle := face_direction.signed_angle_to(desired_direction.slide(Vector3.UP), Vector3.UP)

	if abs(angle) >= ANGULAR_SPEED * delta:
		_velocity = face_direction.rotated(Vector3.UP, sign(angle) * ANGULAR_SPEED * delta) * TURN_SPEED

	return _velocity.limit_length(SPEED)

func on_exit_state():
	animator.speed_scale = 1
