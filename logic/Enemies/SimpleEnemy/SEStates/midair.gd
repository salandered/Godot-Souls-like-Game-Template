extends BaseSEState

var landing_height: float = 2

func check_transition(delta: float) -> Verdict:
	var floor_distance: float = me.awareness.get_floor_distance()
	print_.se_check_trans(state_name, "Floor distance: %s" % str(floor_distance))
	if floor_distance < landing_height:
		print_.se_check_trans(state_name, "landing, backtrack")
		# TODO: change
		return Verdict.new(SEState.backtrack)
	else:
		print_.se_check_trans(state_name, "still falling")
		# still falling
		return Verdict.new()


func update(delta):
	print_.se(state_name, "update")
	me.velocity.y -= u.gravity * delta
	me.move_and_slide()
