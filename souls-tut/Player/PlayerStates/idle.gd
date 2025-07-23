extends BasePlayerState


func _ready():
	animation = "idle_longsword"
	backend_animation = "idle_params"


func default_lifecycle(input) -> String:
	if not player.is_on_floor():
		return "midair"
	
	if has_queued_state and resources.can_be_paid(player.model.moves[queued_state]):
		has_queued_state = false
		return queued_state
	
	return best_input_that_can_be_paid(input)


func on_enter_state():
	player.velocity = Vector3.ZERO
