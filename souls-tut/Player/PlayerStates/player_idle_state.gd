extends BasePlayerState
class_name PlayerIdleState


func _ready():
	animation = "idle"


func check_relevance(input) -> String:
	input.actions.sort_custom(states_priority_sort)
	return input.actions[0]


func on_enter_state():
	player.velocity = Vector3.ZERO


# extends PlayerBaseState
# class_name PlayerIdleState


# func check_relevance(input_data: InputData) -> String:
# 	input_data.actions.sort_custom(sort_states_by_priorities)
# 	return input_data.actions[0]
