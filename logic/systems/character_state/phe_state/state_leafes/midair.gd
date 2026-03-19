extends BasePHELeaf


func initialize() -> void:
	pass
	
	# default_sp.ANGULAR_SPEED = 2.0


func on_enter_state() -> void:
	APPLY_GRAVITY = false


func on_exit_state() -> void:
	APPLY_GRAVITY = true


func is_ended() -> bool:
	if me.get_area_awareness().is_almost_on_floor() or me.get_area_awareness().is_on_floor():
		return true
	return false


func update(delta: float) -> void:
	# e_movement.rotate_towards_player(delta, SpeedConfig.new(default_sp))
	e_movement.apply_gravity(delta, 1.5)
