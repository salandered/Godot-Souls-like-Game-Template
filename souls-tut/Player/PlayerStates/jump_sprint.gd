extends BasePlayerState


const VERTICAL_SPEED_ADDED: float = 2.5

const TRANSITION_TIMING = 0.4
const JUMP_TIMING = 0.0657

var jumped: bool = false


func _ready():
	SPEED = 5.0
	TURN_SPEED = 3.2
	ANGULAR_SPEED = 13

func default_lifecycle(_input: InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		jumped = false
		return "midair"
	else:
		return "okay"


func update(_input: InputPackage, _delta: float):
	var _velocity := velocity_by_input(_input, _delta)
	rotate_player(_velocity, _delta)
	process_jump()
	player.move_and_slide()


func rotate_player(_velocity: Vector3, delta: float):
	var input_direction := _velocity.normalized()
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= ANGULAR_SPEED * delta:
		player.velocity = player.velocity.rotated(Vector3.UP, sign(angle) * ANGULAR_SPEED * delta)
		face_direction = face_direction.rotated(Vector3.UP, sign(angle) * ANGULAR_SPEED * delta)
	else:
		player.velocity = player.velocity.rotated(Vector3.UP, angle)
		face_direction = face_direction.rotated(Vector3.UP, angle)
	
	player.look_at(player.global_position - face_direction)


func process_jump():
	if works_longer_than(JUMP_TIMING):
		if not jumped:
			player.velocity.y += VERTICAL_SPEED_ADDED
			jumped = true


func on_enter_state():
	player.velocity = player.velocity.normalized() * SPEED