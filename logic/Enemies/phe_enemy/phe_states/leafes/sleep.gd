extends BasePHState


var activated: bool = true


func check_transition(_delta) -> VerdictPH:
	if activated:
		return VerdictPH.new("awakening")
	return VerdictPH.new()
