extends BasePHELeaf


var decel_speed: float = 9


func initialise() -> void:
	default_sp.ANGULAR_SPEED = 2


func on_enter_state() -> void:
	if dist_to_player_greater(config.CLOSE_TO_ORBIT()) and ra.chance(0.4):
		anim = anim_container.get_by_anim_id(PHEA.loco.combat_idle_stupid)
		default_sp.ANGULAR_SPEED = 1.5
	else:
		anim = anim_container.get_by_anim_id(PHEA.loco.combat_idle)
		default_sp.ANGULAR_SPEED = 2


func update(delta):
	e_movement.rotate_towards_player(delta, SpeedConfig.new(default_sp))
	smooth_stop(delta)


func smooth_stop(delta):
	var horizontal_vel := Vector3(me.velocity.x, 0, me.velocity.z)
	
	horizontal_vel = horizontal_vel.move_toward(Vector3.ZERO, decel_speed * delta)
	
	me.velocity.x = horizontal_vel.x
	me.velocity.z = horizontal_vel.z