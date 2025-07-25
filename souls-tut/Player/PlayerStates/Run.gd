extends BasePlayerState

const SPEED = 3.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func default_lifecycle(input: InputPackage):
	if not player.is_on_floor():
		return "midair"
	
	return best_input_that_can_be_paid(input)


func update(input: InputPackage, delta: float):
	player.velocity = velocity_by_input(input, delta)
	player.look_at(player.global_position - player.velocity)
	player.move_and_slide()
