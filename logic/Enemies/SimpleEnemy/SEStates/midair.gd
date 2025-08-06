extends BaseSEState

var landing_height: float = 2

func check_transition(delta: float) -> String:
	print_.prefix("SE", "midair: check_transition")
	var floor_distance := me.awareness.get_floor_distance()
	print_.prefix("SE", "Floor distance: %s" % str(floor_distance))
	if floor_distance < landing_height:
		print_.prefix("SE", "midair decision: landing, backtrack")
		# TODO: change
		return SEState.backtrack
	else:
		print_.prefix("SE", "midair decision: still falling")
		# still falling
		return me.CURRENT


func update(delta):
	print_.prefix("SE", "midair: update")
	me.velocity.y -= gravity * delta
	me.move_and_slide()
