extends BasePHEState


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	return VerdictPH.new()

func update(delta):
	if time_remaining() <= 0.1:
		me.queue_free()
