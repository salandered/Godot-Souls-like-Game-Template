extends BaseSEState


func check_transition(delta: float) -> String:
	# print("check_transition idle")
	# print(">   SPAWN ", spawn_point)
	# print("   > ", player.global_position.distance_to(spawn_point))
	# print("   > ", me.aggro_radius)
	if player.global_position.distance_to(spawn_point) < me.aggro_radius:
		return SEState.pursuit
	return me.CURRENT
