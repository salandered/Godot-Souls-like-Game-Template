extends BaseSEState


func check_transition(delta: float) -> String:
	if me.global_position.distance_to(spawn_point) < 2:
		print_.se("", "backtrack decision: reached spawn point, idle")
		return SEState.idle
	return me.CURRENT


func update(delta):
	# Move towards spawn_point, keeping movement on the horizontal plane
	var target_pos := spawn_point
	target_pos.y = me.global_position.y
	var to_spawn := target_pos - me.global_position
	if to_spawn.length() > 0.2:
		me.velocity = to_spawn.normalized() * me.backtrack_speed
	else:
		me.velocity = Vector3.ZERO
	u.safe_look_at(me, target_pos)
	me.move_and_slide()


func on_enter_state():
	# boosted for test purposes
	# animator.speed_scale = me.return_speed / me.pursuit_speed
	pass


func on_exit_state():
	# animator.speed_scale = 1
	pass
