extends LegsAction

@export var accelerate_from_idle_curve: Curve

var curr_speed_time: float = 0.0 # [0,1] progress along curve
var acceleration_time: float = 0.5 # How long to reach full speed

var speed_curve_interpolator = CurveInterpolator.new()
var speed_interpolator = FloatLinearInterpolator.new()

var turn_completed := true
var target_angle := 0.0
var accumulated_rotation := 0.0

const RESIDUAL_TURN_SPEED = PI / 4

func _ready():
	SPEED = 3.0
	ANGULAR_SPEED = 12.0
	TURN_SPEED = 2.0

	blend_time_by_state = {
		Leg.Act.idle: 0.3 + _dev_add_blend, # 0.3 WORKED GOOD!!
		Leg.Act.sprint: 0.3 + _dev_add_blend,
		Leg.Act.turn_180: 0.3
	}

func on_enter_action(input: InputPackage):
	var _turn_completed = legs_sm.transfer_data.get_by_key_if_action(Leg.Act.turn_180, "turn_completed")

	if _turn_completed == null:
		prints(u.fr(), "[RUN] no _turn_completed data. assuming turn completed")
		turn_completed = true

	elif _turn_completed == false:
		turn_completed = false
		target_angle = legs_sm.transfer_data.get_by_key_if_action(Leg.Act.turn_180, "target_angle")
		accumulated_rotation = legs_sm.transfer_data.get_by_key_if_action(Leg.Act.turn_180, "accumulated_rotation")
		prints(u.fr(), "[RUN] Inherited incomplete turn. Target:", rad_to_deg(target_angle))
	else:
		prints(u.fr(), "[RUN] Inherited complete turn")
		turn_completed = true

	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			speed_curve_interpolator.initialise(accelerate_from_idle_curve, acceleration_time)
		Leg.Act.turn_180:
			var start_speed = legs_sm.transfer_data.get_by_key_if_action(Leg.Act.turn_180, "rm_speed")
			prints(u.fr(), "on enter rm_speed", start_speed)
			if start_speed:
				speed_interpolator.initialise(start_speed, SPEED, acceleration_time)
			else:
				speed_interpolator.initialise(SPEED, SPEED, 0)

func on_exit_action():
	animator_manager.reset_global_speed_scale()
	var final_speed = player.velocity.length()
	legs_sm.transfer_data.fill(action_name, {"manual_speed": final_speed})


func update(input: InputPackage, delta: float):
	var CURVE_SPEED = 1.0 # default multiplier
	var RESULT_SPEED = SPEED # default actual speed


	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			CURVE_SPEED = speed_curve_interpolator.update(delta)
		Leg.Act.turn_180:
			RESULT_SPEED = speed_interpolator.update(delta)
	
	# turn_completed = true
	if not turn_completed:
		var rotation_delta = animator_manager.get_prev_root_rotation()
		var remaining_angle = target_angle - accumulated_rotation

		var _log_msg = "rem ∠ " + pp.rad2deg(remaining_angle) + ", rot delta " + pp.rad2deg(rotation_delta)
		if rotation_delta < 0 and remaining_angle > 0 or rotation_delta > 0 and remaining_angle < 0:
			prints(u.fr(), em.pin + "counter rotation, ending turn", _log_msg)
			turn_completed = true
		else:
			if abs(rotation_delta) >= abs(remaining_angle):
				player.rotate_y(remaining_angle)
				turn_completed = true
				prints(u.fr(), "Turn complete.", _log_msg)
			else:
				player.rotate_y(rotation_delta)
				accumulated_rotation += rotation_delta
				prints(u.fr(), "applied", _log_msg)

		player.velocity = player.basis.z * RESULT_SPEED
		# TODO: experiment with blending from this and process_input_vector
		# move_with_input_vector(input, delta, CURVE_SPEED, RESULT_SPEED)

	else:
		process_input_vector(input, delta, CURVE_SPEED, RESULT_SPEED)

	animator_manager.set_global_speed_scale(player.velocity.length() / RESULT_SPEED)


var _next_anim_correction = 0.08
var __start_time_offset_dev = 0.0


func animate(): # ▶️
	var start_time_offset := 0.0
	var blend_time: float = blend_time_by_state.get(legs_sm.prev_action.action_name, default_blend_time)
	
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


var _dev_add_blend = 0

func _input(event):
	SPEED = u._dev_change_param(event, SPEED, "SPEED", 6, "dev_speed_down", "dev_speed_up")
	# _dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
	__start_time_offset_dev = u._dev_change_t34_param(event, __start_time_offset_dev, "__start_time_offset_dev", 0.05)
