extends BaseSEState


@export var idle_commitment: float = 2

func check_transition(delta: float) -> String:
	if not works_longer_than(idle_commitment):
		return me.CURRENT
	if me.area_awareness.is_player_detected():
		var aggression := traits._aggression.normalized()
		if ra.chance(aggression):
			return SEState.pursuit
		elif ra.chance(aggression * 0.5): # small chance
			return SEState.follow
		else:
			return me.CURRENT
	return me.CURRENT


func update(delta):
	me.move_and_slide()