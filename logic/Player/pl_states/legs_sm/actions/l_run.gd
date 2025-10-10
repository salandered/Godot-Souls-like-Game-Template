extends LegsAction

@export var accelerate_from_idle_curve: Curve
@export var accel_from_turn_curve: Curve


var accel_from_idle_time: float = 0.5 # How long to reach full speed
var accel_from_turn_time: float = 0.5

var speed_mult_from_idle = EaseCurveInterpolator.new()
var speed_from_turn = FloatCurveInterpolator.new()
var angular_sp_from_turn = FloatLinearInterpolator.new()

var curr_turn: TurnData = TurnData.new()

## NOTE: currently adjusting SpeedConfig solves non completed root turn better than this.
## In the future this feature may be deleted or separated into something bigger.
var COMPLETE_ROOT_TURN_FEATURE: bool = false

func initialise():
	SPEED = 3.0
	TURN_SPEED = 2.0
	ANGULAR_SPEED = 10.0

	var turn_180_blend_time := calculate_blend_time_from_prev_anim_marker(Leg.Act.turn_180, Marker.Name.TURN_180_APEX, 0.25)
	
	blend_time_by_action = {
		Leg.Act.idle: 0.3, # 0.3 WORKED GOOD!!
		Leg.Act.sprint: 0.3,
		Leg.Act.turn_180: turn_180_blend_time,
	}

func on_enter_action(input: InputPackage):
	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			speed_mult_from_idle.initialise(accelerate_from_idle_curve, accel_from_idle_time)
		Leg.Act.turn_180:
			var start_speed = legs_sm.get_tranfer_data_by_key("rm_speed")
			if not start_speed:
				print_.warn("no start_speed! will use 1.0")
				start_speed = 1.0
			speed_from_turn.initialise(start_speed + 1.5, SPEED, accel_from_turn_curve, accel_from_turn_time)
			angular_sp_from_turn.initialise(ANGULAR_SPEED / 3, ANGULAR_SPEED, 1)
			var raw_turn_data = legs_sm.get_tranfer_data_by_key("turn_data")
			if raw_turn_data == null:
				prints(u.fr(), "no 'turn_data' data. assuming turn completed")
				curr_turn.hard_complete()
			else:
				curr_turn.initialise_from_dict(raw_turn_data)
				prints(u.fr(), " Inherited turn:", str(curr_turn))

func on_exit_action():
	animator_manager.reset_global_speed_scale()
	var final_speed = get_player().velocity.length()
	legs_sm.fill_tranfer_data({"manual_speed": final_speed})

	speed_mult_from_idle.reset()
	speed_from_turn.reset()
	angular_sp_from_turn.reset()

func update(input: InputPackage, delta: float):
	var SPEED_MULT = 1.0 # default multiplier
	var CURR_SPEED = SPEED # default actual speed
	var CURR_ANGULAR_SPEED = ANGULAR_SPEED

	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			SPEED_MULT = speed_mult_from_idle.update(delta)
		Leg.Act.turn_180:
			CURR_SPEED = speed_from_turn.update(delta)
			CURR_ANGULAR_SPEED = angular_sp_from_turn.update(delta)

	if not curr_turn.turn_completed and COMPLETE_ROOT_TURN_FEATURE:
		_complete_root_turn(CURR_SPEED)
	else:
		# prints("~~", SPEED_MULT, CURR_SPEED, CURR_ANGULAR_SPEED)
		var speed_config = SpeedConfig.new(SPEED_MULT, CURR_SPEED, CURR_ANGULAR_SPEED)
		speed_config.tie_turn_sp_to_speed(0.6)
		process_input_vector(input, delta, speed_config)

	animator_manager.set_global_speed_scale(get_player().velocity.length() / CURR_SPEED)


var _next_anim_correction = 0.08
var __start_time_offset_dev = 0.0


func animate(): # ▶️
	var start_time_offset := 0.0
	var blend_time: float = blend_time_by_action.get(legs_sm.prev_action.action_name, default_blend_time)
	
	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			start_time_offset = 0.2667 # sync with idle where left leg forward
		Leg.Act.turn_180:
			start_time_offset = __start_time_offset_dev # sync with idle where left leg forward
		Leg.Act.sprint:
			var r = sync_with_prev_loco_anim(_next_anim_correction)
			if r != -1:
				start_time_offset = r
			
	__log_anim(blend_time, start_time_offset)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_time_offset)


func _complete_root_turn(CURR_SPEED):
	var rotation_delta = animator_manager.get_prev_root_rotation()
	var result = apply_root_rotation(rotation_delta, curr_turn.target_angle, curr_turn.accum_rotation, true)
	curr_turn.update(result.completed, result.accum_rot)

	get_player().velocity = get_player().basis.z * CURR_SPEED
	# OR move_with_input_vector(input, delta, CURVE_SPEED, RESULT_SPEED)

var _dev_add_blend = 0

func _input(event):
	SPEED = u._dev_change_param(event, SPEED, "SPEED", 6, "dev_speed_down", "dev_speed_up")
	# _dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
	__start_time_offset_dev = u._dev_change_t34_param(event, __start_time_offset_dev, "__start_time_offset_dev", 0.05)
