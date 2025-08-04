extends BaseSEState


func check_transition(delta: float) -> String:
	if me.global_position.distance_to(spawn_point) < 1:
		return SEState.idle
	return me.CURRENT


func update(delta):
	var grounded_spawn_pos = spawn_point
	grounded_spawn_pos.y = me.global_position.y
	
	me.velocity = me.global_position.direction_to(grounded_spawn_pos) * me.return_speed
	me.look_at(grounded_spawn_pos)
	me.move_and_slide()


func on_enter():
	# boosted for test purposes
	animator.speed_scale = me.return_speed / me.speed


func on_exit():
	animator.speed_scale = 1
