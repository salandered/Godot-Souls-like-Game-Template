extends BaseSEState

var landing_height: float = 2

func check_transition(delta: float) -> String:
	var floor_distance := me.area_awareness.get_floor_distance()
	if floor_distance < landing_height:
		# TODO: change
		return SEState.backtrack
	else:
		# still falling
		return me.CURRENT


func update(delta):
	me.velocity.y -= gravity * delta
	me.move_and_slide()
