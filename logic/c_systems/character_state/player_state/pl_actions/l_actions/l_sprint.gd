extends LegsAction


@export var accel_from_turn_curve: Curve

var accel_time_from_turn: float = 0.8 # How long to reach full speed
var accel_time_from_slow: float = 0.8 # Time to interpolate to target speed

var speed_from_inherited := FloatLinearInterpolator.new()
var speed_from_turn := FloatCurveInterpolator.new()
var angular_sp := FloatLinearInterpolator.new()


var SPEED_BOOST: float = 0.0

func initialise() -> void:
	default_sp.SPEED = 5.0
	default_sp.TURN_SPEED = 3.2
	default_sp.ANGULAR_SPEED = 10
	
	blend_time.set_by_prev_action({
		Leg.Act.idle_to_sprint: 0.3,
		Leg.Act.run: 0.3,
		Leg.Act.fast_turn_180: 0.4,
		PS.Act.dodge: 0.25

	})
	# NOTE: start_time_offset is handled in animate()

	GlobalSignal.player_speed_increase.connect_(_on_speed_increase)


func on_enter_action(input_: InputPackage):
	speed_from_inherited.reset()
	speed_from_turn.reset()
	angular_sp.reset()
	
	var _inherited_speed := pm().get_curr_velocity_len()
	speed_from_inherited.initialise(_inherited_speed, default_sp.SPEED, accel_time_from_slow)
	
	match PREV_ACTION:
		Leg.Act.idle_to_sprint:
			var _root_vel_speed: Variant = player_sm.get_tranfer_data_by_key("root_vel_speed")
			if _root_vel_speed == null:
				__log_error("_root_vel_speed is null", "", "")
				speed_from_inherited.initialise(_inherited_speed + 1.0, default_sp.SPEED, 0.4)
			elif _root_vel_speed is float:
				__log_action("_root_vel_speed / _inherited_speed", _root_vel_speed, _inherited_speed)
				speed_from_inherited.initialise(_root_vel_speed + 0.4, default_sp.SPEED, 0.4)
			else:
				__log_error("_root_vel_speed is not float", "", "")
				speed_from_inherited.initialise(_inherited_speed + 1.0, default_sp.SPEED, 0.4)
				
		Leg.Act.run:
			speed_from_inherited.initialise(_inherited_speed, default_sp.SPEED, 0.4)
		Leg.Act.fast_turn_180:
			__log_action("_inherited_speed", _inherited_speed)
			speed_from_turn.initialise(_inherited_speed, default_sp.SPEED, accel_from_turn_curve, accel_time_from_turn)
			angular_sp.initialise(default_sp.ANGULAR_SPEED / 3, default_sp.ANGULAR_SPEED, 1.0)
		PS.Act.landing_sprint, PS.Act.dodge:
			speed_from_inherited.initialise(_inherited_speed, default_sp.SPEED, 1.0)
			angular_sp.initialise(default_sp.ANGULAR_SPEED / 3, default_sp.ANGULAR_SPEED, 1.0)
		Leg.Act.strafe:
			speed_from_inherited.initialise(_inherited_speed, default_sp.SPEED, 0.3)
		# PS.Act.dodge:
			# angular_sp.initialise(default_sp.ANGULAR_SPEED / 3, default_sp.ANGULAR_SPEED, 1.0)

	print_.lsm_action(action_name + pp.on_ent, "")

	
func on_exit_action():
	get_animator_manager().reset_global_speed_scale()


func update(input_: InputPackage, delta: float):
	var CURR_ANGULAR_SPEED := default_sp.ANGULAR_SPEED

	var CURR_SPEED := speed_from_inherited.update(delta)
	match PREV_ACTION:
		Leg.Act.idle_to_sprint:
			CURR_SPEED = speed_from_inherited.update(delta)
		Leg.Act.sprint_to_idle:
			CURR_SPEED = speed_from_inherited.update(delta)
		Leg.Act.run:
			CURR_SPEED = speed_from_inherited.update(delta)
		Leg.Act.fast_turn_180:
			CURR_SPEED = speed_from_turn.update(delta)
			CURR_ANGULAR_SPEED = angular_sp.update(delta)
		PS.Act.landing_sprint, PS.Act.dodge:
			CURR_SPEED = speed_from_inherited.update(delta)
			CURR_ANGULAR_SPEED = angular_sp.update(delta)
	
	CURR_SPEED = player_sm.apply_hit_influence(CURR_SPEED)
	var speed_config := SpeedConfig.new(default_sp, 1.0, CURR_SPEED + SPEED_BOOST, CURR_ANGULAR_SPEED)
	speed_config.tie_turn_sp_to_speed(0.6)
	# __log_action(speed_config)
	pm().move_rotate_with_input_vector(input_, delta, speed_config)

	get_animator_manager().set_global_speed_scale(pm().get_curr_velocity_len() / CURR_SPEED)


var __start_time_offset_dev := 0.0
var _next_anim_correction := 0.12


func animate(): # ▶️
	var _custom_start_time_offset := start_time_offset.calculate_actual(PREV_ACTION)

	match PREV_ACTION:
		Leg.Act.idle_to_sprint:
			_custom_start_time_offset = 0.5
		Leg.Act.fast_turn_180:
			_custom_start_time_offset = 0.0
		Leg.Act.run:
			var r := sync_with_prev_loco_anim(_next_anim_correction)
			if r != -1:
				_custom_start_time_offset = r
		PS.Act.landing_sprint:
			_custom_start_time_offset = __start_time_offset_dev
	
	set_anim_to_play(-1, _custom_start_time_offset)


func _on_speed_increase(payload: Dictionary[StringName, Variant]) -> void:
	# prints("_on_speed_increase", "triggered")
	var value = payload.get(SPS.amount_field)
	if value and (value is float or value is int):
		SPEED_BOOST += value


func _unhandled_input(event: InputEvent) -> void:
	if u.is_release():
		return
	SPEED_BOOST = InputUtils._dev_change_param(event, SPEED_BOOST, "SPEED_BOOST", 3, RawAction.DEV_speed_down, RawAction.DEV_speed_up, true)
