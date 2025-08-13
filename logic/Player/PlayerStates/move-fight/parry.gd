extends BasePlayerState


const PARRY_WINDOW_START: float = 0.2
const PARRY_WINDOW_END: float = 1


func react_on_hit(hit: HitData):
	# overrides the on_hit method to consult its parrying windows 
	# 	and if triggered, returns the call to the sender (current_state).
	if works_between(PARRY_WINDOW_START, PARRY_WINDOW_END) and hit.is_parryable:
		hit.weapon.holder.current_state.react_on_parry(hit)
		print("parry triggered")
	else:
		super.react_on_hit(hit)
	# delete hit package to avoid memory leaks
	# hit.queue_free()


func best_input_that_can_be_paid(input: InputPackage) -> String:
	input.actions.sort_custom(container.states_priority_sort)
	for action in input.actions:
		if resources.can_be_paid(container.states[action]):
			return action
			#if container.states[action] == self:
				#return "okay"
			#else:
				#return action
	return "throwing because for some reason input.actions doesn't contain even idle"

# # TODO revisit&rethink, tech debt certainly / see Roll State
# func on_exit_state():
# 	animator.reset_torso_animation()
# 	animator.reset_legs_animation()