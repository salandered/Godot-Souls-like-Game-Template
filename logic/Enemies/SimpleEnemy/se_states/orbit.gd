extends BaseSEState

@export var speed: float = 0.65
@export var tracking_angular_speed: float = 2
var direction_decider: int # 1 or -1

# TODO: whats going on here


func check_transition(delta: float) -> SEVerdict:
	if distance_to_player() < me.attack_distance:
		print_.se_check_trans(state_name, "<attack_distance => attack")
		return SEVerdict.new(SEState.attack)
	if distance_to_player() > me.fight_distance:
		print_.se_check_trans(state_name, ">fight_distance => backtrack")
		return SEVerdict.new(SEState.backtrack)
	return SEVerdict.new()

# The lazy way to do this, not the circular movement
func _update(delta):
	look_at_player(true)

	me.velocity = Vector3.UP.cross(direction_to_player()) * speed * direction_decider
	me.move_and_slide()


func on_enter_state():
	if ra.coinflip():
		direction_decider = -1
		change_animation_to(SEA.strafe_L)
	else:
		direction_decider = 1
		change_animation_to(SEA.strafe_R)


func on_exit():
	pass
