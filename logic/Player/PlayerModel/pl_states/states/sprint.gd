extends PlayerState

func update(input: InputPackage, delta: float):
	current_action.update(input, delta)

func transition_logic(input: InputPackage) -> String:
	return best_input_that_can_be_paid(input)


# Very important TODO, I am not fixing it rn because we need some experience working with new
# Torso - Legs system, but here lies a piranha
# Picture we were in some kind of spell that works on run legs base and we were in cycle at 0.5 sec
# we then go here and if left as is we switch into cycle, but we animate it from 0.
# We need something like insta-sync command for our torsos to jump to legs' progress etc.
func on_enter_behavior(input: InputPackage):
	switch_action_to(PS.action_sprint, input)
