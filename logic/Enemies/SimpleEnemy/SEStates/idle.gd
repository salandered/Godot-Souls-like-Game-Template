extends BaseSEState


func check_transition(delta: float) -> Verdict:
	var detect: Detection = me.awareness.detect_player()
	if detect.is_not_detected():
		# print_.se("", "not detected → idle " + me.CURRENT)
		return Verdict.new() # not me.CURRENT_NEW_ITER because we are ready to go anytime
	
	# -- next if detected
	var aggression := traits.aggression.normalized()
	print_.se_check_trans(state_name, "player detected and aggression is: " + str(aggression))

	if detect.is_only_heard():
		# TODO: rotating, not pursuit ...
		print_.se_check_trans(state_name, "is_only_heard => pursuit")
		return Verdict.new(SEState.pursuit)

	# -- next if detected and seen

	# TODO: likely follow if player is spotted but from a big distances
	if distance_to_player() > me.fight_distance:
		print_.se_check_trans(state_name, "dist to pl " + str(distance_to_player()) + " > fight dist " + str(me.fight_distance) + " => rotating and idle " + me.CURRENT)
		# Turn towards player and remain idle
		look_at_player()
		return Verdict.new()

	# in fight distance
	if distance_to_player() < me.attack_distance:
		print_.se_check_trans(state_name, "too close! attack")
		return Verdict.new(SEState.attack)
	
	# in fight but not attack
	if ra.chance(aggression):
		print_.se_check_trans(state_name, "ra pursuit")
		# TODO: pursuit?
		return Verdict.new(SEState.follow)
	elif ra.chance(aggression * 0.5): # smaller chance
		print_.se_check_trans(state_name, "ra follow")
		return Verdict.new(SEState.follow)
	else:
		print_.se_check_trans(state_name, "ra => idle")
		return Verdict.new()


# func update(delta):
# 	# do we need this?
# 	me.move_and_slide()

func on_exit_state():
	pass
