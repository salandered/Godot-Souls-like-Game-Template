extends LegsAction


var DECEL_SPEED: float = 10.0

func initialise() -> void:
	blend_time.set_by_prev_action({
		Leg.Act.sprint_to_idle: 0.3,
		Leg.Act.turn_180: 0.3,
		PS.Act.attack_from_dodge: 0.35,
		PS.Act.thrown: 0.35,
		PS.Act.axe_slice_3: 0.35
	})


func on_enter_action(input_: InputPackage) -> void:
	match PREV_ACTION:
		PS.Act.dodge:
			DECEL_SPEED = 14.0

		_:
			DECEL_SPEED = 10.0


func update(input_: InputPackage, delta: float) -> void:
	# get_player().velocity = Vector3.ZERO
	if not legs_sm.area_awareness.is_camera_locked():
		pm().apply_friction(delta, DECEL_SPEED)
	else:
		pm().apply_friction(delta, DECEL_SPEED + 2.0)