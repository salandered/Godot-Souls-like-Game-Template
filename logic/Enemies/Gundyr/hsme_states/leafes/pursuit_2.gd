extends BaseHSMEState


@export var pursuit_drop_radius: float = 3.5
@export var speed = 6

func check_transition(_delta) -> VerdictHSM:
	if distance_to_player() < pursuit_drop_radius:
		return VerdictHSM.new("slash_4")
	return VerdictHSM.new()


func update(_delta: float):
	look_at_player(true)
	me.velocity = me.basis.z * speed
	me.move_and_slide()
