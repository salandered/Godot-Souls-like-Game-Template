extends BasePlayerState

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var sprint_stamina_cost = 20 # per sec so multiply by delta


func _ready():
	animation = "sprint"
	backend_animation = animation + "_params"
	state_name = PlayerState.sprint
	
	
func default_lifecycle(input: InputPackage):
	if not player.is_on_floor():
		return "midair"
	
	return best_input_that_can_be_paid(input)


func update(input: InputPackage, delta: float):
	# loses stamina and self-exits if run out of it
	resources.lose_stamina(sprint_stamina_cost * delta)
	if resources.stamina < sprint_stamina_cost * delta:
		try_force_state("run")
	player.velocity = velocity_by_input(input, delta)
	player.look_at(player.global_position - player.velocity)
	player.move_and_slide()