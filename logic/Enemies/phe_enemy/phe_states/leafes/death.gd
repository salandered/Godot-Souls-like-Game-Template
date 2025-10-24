extends BasePHState


func check_transition(_delta) -> VerdictPH:
	return VerdictPH.new()

func update(_delta):
	if close_to_the_end_of_animation():
		me.queue_free()
