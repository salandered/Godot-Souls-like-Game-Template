extends BasePHELeaf


var DECEL_SPEED: float = 11


func initialise() -> void:
	default_sp.ANGULAR_SPEED = 0.1


func on_exit_state() -> void:
	get_animator_manager().reset_global_speed_scale()


func update(delta):
	e_movement.rotate_towards_player(delta, SpeedConfig.new(default_sp))
	e_movement.smooth_xz_stop(delta, DECEL_SPEED)
