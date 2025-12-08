extends BasePHELeaf


func update(delta: float):
	e_movement.smooth_xz_stop(delta, 15)
