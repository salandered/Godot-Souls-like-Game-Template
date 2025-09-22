extends PlayerState

@export var VERTICAL_SPEED_ADDED: float = 2.5

@export var DELTA_VECTOR_LENGTH = 0.05
var jump_direction: Vector3

# values based on animation jump_run
const TRANSITION_TIMING = 0.44
const JUMP_TIMING = 0.1

var jumped: bool = false


func _ready() -> void:
	#state_name = "jump_run"
	#animation = "jump_run"
	#backend_animation = animation + "-param"
	SPEED = 3.0

func check_transition(input: InputPackage) -> PLVerdict:
	if current_action.works_longer_than(TRANSITION_TIMING):
		jumped = false
		return PLVerdict.new(PS.midair)
	else:
		return PLVerdict.new("")

func on_enter_state(input: InputPackage) -> void:
	player.velocity = player.velocity.normalized() * SPEED

func update(input: InputPackage, delta: float) -> void:
	process_jump()

func process_jump() -> void:
	if current_action.works_longer_than(JUMP_TIMING):
		if not jumped:
			#player.velocity = player.basis.z * SPEED
			player.velocity.y += VERTICAL_SPEED_ADDED
			jumped = true

func _input(event) -> void:
	if event.is_action_released("dev_speed_up"):
		VERTICAL_SPEED_ADDED += 10
	if event.is_action_released("dev_speed_down"):
		VERTICAL_SPEED_ADDED -= 10
