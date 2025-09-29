extends LegsAction

@export var tracking_angular_speed: float = 10

func _ready():
	SPEED = 5.0
	TURN_SPEED = 3.2


func update(input: InputPackage, delta: float):
	process_input_vector(input, delta)


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
	# 🚧
	legs_sm.full_body_animator.set_global_speed_scale(player.velocity.length() / SPEED)

func _input(event):
	if event.is_action_released("dev_speed_up"):
		SPEED += 6
	if event.is_action_released("dev_speed_down"):
		SPEED -= 6

func on_exit_action():
	# 🚧
	legs_sm.full_body_animator.reset_global_speed_scale()