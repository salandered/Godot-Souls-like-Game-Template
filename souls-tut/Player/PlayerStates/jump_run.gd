extends BasePlayerState
class_name JumpRunState

const VERTICAL_SPEED_ADDED: float = 2.5

# values based on animation jump_run
const TRANSITION_TIMING = 0.44
const JUMP_TIMING = 0.1

var jumped: bool = false

func _ready():
	animation = "jump_run"
	state_name = "jump_run"


func check_relevance(_input: InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		jumped = false
		return "midair"
	else:
		return "okay"


func update(_input: InputPackage, delta):
	if works_longer_than(JUMP_TIMING):
		if not jumped:
			player.velocity.y += VERTICAL_SPEED_ADDED
			jumped = true
	player.move_and_slide()


# func check_relevance(input_data: InputData):
# 	if player.is_on_floor():
# 		input_data.actions.sort_custom(sort_states_by_priorities)
# 		# todo check length
# 		return input_data.actions[0]
# 	# todo return something sane
# 	return "jump"
