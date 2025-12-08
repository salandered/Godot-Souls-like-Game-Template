extends BasePHELeaf


var DECEL_SPEED := 15.0


func is_ended() -> bool:
	return time_remaining() <= 0.2


func update(delta: float):
	e_movement.smooth_xz_stop(delta, DECEL_SPEED)

	if passed_marker(MarkerName.DEATH_SCATTER):
		me.death_raised = true
