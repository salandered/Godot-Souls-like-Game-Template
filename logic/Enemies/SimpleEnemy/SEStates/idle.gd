extends BaseSEState


var __detected := false

func check_transition(delta: float) -> String:
	var detect := me.awareness.detect_player()
	if detect.is_not_detected():
		# print_.se("", "idle decision: not detected → idle " + me.CURRENT)
		return me.CURRENT # not me.CURRENT_NEW_ITER because we are ready to go anytime
	

	if not __detected:
		__detected = true
		print_.se("", " !!! DETECTED")

	var aggression := traits.aggression.normalized()
	print_.se("", "player detected and aggression is: " + str(aggression) + " ")

	# next if detected somehow

	if detect.is_only_heard():
		print_.se("", "idle decision: is_only_heard => pursuit")
		return SEState.pursuit

	# next if detected and seen

	# TODO: likely follow if player is spotted but from a big distances

	if distance_to_player() > me.fight_distance:
		print_.se("", "distance_to_player(" + str(distance_to_player()) + ") > fight_distance(" + str(me.fight_distance) + ") => idle " + me.CURRENT)
		# Turn towards player and remain idle
		me.look_at(me.player.global_position, Vector3.UP)
		return me.CURRENT

	# in fight distance
	if distance_to_player() < me.attack_distance:
		print_.se("", "idle decision: to close! attack")
		return SEState.attack
	

	# in fight but not attack
	if ra.chance(aggression):
		print_.se("", "idle decision: ra  pursuit")
		return SEState.follow
	elif ra.chance(aggression * 0.5): # smaller chance
		print_.se("", "idle decision: ra follow")
		return SEState.follow
	else:
		print_.se("", "idle decision: ra => idle")
		return me.CURRENT


# func update(delta):
# 	# do we need this?
# 	me.move_and_slide()

func on_exit_state():
	__detected = false
