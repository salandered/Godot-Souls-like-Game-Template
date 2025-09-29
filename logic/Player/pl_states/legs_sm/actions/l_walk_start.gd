extends LegsAction

var ANGULAR_SPEED: float = 4

func _ready() -> void:
	SPEED_SCALE = 1.5

func on_enter_action(_input: InputPackage) -> void:
	# 🚧
	legs_sm.full_body_animator.set_global_speed_scale(SPEED_SCALE)

func on_exit_action() -> void:
	# 🚧
	legs_sm.full_body_animator.reset_global_speed_scale()


func update(input: InputPackage, delta: float):
	process_input_vector(input, delta)
	move_with_root(delta)


func process_input_vector(input: InputPackage, delta: float):
	var input_direction := velocity_by_input(input, delta).normalized()
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= ANGULAR_SPEED * delta:
		player.rotate_y(sign(angle) * ANGULAR_SPEED * delta)
	else:
		player.rotate_y(angle)

func move_with_root(delta: float) -> void:
	# 🚧
	var root_vel := legs_sm.full_body_animator.get_root_velocity()
	player.velocity = player.get_quaternion() * root_vel
