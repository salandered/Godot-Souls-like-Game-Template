extends TorsoBehavior

func update(input: InputPackage, delta: float):
	current_action.update(input, delta)

func transition_logic(input: InputPackage) -> String:
	input = translate_actions_to_behaviors(input)
	return best_input_that_can_be_paid(input)
func translate_actions_to_behaviors(input: InputPackage) -> InputPackage:
	input.behavior_names.append("jog") # TODO smth like append default locomotion mode that is walk/
	input = map_with_dictionary(input, behavior_map)
	return input

# Very important TODO, I am not fixing it rn because we need some experience working with new
# Torso - Legs system, but here lies a piranha to bite our ass in the future.
# Picture we were in some kind of spell that works on jog legs base and we were in cycle at 0.5 sec
# we then go here and if left as is we switch into cycle, but we animate it from 0.
# We need something like insta-sync command for our torsos to jump to legs' progress etc.
func on_enter_behavior(input: InputPackage):
	switch_action_to("sprint", input)
