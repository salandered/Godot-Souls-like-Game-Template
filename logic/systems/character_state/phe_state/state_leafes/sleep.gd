extends BasePHELeaf


func update(delta):
	e_movement.smooth_xz_stop(delta, 15)
