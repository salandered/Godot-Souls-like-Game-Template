extends BasePlayerState

# todo
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const TRANSITION_TIMING = 0.2


func _ready():
	animation = "landing_run"
	backend_animation = animation + "_params"
	state_name = PlayerState.landing_run


func default_lifecycle(input: InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		return best_input_that_can_be_paid(input)
	return "okay"

# ex
# func check_relevance(input: InputPackage):
# 	if works_longer_than(TRANSITION_TIMING):
# 		# TODO: possible input actions and states are not the same sets
# 		# seems like always false if action not in states
# 		# See also: combat system
# 		return PlayerState.prioritized(input.actions)
# 	else:
# 		return "okay"


func update(input: InputPackage, delta):
	player.velocity.y -= gravity * delta
	player.move_and_slide()
