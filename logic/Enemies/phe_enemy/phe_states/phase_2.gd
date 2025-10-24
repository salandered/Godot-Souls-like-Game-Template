extends BasePHState


var pursuit_radius: float = 8
var scare_off_radius: float = 1.5

func check_transition(_delta):
	return VerdictPH.new()


func choose_internal_state() -> VerdictPH:
	return VerdictPH.new("slash_4")
