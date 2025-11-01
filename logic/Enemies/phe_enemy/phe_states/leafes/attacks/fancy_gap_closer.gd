extends BasePHELeaf


var default_range: float = 2.5
var GAP_COEF: float
var hit_damage: float = 30
var sp_config: SpeedConfig

var angle_adjustment: float = 0 # radians


func initialise():
	default_sp.ANGULAR_SPEED = 1.0
	sp_config = SpeedConfig.new(default_sp)


func update(delta):
	e_movement.rotate_towards_player(delta, sp_config, angle_adjustment)

	if before_marker(Marker.Name_.JUMP_LAUNCH):
		e_movement.move_with_root_scaled(delta, 1.3)
	elif before_marker(Marker.Name_.LAND_START):
		e_movement.move_with_root_scaled(delta, GAP_COEF)
	else:
		e_movement.move_with_root_scaled(delta, 1.3)
	

func on_enter_state():
	GAP_COEF = distance_to_player() / default_range
	__log_ent("dist to pl/default_range/GAP_COEF", distance_to_player(), default_range, GAP_COEF)


func on_exit_state():
	deactivate_weapons()
