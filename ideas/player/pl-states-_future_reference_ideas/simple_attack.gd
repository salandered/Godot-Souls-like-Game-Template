extends BasePlayerState

@export var releases_priority: float
@export var animation: String

var double_action: LegsAction


# SIMPLE ATTACK IS USED FOR REFERENCE FOR NOW


# this was in player state (_base)
# func map_with_combos(input_) -> InputPackage:
# 	for combo in combos:
# 		combo.map(input_)
# 	return input


# func transition_logic(input_: InputPackage) -> String:
# 	# input = translate_actions_to_behaviors(input_)
# 	# var best_input = best_input_that_can_be_paid(input_)
# 	# if current_action.acts_longer_than(releases_priority):
# 	# 	if current_action.animation_ended() or input_.actions.has("move"):
# 	# 		return best_input
# 	return PLVerdict.new("")

# func translate_actions_to_behaviors(input_: InputPackage) -> InputPackage:
# 	input.behavior_names.append("run")
# 	input = map_with_combos(input_)
# 	return input

# func update(input_: InputPackage, _delta: float):
# 	pass

# func update_legs(input_: InputPackage, delta: float):
# 	process_input_vector(input_, delta)
# 	# move_with_root(delta)

# func process_input_vector(input_: InputPackage, delta: float):
# 	# FILL ME if you want state-side aiming/turning for attacks.
# 	pass

# func on_enter_behavior(input_: InputPackage):
# 	switch_action_to("...", input)
