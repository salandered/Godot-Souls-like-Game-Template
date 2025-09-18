extends BaseHSMEState


func check_transition(_delta) -> VerdictHSM:
	return VerdictHSM.new()

func update(_delta):
	if close_to_the_end_of_animation():
		me.queue_free()
