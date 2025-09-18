extends BaseHSMEState


func check_transition(_delta) -> VerdictHSM:
	if works_longer_than(get_animation_length()):
		return VerdictHSM.new("phase_2")
	return VerdictHSM.new()
