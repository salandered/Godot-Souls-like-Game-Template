extends BaseHSMEState


func check_transition(_delta) -> VerdictHSM:
	if resources.health < 1:
		return VerdictHSM.new("death")
	return VerdictHSM.new()


func choose_internal_state() -> VerdictHSM:
	return VerdictHSM.new("phase_1")
