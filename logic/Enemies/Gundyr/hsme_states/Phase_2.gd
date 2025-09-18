extends BaseHSMEState


@export var pursuit_radius: float = 8
@export var scare_off_radius: float = 1.5

func check_transition(_delta):
	return VerdictHSM.new()


func choose_internal_state() -> VerdictHSM:
	return VerdictHSM.new("slash_4")
