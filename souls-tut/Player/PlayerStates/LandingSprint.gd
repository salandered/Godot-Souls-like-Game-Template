extends BasePlayerState
class_name LandingSprintState

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	animation = "landing_sprint"
	state_name = "landing_sprint"


func check_relevance(input: InputPackage):
	if get_progress() >= 0.2:
		input.actions.sort_custom(states_priority_sort)
		return input.actions[0]
	else:
		return "okay"


func update(input: InputPackage, delta):
	player.velocity.y -= gravity * delta
	player.move_and_slide()
