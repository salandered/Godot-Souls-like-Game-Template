extends BaseSEState


@export var death_timer: float = 3


func check_transition(delta: float) -> String:
	if works_longer_than(death_timer):
		resources.gain_health(resources.max_health)
		return SEState.idle # interesting question, idle or returning or teleport, but that's up to you
	return me.CURRENT
