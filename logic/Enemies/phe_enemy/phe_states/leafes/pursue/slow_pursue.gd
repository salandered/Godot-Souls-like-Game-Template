extends BasePHEPursue


func initialise() -> void:
	default_sp.SPEED = 1.7
	default_sp.ANGULAR_SPEED = 2.5
	
	accel_from_idle_time = 0.3
	
	blend_time.set_by_prev_action({
		PHEState.Leaf.awaken: 0.3
	})
