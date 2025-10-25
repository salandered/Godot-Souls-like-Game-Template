extends BasePHEPursue


func initialise() -> void:
	default_sp.SPEED = 5.5
	default_sp.ANGULAR_SPEED = 2
	
	accel_from_idle_time = 0.5

	blend_time.set_by_prev_action({
		PHEState.Leaf.awaken: 0.3
	})
