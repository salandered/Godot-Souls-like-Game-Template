extends BasePHEState
class_name BasePHEPursue

var speed_from_inherited := FloatLinearInterpolator.new()

var accel_from_idle_time: float = 0.5

func initialise() -> void:
	default_sp.SPEED = 5.5
	default_sp.ANGULAR_SPEED = 3

	blend_time.set_by_prev_action({
		PHEState.Leaf.awaken: 0.3
	})


func on_enter_state():
	var _inherited_speed := e_movement.get_curr_velocity_len()
	__log_ent("_inherited_speed", _inherited_speed, "would be _inherited_speed -> ", default_sp.SPEED)
	speed_from_inherited.initialise(_inherited_speed, default_sp.SPEED, accel_from_idle_time)


func on_exit_state():
	get_animator_manager().reset_global_speed_scale()


func update(delta: float):
	var CURR_SPEED = speed_from_inherited.update(delta)

	var speed_config := SpeedConfig.new(default_sp, 1.0, CURR_SPEED)
	
	e_movement.move_rotate_towards_player(delta, speed_config)
	
	get_animator_manager().set_global_speed_scale(e_movement.get_curr_velocity_len() / CURR_SPEED)
