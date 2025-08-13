extends BasePlayerState

@export var VERTICAL_SPEED_ADDED: float = 2.5

@export var DELTA_VECTOR_LENGTH = 0.05
var jump_direction: Vector3

# values based on animation jump_run
const TRANSITION_TIMING = 0.44
const JUMP_TIMING = 0.1

var jumped: bool = false



func _ready():
	#state_name = "jump_run"
	#animation = "jump_run"
	#backend_animation = animation + "_params"

	SPEED = 3.0
	

func default_lifecycle(input: InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		jumped = false
		return "midair"
	else:
		return "okay"


func update(input: InputPackage, _delta):
	process_jump()
	player.move_and_slide()


func process_jump():
	if works_longer_than(JUMP_TIMING):
		if not jumped:
			#player.velocity = player.basis.z * SPEED
			player.velocity.y += VERTICAL_SPEED_ADDED
			jumped = true


func on_enter_state():
	player.velocity = player.velocity.normalized() * SPEED

func _input(event):
	if event.is_action_released("dev_speed_up"):
		VERTICAL_SPEED_ADDED += 10
	if event.is_action_released("dev_speed_down"):
		VERTICAL_SPEED_ADDED -= 10
		
