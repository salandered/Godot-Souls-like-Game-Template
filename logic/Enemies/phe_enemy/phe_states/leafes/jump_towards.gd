extends BasePHELeaf

var gap_config := GapJumpCalculator.new(0.2, 0.8, 2.6)

var sp_config: SpeedConfig


func initialise() -> void:
	TIME_REMAINING_TO_END = 0.2
	default_sp.ANGULAR_SPEED = 1.0
	sp_config = SpeedConfig.new(default_sp)


func update(delta):
	e_movement.rotate_towards_player(delta, sp_config)

	if before_marker(MarkerName.JUMP_LAUNCH):
		e_movement.move_with_root(delta)
	elif before_marker(MarkerName.LAND_START):
		e_movement.move_with_root(delta, gap_config.get_curr_coef(), true, false)
	else:
		e_movement.move_with_root(delta)
	

func on_enter_state() -> void:
	gap_config.set_coef(distance_to_player(), me.angry_raised)
	__log_ent(gap_config.__log_(distance_to_player(), me.angry_raised))