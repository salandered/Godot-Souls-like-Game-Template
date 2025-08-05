extends BaseSEState

# TODO looks like vars for all states
@export var pursuit_commitment: float = 1
@export var pursuit_fatigue: float = 1

func check_transition(delta: float) -> String:
	var aggression := traits._aggression.normalized()
	if not works_longer_than(pursuit_commitment):
		return me.CURRENT
	if works_longer_than(pursuit_fatigue):
		return SEState.idle
	if player.global_position.distance_to(me.global_position) < me.attack_radius:
		if ra.chance(aggression):
			return SEState.attack
		elif ra.chance(aggression * 0.5):
			return SEState.idle
	if player.global_position.distance_to(me.global_position) > me.area_awareness.sight_distance:
		return SEState.backtrack
	
	return me.CURRENT


func update(delta):
	var grounded_player_pos = player.global_position
	grounded_player_pos.y = me.global_position.y
	
	me.velocity = me.global_position.direction_to(grounded_player_pos) * me.speed
	me.look_at(grounded_player_pos)
	me.move_and_slide()
