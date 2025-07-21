extends BasePlayerState
class_name Slash3State


const TRANSITION_TIMING = 1.96


func _ready():
	animation = "slash_3"
	state_name = "slash_3"


func check_relevance(input: InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		input.actions.sort_custom(states_priority_sort)
		return input.actions[0]
	else:
		return "okay"
