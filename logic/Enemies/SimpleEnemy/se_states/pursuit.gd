extends BaseSEState


# func check_transition(delta: float) -> SEVerdict:
# 	var aggression := traits.aggression.normalized()

# 	if works_longer_than(fatigue):
# 		print_.se_check_trans(state_name, "fatigue => idle " + str(get_progress()) + " " + str(fatigue))
# 		return SEVerdict.new(SEState.idle)

# 	if distance_to_player() < me.attack_distance:
# 		if ra.chance(aggression):
# 			print_.se_check_trans(state_name, "<attack_distance => attack")
# 			return SEVerdict.new(SEState.attack)
# 		elif ra.chance(aggression * 0.5):
# 			print_.se_check_trans(state_name, "<attack_distance but ra => idle")
# 			return SEVerdict.new(SEState.idle)
# 		else:
# 			print_.se_check_trans(state_name, "<attack_distance => attack")
# 			return SEVerdict.new(SEState.attack)

# 	if distance_to_player() > me.sight_distance:
# 		print_.se_check_trans(state_name, ">sight_distance => backtrack")
# 		return SEVerdict.new(SEState.backtrack)

# 	return SEVerdict.new()

# func update(delta):
# 	var grounded_player_pos = get_player().global_position
# 	grounded_player_pos.y = me.global_position.y
# 	me.velocity = direction_to_(grounded_player_pos) * me.pursuit_speed
# 	e_movement.look_at_player(true)
# 	me.move_and_slide()
