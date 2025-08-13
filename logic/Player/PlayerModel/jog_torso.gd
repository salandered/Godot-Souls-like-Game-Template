# extends TorsoBehaviour

# ## we have a torso state called jog, and it uses the legs behaviour called jog_legs. 
# # legs beh - attached JogLegs
# # name - jog

extends Node
# func update(input : InputPackage, delta : float):
# 	choose_action(input)
# 	current_action.update(input, delta)

# # we are but a parrot state
# func choose_action(input : InputPackage):
# 	if current_action.action_name != legs.current_action.action_name:
# 		switch_action_to(legs.current_action.action_name, input)

# func transition_logic(input : InputPackage) -> String:
# 	input = translate_actions_to_behaviours(input)
# 	return best_input_that_can_be_paid(input)

# func translate_actions_to_behaviours(input : InputPackage) -> InputPackage:
# 	input.behaviour_names.append("jog") # TODO smth like append default locomotion mode that is walk/
# 	input = map_with_dictionary(input, behaviour_map)
# 	return input

# # Very important TODO, I am not fixing it rn because we need some experience working with new
# # Torso - Legs system, but here lies a piranha to bite our ass in the future.
# # Picture we are in some kind of spell that works on jog legs base and we were in cycle at 0.5 sec
