extends BaseSEState


@export var death_timer: float = 5
var commitment = 5

func check_transition(delta: float) -> String:
	if not works_longer_than(commitment):
		return me.CURRENT
	if works_longer_than(death_timer):
		resources.gain_health(resources.max_health)
		return SEState.idle
	return me.CURRENT
