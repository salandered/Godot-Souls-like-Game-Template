extends BasePHState


func check_transition(_delta) -> VerdictPH:
	if works_longer_than(get_animation_length()):
		return VerdictPH.new("phase_2")
	return VerdictPH.new()
