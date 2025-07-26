extends BasePlayerState

@export var VERTICAL_SPEED_ADDED: float = 2.5

@export var DELTA_VECTOR_LENGTH = 0.05
var jump_direction: Vector3

# values based on animation jump_run
const TRANSITION_TIMING = 0.44
const JUMP_TIMING = 0.1

var jumped: bool = false

func _ready():
	state_name = "jump_run"
	animation = "jump_run"
	backend_animation = animation + "_params"

	SPEED = 3.0
	TURN_SPEED = 2
	ANGULAR_SPEED = 7
	

func default_lifecycle(_input: InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		jumped = false
		return "midair"
	else:
		return "okay"


func update(_input: InputPackage, _delta):
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