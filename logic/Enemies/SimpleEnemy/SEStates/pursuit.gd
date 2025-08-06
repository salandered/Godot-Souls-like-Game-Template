extends BaseSEState


func check_transition(delta: float) -> String:
	var aggression := traits.aggression.normalized()

	if works_longer_than(fatigue):
		print_.prefix("SE", "pursuit decision: fatigue => idle         " + str(get_progress()) + "      " + str(fatigue))
		return SEState.idle

	if distance_to_player() < me.attack_distance:
		if ra.chance(aggression):
			print_.prefix("SE", "pursuit decision: <attack_distance => attack")
			return SEState.attack
		elif ra.chance(aggression * 0.5):
			print_.prefix("SE", "pursuit decision: <attack_distance but ra => idle")
			return SEState.idle
		else:
			print_.prefix("SE", "pursuit decision: <attack_distance => attack")
			return SEState.attack

	if distance_to_player() > me.sight_distance:
		print_.prefix("SE", "pursuit decision: >sight_distance => backtrack")
		return SEState.backtrack

	return me.CURRENT

func update(delta):
	var grounded_player_pos = player.global_position
	grounded_player_pos.y = me.global_position.y
	me.velocity = direction_to_(grounded_player_pos) * me.pursuit_speed
	u.safe_look_at(me, grounded_player_pos)
	me.move_and_slide()
