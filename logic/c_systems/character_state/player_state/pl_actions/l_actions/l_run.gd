extends LegsAction

@export var accelerate_from_idle_curve: Curve
@export var accel_from_fall_curve: Curve
@export var accel_from_turn_curve: Curve


var accel_from_idle_time: float = 0.3
var accel_from_turn_time: float = 0.3

var speed_mult_from_idle := EaseCurveInterpolator.new()
var angular_sp_from_idle := FloatLinearInterpolator.new()
var turn_sp_from_idle := FloatLinearInterpolator.new()
var speed_from_turn := FloatCurveInterpolator.new()
var angular_sp := FloatLinearInterpolator.new()
var speed_from_inherited := FloatLinearInterpolator.new()

var curr_turn: TurnData = TurnData.new()


var _resettable := [
	speed_mult_from_idle,
	angular_sp_from_idle,
	turn_sp_from_idle,
	speed_from_turn,
	angular_sp,
	speed_from_inherited
]


var SPEED_BOOST: float = 0.0

func initialise() -> void:
	default_sp.SPEED = 3.0
	default_sp.TURN_SPEED = 2.6
	default_sp.ANGULAR_SPEED = 14.0

	var turn_180_blend_time := calculate_blend_time_from_prev_anim_marker(Leg.Act.turn_180, MarkerName.TURN_180_APEX, 0.25)
	var thrown_blend_time := calculate_blend_time_from_prev_anim_marker(PS.Act.thrown, MarkerName.TO_RUN, 0.25, true)
	
	blend_time.set_by_prev_action({
		Leg.Act.idle: 0.3, # 0.3 works good
		Leg.Act.sprint: 0.3,
		Leg.Act.turn_180: turn_180_blend_time,
		Leg.Act.idle_to_sprint: 0.3,
		Leg.Act.fast_turn_180: 0.3,
		PS.Act.landing_sprint: 0.4,
		PS.Act.dodge: 0.3,
		PS.Act.thrown: thrown_blend_time
	})

	GlobalSignal.player_speed_increase.connect_(_on_speed_increase)


func on_enter_action(input_: InputPackage):
	u.reset_all(_resettable)

	var _inherited_speed := pm().get_curr_velocity_len()
	speed_from_inherited.initialise(_inherited_speed, default_sp.SPEED, accel_from_idle_time)
	

	match PREV_ACTION:
		PS.Act.thrown:
			speed_mult_from_idle.initialise(accel_from_fall_curve, accel_from_idle_time + 0.2)
			angular_sp_from_idle.initialise(default_sp.ANGULAR_SPEED / 4, default_sp.ANGULAR_SPEED, 0.5)
			turn_sp_from_idle.initialise(default_sp.TURN_SPEED / 4, default_sp.TURN_SPEED, 0.5)
		Leg.Act.idle:
			speed_mult_from_idle.initialise(accel_from_fall_curve, accel_from_idle_time + 0.2)
			angular_sp_from_idle.initialise(default_sp.ANGULAR_SPEED / 4, default_sp.ANGULAR_SPEED, 0.5)
			turn_sp_from_idle.initialise(default_sp.TURN_SPEED / 4, default_sp.TURN_SPEED, 0.5)
		_ when PREV_ACTION in IDLE_LIKE_ACTIONS:
			speed_mult_from_idle.initialise(accelerate_from_idle_curve, accel_from_idle_time)
			angular_sp_from_idle.initialise(default_sp.ANGULAR_SPEED / 3, default_sp.ANGULAR_SPEED, 0.5)
			turn_sp_from_idle.initialise(default_sp.TURN_SPEED / 3, default_sp.TURN_SPEED, 0.5)
		PS.Act.dodge, Leg.Act.idle_to_sprint, Leg.Act.fast_turn_180:
			speed_mult_from_idle.initialise(accelerate_from_idle_curve, accel_from_idle_time)
			angular_sp_from_idle.initialise(default_sp.ANGULAR_SPEED / 3, default_sp.ANGULAR_SPEED, 0.5)
			turn_sp_from_idle.initialise(default_sp.TURN_SPEED / 3, default_sp.TURN_SPEED, 0.5)
		Leg.Act.sprint:
			speed_from_inherited.initialise(_inherited_speed, default_sp.SPEED, 0.4)
		Leg.Act.turn_180:
			speed_from_turn.initialise(_inherited_speed + 1.5, default_sp.SPEED, accel_from_turn_curve, accel_from_turn_time)
			angular_sp.initialise(default_sp.ANGULAR_SPEED / 3, default_sp.ANGULAR_SPEED, 1.0)
		PS.Act.landing_sprint:
			speed_from_inherited.initialise(_inherited_speed, default_sp.SPEED, 0.5)
			angular_sp.initialise(default_sp.ANGULAR_SPEED / 2, default_sp.ANGULAR_SPEED, 0.5)

func on_exit_action():
	u.reset_all(_resettable)
	get_animator_manager().reset_global_speed_scale()


func update(input_: InputPackage, delta: float):
	var SPEED_MULT := 1.0 # default multiplier
	var CURR_SPEED := speed_from_inherited.update(delta)
	var CURR_ANGULAR_SPEED := default_sp.ANGULAR_SPEED
	var TURN_SPEED := default_sp.TURN_SPEED
	match PREV_ACTION:
		PS.Act.thrown:
			CURR_SPEED = default_sp.SPEED
			SPEED_MULT = speed_mult_from_idle.update(delta)
			CURR_ANGULAR_SPEED = angular_sp_from_idle.update(delta)
			TURN_SPEED = turn_sp_from_idle.update(delta)
		Leg.Act.idle:
			CURR_SPEED = default_sp.SPEED
			SPEED_MULT = speed_mult_from_idle.update(delta)
			CURR_ANGULAR_SPEED = angular_sp_from_idle.update(delta)
			TURN_SPEED = turn_sp_from_idle.update(delta)
		_ when PREV_ACTION in IDLE_LIKE_ACTIONS:
			CURR_SPEED = default_sp.SPEED
			SPEED_MULT = speed_mult_from_idle.update(delta)
			CURR_ANGULAR_SPEED = angular_sp_from_idle.update(delta)
			TURN_SPEED = turn_sp_from_idle.update(delta)
		PS.Act.dodge, Leg.Act.idle_to_sprint, Leg.Act.fast_turn_180:
			CURR_SPEED = default_sp.SPEED
			SPEED_MULT = speed_mult_from_idle.update(delta)
			CURR_ANGULAR_SPEED = angular_sp_from_idle.update(delta)
			TURN_SPEED = turn_sp_from_idle.update(delta)
		Leg.Act.sprint:
			CURR_SPEED = speed_from_inherited.update(delta)
		Leg.Act.turn_180:
			CURR_SPEED = speed_from_turn.update(delta)
			CURR_ANGULAR_SPEED = angular_sp.update(delta)
		PS.Act.landing_sprint:
			CURR_SPEED = speed_from_inherited.update(delta)
			CURR_ANGULAR_SPEED = angular_sp.update(delta)

	CURR_SPEED = player_sm.apply_hit_influence(CURR_SPEED)
	var speed_config := SpeedConfig.new(default_sp, SPEED_MULT, CURR_SPEED + SPEED_BOOST, CURR_ANGULAR_SPEED, TURN_SPEED)
	speed_config.tie_turn_sp_to_speed(0.6)
	pm().move_rotate_with_input_vector(input_, delta, speed_config)

	if CURR_SPEED + SPEED_BOOST != 0.0:
		get_animator_manager().set_global_speed_scale(pm().get_curr_velocity_len() / (CURR_SPEED + SPEED_BOOST))


var _next_anim_correction := 0.08
var __start_time_offset_dev := 0.0


func animate(): # ▶️
	var custom_start_time_offset := start_time_offset.calculate_actual(PREV_ACTION)

	match PREV_ACTION:
		_ when PREV_ACTION in IDLE_LIKE_ACTIONS:
			custom_start_time_offset = 0.2667 # sync with idle where left leg forward (change to marker)
		Leg.Act.turn_180:
			custom_start_time_offset = __start_time_offset_dev # sync with idle where left leg forward
		Leg.Act.sprint:
			var r := sync_with_prev_loco_anim(_next_anim_correction)
			if r != -1:
				custom_start_time_offset = r
		Leg.Act.idle_to_sprint:
			custom_start_time_offset = 0.25
			
	set_anim_to_play(-1, custom_start_time_offset)


var _dev_add_blend := 0.0

func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	SPEED_BOOST = u._dev_change_param(event, SPEED_BOOST, "SPEED_BOOST", 2, RawAction.DEV_speed_down, RawAction.DEV_speed_up)
	# _dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
	# __start_time_offset_dev = u._dev_change_t34_param(event, __start_time_offset_dev, "__start_time_offset_dev", 0.05)


func _on_speed_increase(payload: Dictionary[String, Variant]) -> void:
	# prints("_on_speed_increase", "triggered")
	var value = payload.get(GlobalSignal.payload_amount_field)
	if value and (value is float or value is int):
		SPEED_BOOST += value


## NOTE: currently adjusting SpeedConfig solves non completed root turn better than this.
## In the future this feature may be deleted or separated into something bigger.
var COMPLETE_ROOT_TURN_FEATURE: bool = false
# region: COMPLETE_ROOT_TURN_FEATURE
# from on enter match turn
	# var raw_turn_data: Variant = player_sm.get_tranfer_data_by_key("turn_data")
	# if raw_turn_data == null:
		# prints(u.sfr(), "no 'turn_data' data. assuming turn completed")
		# curr_turn.hard_complete()
	# else:
		# curr_turn.initialise_from_dict(raw_turn_data)
		# prints(u.sfr(), " Inherited turn:", str(curr_turn))

# from update
	# if COMPLETE_ROOT_TURN_FEATURE and not curr_turn.turn_completed:
	# 	_complete_root_turn(CURR_SPEED)
	# else:
		
# func _complete_root_turn(CURR_SPEED):
# 	var rotation_delta := get_animator_manager().get_prev_root_rotation()
# 	var result := pm().apply_root_rotation(rotation_delta, curr_turn.target_angle, curr_turn.accum_rotation, true)
# 	curr_turn.update(result.completed, result.accum_rot)

# 	get_player().velocity = get_player().basis.z * CURR_SPEED
# 	# OR move_with_input_vector(input_, delta, CURVE_SPEED, RESULT_SPEED)
# endregione_with_input_vector(input_, delta, CURVE_SPEED, RESULT_SPEED)
# endregion
