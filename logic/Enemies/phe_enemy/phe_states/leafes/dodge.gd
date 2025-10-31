extends BasePHELeaf


var angle_adjustment: float = 0 # radians

var sp_config: SpeedConfig


func is_ended() -> bool:
	return time_remaining() < 0.2


func initialise() -> void:
	default_sp.ANGULAR_SPEED = 1
	sp_config = SpeedConfig.new(default_sp)


func update(delta):
	e_movement.rotate_towards_player(delta, sp_config, angle_adjustment)
	e_movement.move_with_root(delta)
