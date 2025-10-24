extends BasePHState


var pursuit_drop_radius: float = 3.5
var speed = 6

func check_transition(_delta) -> VerdictPH:
	if distance_to_player() < pursuit_drop_radius:
		return VerdictPH.new("slash_4")
	return VerdictPH.new()


func update(_delta: float):
	look_at_player(true)
	me.velocity = me.basis.z * speed
	me.move_and_slide()
