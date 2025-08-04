extends BaseSEState


func check_transition(delta: float) -> String:
	if player.global_position.distance_to(me.global_position) < me.attack_radius:
		return SEState.attack
	if player.global_position.distance_to(spawn_point) > me.deaggro_radius:
		return SEState.backtrack
	return me.CURRENT


func update(delta):
	var grounded_player_pos = player.global_position
	grounded_player_pos.y = me.global_position.y
	
	me.velocity = me.global_position.direction_to(grounded_player_pos) * me.speed
	me.look_at(grounded_player_pos)
	me.move_and_slide()
