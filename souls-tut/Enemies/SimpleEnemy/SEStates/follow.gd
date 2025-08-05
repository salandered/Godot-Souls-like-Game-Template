extends BaseSEState

## light pursuit

@export var commitment: float = 3

func check_transition(delta: float) -> String:
	var aggression := traits._aggression.normalized()

	if not works_longer_than(commitment):
		return me.CURRENT

	if player.global_position.distance_to(me.global_position) < me.attack_radius:
		if ra.chance(aggression):
			return SEState.attack
		elif ra.chance(aggression * 0.5):
			return SEState.idle

	if player.global_position.distance_to(spawn_point) > me.deaggro_radius:
		return SEState.backtrack
	return me.CURRENT


func update(delta):
	var grounded_player_pos = player.global_position
	grounded_player_pos.y = me.global_position.y
	
	me.velocity = me.global_position.direction_to(grounded_player_pos) * me.speed / 2
	me.look_at(grounded_player_pos)
	me.move_and_slide()
