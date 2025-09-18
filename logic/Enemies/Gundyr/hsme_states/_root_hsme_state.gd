extends BaseHSMEState


func check_transition(_delta) -> VerdictHSM:
	return VerdictHSM.new("", "top layer single state, we never transition")


func choose_internal_state() -> VerdictHSM:
	return VerdictHSM.new(HSMEState.idle)
