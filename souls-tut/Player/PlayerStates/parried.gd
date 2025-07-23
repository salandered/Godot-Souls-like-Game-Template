extends BasePlayerState


const ANIMATION_END: float = 3


func _ready():
	animation = "parried"
	backend_animation = animation + "_params"
	state_name = PlayerState.parried
	
func default_lifecycle(input: InputPackage):
	if works_longer_than(ANIMATION_END):
		return best_input_that_can_be_paid(input)
	return "okay"


func on_enter_state():
	player.add_to_group("parried_humanoid")


func on_exit_state():
	player.remove_from_group("parried_humanoid")
