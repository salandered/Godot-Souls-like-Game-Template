extends BaseHSMEState


@export var speed: float = 0.65
@export var tracking_angular_speed: float = 2
var direction_decider: int # 1 or -1


func on_enter():
	if ra.coinflip():
		direction_decider = -1
		animation = "strafe_left"
	else:
		direction_decider = 1
		animation = "strafe_right"


func check_transition(_delta):
	return VerdictHSM.new()

# lasy way to do this, not the circular movement
func update(delta: float):
	look_at_player(true)
	me.velocity = Vector3.UP.cross(direction_to_player()) * speed * direction_decider
	me.move_and_slide()
