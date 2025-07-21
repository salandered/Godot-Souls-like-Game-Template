extends BasePlayerState
class_name RunState


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	animation = "run"
	state_name = PlayerState.run


func check_relevance(input: InputPackage):
	if not player.is_on_floor():
		return "midair"
	
	input.actions.sort_custom(states_priority_sort)
	if input.actions[0] == "run":
		return "okay"
	return input.actions[0]


func update(input: InputPackage, delta: float):
	player.velocity = velocity_by_input(input, delta)
	player.look_at(player.global_position - player.velocity)
	player.move_and_slide()
