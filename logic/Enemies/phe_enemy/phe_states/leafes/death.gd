extends BasePHELeaf


var DECEL_SPEED = 15

func is_ended() -> bool:
	return time_remaining() <= 0.05


func update(delta):
	e_movement.smooth_xz_stop(delta, DECEL_SPEED)
