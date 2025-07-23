extends BasePlayerState

# Step 3: navigate to Model and add a new state to states dictionary
# Step 4: navigate to base State and add this new state to priority dictionary

const ANIMATION_END: float = 3


func _ready():
	animation = "death"
	backend_animation = animation + "_params"
	state_name = PlayerState.death

func default_lifecycle(_input: InputPackage):
	if works_longer_than(ANIMATION_END):
		return "idle"
	return "okay"


func update(_input: InputPackage, _delta):
	pass


func on_enter_state():
	pass

func on_exit_state():
	resources.gain_health(987651468)
