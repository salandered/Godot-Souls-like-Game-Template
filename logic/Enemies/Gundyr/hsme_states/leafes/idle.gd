extends BaseHSMEState


var activated: bool = false


func check_transition(_delta) -> VerdictHSM:
	if activated:
		return VerdictHSM.new("awakening")
	return VerdictHSM.new()


func _unhandled_input(event):
	if event.is_action_pressed("awake Gundyr"):
		activated = true
