extends BaseSEState

## light pursuit

func check_transition(delta: float) -> Verdict:
	var aggression := traits.aggression.normalized()

	if works_longer_than(fatigue):
		print_.se_check_trans(state_name, "fatigue => idle " + str(get_progress()) + " " + str(fatigue))
		return Verdict.new(SEState.idle)

	if distance_to_player() < me.attack_distance:
		if ra.chance(aggression * 0.5):
			print_.se_check_trans(state_name, "<attack_distance => attack")
			return Verdict.new(SEState.attack)
		elif ra.chance(aggression):
			print_.se_check_trans(state_name, "<attack_distance but ra => idle")
			return Verdict.new(SEState.idle)
		else:
			print_.se_check_trans(state_name, "<attack_distance => attack")
			return Verdict.new(SEState.attack)

	if distance_to_player() > me.sight_distance:
		print_.se_check_trans(state_name, ">sight_distance => backtrack")
		return Verdict.new(SEState.backtrack)

	return Verdict.new()

func update(delta):
	var grounded_player_pos = player.global_position
	grounded_player_pos.y = me.global_position.y
	me.velocity = direction_to_(grounded_player_pos) * me.follow_speed
	look_at_player(true)
	me.move_and_slide()
