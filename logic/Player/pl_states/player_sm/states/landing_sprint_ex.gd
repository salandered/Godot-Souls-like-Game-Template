extends PlayerState


const TRANSITION_TIMING = 0.2

# landings aren't default-defaults, this TRANSITION_TIMING != DURATION
# DURATION is much longer, but we are releasing the priorit early
# and the rest of the animation is just for smoother blending
func check_transition(input: InputPackage) -> PLVerdict:
	if current_action.works_longer_than(TRANSITION_TIMING):
		return best_next_state_from_input(input)
	return PLVerdict.new("")


func update(_input: InputPackage, delta):
	player.velocity.y -= u.gravity * delta
