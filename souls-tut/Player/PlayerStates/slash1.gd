extends BasePlayerState
class_name Slash1State


const COMBO_TIMING = 0.97
const TRANSITION_TIMING = 1.1333


func _ready():
	animation = "slash_1"
	state_name = "slash_1"


func check_relevance(input: InputPackage):
	check_combos(input)
	if works_longer_than(COMBO_TIMING) and has_queued_state:
		has_queued_state = false
		return queued_state
	elif works_longer_than(TRANSITION_TIMING):
		input.actions.sort_custom(states_priority_sort)
		return input.actions[0]
	else:
		return "okay"


func on_enter_state():
	player.velocity = Vector3.ZERO
