extends PlayerState


var VERTICAL_SPEED_ADDED: float = 2.5

const TRANSITION_TIMING = 0.4
const JUMP_TIMING = 0.0657

var jumped: bool = false


func _ready():
	SPEED = 5.0

func check_transition(input: InputPackage) -> PLVerdict:
	if current_action.works_longer_than(TRANSITION_TIMING):
		jumped = false
		return PLVerdict.new(PS.midair)
	else:
		return PLVerdict.new("")


func update(input: InputPackage, delta: float) -> void:
	process_jump()

func process_jump():
	if current_action.works_longer_than(JUMP_TIMING):
		if not jumped:
			player.velocity.y += VERTICAL_SPEED_ADDED
			jumped = true


func on_enter_state(input: InputPackage) -> void:
	player.velocity = player.velocity.normalized() * SPEED


func _input(event):
	if event.is_action_released("dev_speed_up"):
		VERTICAL_SPEED_ADDED += 10
	if event.is_action_released("dev_speed_down"):
		VERTICAL_SPEED_ADDED -= 10
