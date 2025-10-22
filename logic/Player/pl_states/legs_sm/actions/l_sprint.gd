extends LegsAction


@export var accel_from_turn_curve: Curve

var accel_time_from_turn: float = 0.8 # How long to reach full speed
var accel_time_from_slow: float = 0.8 # Time to interpolate to target speed

var speed_from_inherited := FloatLinearInterpolator.new()
var speed_from_turn := FloatCurveInterpolator.new()
var angular_from_turn := FloatLinearInterpolator.new()


func _ready():
	default_sp.SPEED = 5.0
	default_sp.TURN_SPEED = 3.2
	default_sp.ANGULAR_SPEED = 10
	
	blend_time_by_action = {
		Leg.Act.idle_to_sprint: 0.6,
		Leg.Act.run: 0.3,
		Leg.Act.fast_turn_180: 0.4
	}
	

func on_enter_action(input_: InputPackage):
	speed_from_inherited.reset()
	speed_from_turn.reset()
	angular_from_turn.reset()

	match PREV_ACTION:
		Leg.Act.idle_to_sprint, Leg.Act.sprint_to_idle:
			var _inherited_speed := get_curr_velocity()
			speed_from_inherited.initialise(_inherited_speed, default_sp.SPEED, accel_time_from_slow)
			# angular_from_turn.initialise(default_sp.ANGULAR_SPEED / 10, default_sp.ANGULAR_SPEED, 1.0)
		Leg.Act.fast_turn_180:
			var _inherited_speed := get_curr_velocity()
			prints("_inherited_speed", _inherited_speed)
			speed_from_turn.initialise(_inherited_speed, default_sp.SPEED, accel_from_turn_curve, accel_time_from_turn)
			angular_from_turn.initialise(default_sp.ANGULAR_SPEED / 3, default_sp.ANGULAR_SPEED, 1.0)

	print_.lsm_action(action_name + pp.on_ent, "")


func on_exit_action():
	animator_manager.reset_global_speed_scale()


func update(input_: InputPackage, delta: float):
	var CURR_SPEED := default_sp.SPEED # default actual speed
	var CURR_ANGULAR_SPEED := default_sp.ANGULAR_SPEED

	match PREV_ACTION:
		Leg.Act.idle_to_sprint, Leg.Act.sprint_to_idle:
			CURR_SPEED = speed_from_inherited.update(delta)
		Leg.Act.fast_turn_180:
			CURR_SPEED = speed_from_turn.update(delta)
			CURR_ANGULAR_SPEED = angular_from_turn.update(delta)
	
	var speed_config := SpeedConfig.new(default_sp, 1.0, CURR_SPEED, CURR_ANGULAR_SPEED)
	speed_config.tie_turn_sp_to_speed(0.6)
	# print(speed_config)
	pm().process_input_vector(input_, delta, speed_config)

	animator_manager.set_global_speed_scale(get_curr_velocity() / CURR_SPEED)

var __start_time_offset_dev := 0.0

func animate(): # ▶️
	blend_time = blend_time_by_action.get(PREV_ACTION, default_blend_time)
	
	start_time_offset = default_start_time_offset
	match PREV_ACTION:
		Leg.Act.idle_to_sprint:
			start_time_offset = 0.5
		Leg.Act.fast_turn_180:
			start_time_offset = __start_time_offset_dev
		Leg.Act.run:
			var r := sync_with_prev_loco_anim(_next_anim_correction)
			if r != -1:
				start_time_offset = r
	
	set_anim_to_play()


var _dev_add_blend := 0.0
var _next_anim_correction := 0.12


func _input(event):
	default_sp.SPEED = u._dev_change_param(event, default_sp.SPEED, "SPEED", 6, "dev_speed_down", "dev_speed_up")
	# _dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)

	# _next_anim_correction = u._dev_change_t67_param(event, _next_anim_correction, "_next_anim_correction", 0.02)
