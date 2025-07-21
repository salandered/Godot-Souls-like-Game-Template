extends BasePlayerState
class_name LandingRunState

# todo
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const TRANSITION_TIMING = 0.2


func _ready():
	animation = "landing_run"
	state_name = PlayerState.landing_run


func check_relevance(input: InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		# todo: possible input actions and states are not the same sets
		# possible critical bugs
		# seems like always false if action not in states
		input.actions.sort_custom(states_priority_sort)
		return input.actions[0]
	else:
		return "okay"


func update(input: InputPackage, delta):
	player.velocity.y -= gravity * delta
	player.move_and_slide()
