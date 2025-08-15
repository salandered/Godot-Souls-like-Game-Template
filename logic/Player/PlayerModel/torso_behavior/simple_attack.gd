extends TorsoBehavior

@export var tracking_angular_speed: float = 10
@export var releases_priority: float
@export var animation: String

var double_action: LegsAction
func transition_logic(input: InputPackage) -> String:
	input = translate_actions_to_behaviors(input)
	var best_input = best_input_that_can_be_paid(input)
	if current_action.acts_longer_than(releases_priority):
		if current_action.animation_ended() or input.input_actions.has("move"):
			return best_input
	return "okay"

func translate_actions_to_behaviors(input: InputPackage) -> InputPackage:
	input = map_with_dictionary(input, behavior_map)
	input.behavior_names.append("jog")
	input = map_with_combos(input)
	return input

func update(_input: InputPackage, _delta: float):
	pass

func update_legs(input: InputPackage, delta: float):
	process_input_vector(input, delta)
	move_with_root(delta)

func process_input_vector(input: InputPackage, delta: float):
	...
