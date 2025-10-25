extends BasePHEState


# var pursuit_drop_radius: float = 3.5
# var speed = 6


# func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
# 	if distance_to_player() < pursuit_drop_radius:
# 		return VerdictPH.new("slash_4")
# 	return VerdictPH.new()


# func update(delta: float):
# 	e_movement.look_at_player(true)
# 	me.velocity = me.basis.z * speed
