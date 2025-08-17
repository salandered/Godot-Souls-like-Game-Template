extends PlayerState

@export var releases_priority: float
@export var animation: String

var double_action: LegsAction


# SIMPLE ATTACK IS USED FOR REFERENCE FOR NOW


# this was in torso state (_base)
# func map_with_combos(input) -> InputPackage:
# 	for combo in combos:
# 		combo.map(input)
# 	return input


# func transition_logic(input: InputPackage) -> String:
# 	# input = translate_actions_to_behaviors(input)
# 	# var best_input = best_input_that_can_be_paid(input)
# 	# if current_action.acts_longer_than(releases_priority):
# 	# 	if current_action.animation_ended() or input.actions.has("move"):
# 	# 		return best_input
# 	return "okay"

# func translate_actions_to_behaviors(input: InputPackage) -> InputPackage:
# 	input.behavior_names.append("run")
# 	input = map_with_combos(input)
# 	return input

# func update(_input: InputPackage, _delta: float):
# 	pass

# func update_legs(input: InputPackage, delta: float):
# 	process_input_vector(input, delta)
# 	# move_with_root(delta)

# func process_input_vector(input: InputPackage, delta: float):
# 	# FILL ME if you want state-side aiming/turning for attacks.
# 	pass

# func on_enter_behavior(input: InputPackage):
# 	switch_action_to("...", input)
