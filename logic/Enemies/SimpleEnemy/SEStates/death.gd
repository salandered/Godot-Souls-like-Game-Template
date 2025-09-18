extends BaseSEState


@export var death_timer: float = 5

func check_transition(delta: float) -> Verdict:
	if works_longer_than(death_timer):
		resources.gain_health(resources.max_health)
		return Verdict.new(SEState.idle)
	return Verdict.new()
