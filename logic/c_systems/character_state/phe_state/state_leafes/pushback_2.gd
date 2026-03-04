extends BasePHELeaf


var sp_config: SpeedConfig

var SCALE_LENGTH := 1.0


func initialize() -> void:
	sp_config = SpeedConfig.new(default_sp)


func update(delta: float):
	e_movement.rotate_towards_player(delta, sp_config)
	e_movement.move_with_root(delta, SCALE_LENGTH)
