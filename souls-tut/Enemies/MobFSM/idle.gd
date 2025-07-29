extends AIState


func check_transition(delta) -> Array:
	# print("check_transition idle")
	# print(">   SPAWN ", spawn_point)
	# print("   > ", player.global_position.distance_to(spawn_point))
	# print("   > ", character.aggro_radius)
	if player.global_position.distance_to(spawn_point) < character.aggro_radius:
		return [true, "pursuit"]
	return [false, ""]
