extends BaseHSMEState


var phase_switch_hp_treshold := 0.5 # % of maximum


func check_transition(_delta) -> VerdictHSM:
	if resources.health < resources.max_health * phase_switch_hp_treshold:
		return VerdictHSM.new("phase_switch")
	return VerdictHSM.new()


func choose_internal_state() -> VerdictHSM:
	return VerdictHSM.new("chill_1")
