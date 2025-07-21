extends BasePlayerState
class_name Slash2State


const TRANSITION_TIMING = 0.65
const COMBO_TIMING = 0.6


func _ready():
	animation = "slash_2"
	state_name = "slash_2"


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
