extends BaseSEState


@export var death_timer: float = 5

func check_transition(delta: float) -> SEVerdict:
	if works_longer_than(death_timer):
		feelings.gain_health(feelings.max_health)
		return SEVerdict.new(SEState.idle)
	return SEVerdict.new()
