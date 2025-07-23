extends BasePlayerState


const PARRY_WINDOW_START: float = 0.2
const PARRY_WINDOW_END: float = 1

const ANIMATION_END: float = 1.3667

func _ready():
	animation = "parry"
	backend_animation = animation + "_params"
	state_name = PlayerState.parry

func default_lifecycle(input: InputPackage):
	if works_longer_than(ANIMATION_END):
		if has_queued_state and resources.can_be_paid(player.model.states[queued_state]):
			has_queued_state = false
			return queued_state
		return best_input_that_can_be_paid(input)
	return "okay"


func react_on_hit(hit: HitData):
	# overrides the on_hit method to consult its parrying windows 
	# 	and if triggered, returns the call to the sender (current_state).
	if works_between(PARRY_WINDOW_START, PARRY_WINDOW_END) and hit.is_parryable:
		hit.weapon.holder.current_state.react_on_parry(hit)
		print("parry triggered")
	else:
		try_force_state("staggered")
	# delete hit package to avoid memory leaks
	hit.queue_free()
