extends PlayerAction


var DECEL_SPEED: float = 10.0

# func initialise() -> void:
# 	blend_time.set_by_prev_action({
# 		Leg.Act.sprint_to_idle: 0.3,
# 		Leg.Act.turn_180: 0.3,
# 		PS.Act.thrown: 0.35
# 	})


func on_enter_action(input_: InputPackage) -> void:
	prints("dead action")
	match PREV_ACTION:
		PS.Act.dodge:
			DECEL_SPEED = 14.0

		_:
			DECEL_SPEED = 10.0


func update(input_: InputPackage, delta: float) -> void:
	# get_player().velocity = Vector3.ZERO
	pm().apply_friction(delta, DECEL_SPEED + 2.0)
