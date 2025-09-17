extends BaseSEState

@export var speed: float = 0.65
@export var tracking_angular_speed: float = 2
var direction_decider: int # 1 or -1

# TODO: whats going on here


func on_enter_state():
	print_.se("", "orbit: on_enter_state")
	if ra.coinflip():
		direction_decider = -1
		change_animation_to(SEA.strafe_L)
	else:
		direction_decider = 1
		change_animation_to(SEA.strafe_R)


func check_transition(delta: float) -> String:
	print_.se("", "orbit: check_transition")
	if player.global_position.distance_to(me.global_position) < me.attack_distance:
		print_.se("", "orbit decision: attack")
		return SEState.attack
	if distance_to_player() > me.fight_distance:
		print_.se("", "orbit decision: backtrack")
		return SEState.backtrack
	return me.CURRENT

# The Lazy way to do this, not the circular movement
func _update(delta):
	u.safe_look_at(me, get_projected_player_pos(), Vector3.UP, true)

	me.velocity = Vector3.UP.cross(direction_to_player()) * speed * direction_decider
	me.move_and_slide()


func on_exit():
	print_.se("", "orbit: on_exit")
	pass
