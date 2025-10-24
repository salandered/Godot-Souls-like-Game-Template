extends BasePHState


func check_transition(_delta) -> VerdictPH:
	return VerdictPH.new("", PHEState.life + " is never being transitioned")


func choose_internal_state() -> VerdictPH:
	var _state = PHEState.life
	__log_phe_choose(_state, "(from root state)")
	return VerdictPH.new(_state)
