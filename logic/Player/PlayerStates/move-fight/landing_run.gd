extends BasePlayerState


const TRANSITION_TIMING = 0.2

# landings aren't default-defaults, this TRANSITION_TIMING != DURATION
# DURATION is much longer, but we are releasing the priorit early
# and the rest of the animation is just for smoother blending
func default_lifecycle(input: InputPackage):
	# demonstration of innate trashyness of mixing built in is_on_floor() and advanced techs
	#if not player.is_on_floor():
		#return "midair"
	if works_longer_than(TRANSITION_TIMING):
		return best_input_that_can_be_paid(input)
	return "okay"


func update(_input: InputPackage, delta):
	player.velocity.y -= gravity * delta
	player.move_and_slide()

# ex ep 2
# func check_relevance(input: InputPackage):
# 	if works_longer_than(TRANSITION_TIMING):
# 		# TODO: possible input actions and states are not the same sets
# 		# seems like always false if action not in states
# 		# See also: combat system
# 		return PS.prioritized(input.actions)
# 	else:
# 		return "okay"
