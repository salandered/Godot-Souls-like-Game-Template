extends LegsAction

@export var stopping_curve: Curve

# var speed_slow_down := EaseCurveInterpolator.new()

func initialise() -> void:
	blend_time.set_by_prev_action({
		Leg.Act.sprint_to_idle: 0.3,
		Leg.Act.turn_180: 0.3
	})

var _inherited_speed

# func on_enter_action(input_: InputPackage) -> void:
# 	speed_slow_down.reset()

# 	_inherited_speed = pm().get_curr_velocity_len()
# 	speed_slow_down.initialise(stopping_curve, 0.3)


func update(input_: InputPackage, delta: float) -> void:
	# get_player().velocity = Vector3.ZERO
	# get_player().velocity = get_player().velocity.move_toward(Vector3.ZERO, 5.0 * delta)
	# if not legs_sm.area_awareness.is_camera_locked():
	# 	var speed_mult = speed_slow_down.update(delta)
	# 	var current_direction = get_player().velocity.normalized()
	# 	get_player().velocity = current_direction * _inherited_speed * speed_mult
	# else: # todo
	get_player().velocity = Vector3.ZERO