extends BasePHELeaf


var DECEL_SPEED: float = 11

var angular_accel := FloatLinearInterpolator.new()


var _resettable := [
	angular_accel,
]

func initialise() -> void:
	default_sp.ANGULAR_SPEED = 1.5


func on_enter_state() -> void:
	y_offset_adjustment = -0.03
	if not me.angry_raised:
		if dist_to_player_greater(config.CLOSE_TO_ORBIT() - 1.0) and ra.chance(0.4):
			anim = anim_container.get_by_anim_id(PHEA.loco.combat_idle_stupid)
			default_sp.ANGULAR_SPEED = 1.4 - 0.8
		else:
			anim = anim_container.get_by_anim_id(PHEA.loco.combat_idle)
			default_sp.ANGULAR_SPEED = 2 - 0.8
	else:
		if dist_to_player_greater(config.CLOSE_TO_ORBIT()) and ra.chance(0.8):
			anim = anim_container.get_by_anim_id(PHEA.phase_switch_loop)
			y_offset_adjustment = -0.3
			default_sp.ANGULAR_SPEED = 1.5 - 0.8
		else:
			anim = anim_container.get_by_anim_id(PHEA.loco.combat_idle)
			default_sp.ANGULAR_SPEED = 2 - 0.8

	angular_accel.initialise(0.2, default_sp.ANGULAR_SPEED, 0.5)


func on_exit_state() -> void:
	u.reset_all(_resettable)
	get_animator_manager().reset_global_speed_scale()

func update(delta):
	var CURR_ANGULAR_SPEED := default_sp.ANGULAR_SPEED
	CURR_ANGULAR_SPEED = angular_accel.update(delta)
	
	e_movement.rotate_towards_player(delta, SpeedConfig.new(default_sp, 1.0, -1.0, CURR_ANGULAR_SPEED))
	e_movement.smooth_xz_stop(delta, DECEL_SPEED)
