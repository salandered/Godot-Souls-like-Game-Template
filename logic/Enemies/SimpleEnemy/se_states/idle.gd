extends BaseSEState


func check_transition(delta: float) -> SEVerdict:
	var detect: Detection = me.awareness.detect_player()
	if detect.is_not_detected():
		# print_.se("", "not detected → idle " + me.CURRENT)
		return SEVerdict.new() # not me.CURRENT_NEW_ITER because we are ready to go anytime
	
	# -- next if detected
	var aggression := traits.aggression.normalized()
	print_.se_check_trans(state_name, "player detected and aggression is: " + str(aggression))

	if detect.is_only_heard():
		# TODO: rotating, not pursuit ...
		print_.se_check_trans(state_name, "is_only_heard => pursuit")
		return SEVerdict.new(SEState.pursuit)

	# -- next if detected and seen

	# TODO: likely follow if player is spotted but from a big distances
	if distance_to_player() > me.fight_distance:
		print_.se_check_trans(state_name, "dist to pl " + str(distance_to_player()) + " > fight dist " + str(me.fight_distance) + " => rotating and idle " + SEVerdict.CURRENT)
		# Turn towards player and remain idle
		look_at_player()
		return SEVerdict.new()

	# in fight distance
	if distance_to_player() < me.attack_distance:
		print_.se_check_trans(state_name, "too close! attack")
		return SEVerdict.new(SEState.attack)
	
	# in fight but not attack
	if ra.chance(aggression):
		print_.se_check_trans(state_name, "ra pursuit")
		# TODO: pursuit?
		return SEVerdict.new(SEState.follow)
	elif ra.chance(aggression * 0.5): # smaller chance
		print_.se_check_trans(state_name, "ra follow")
		return SEVerdict.new(SEState.follow)
	else:
		print_.se_check_trans(state_name, "ra => idle")
		return SEVerdict.new()


# func update(delta):
# 	# do we need this?
# 	me.move_and_slide()

func on_exit_state():
	pass
