extends LegsAction

@export var accelerate_from_idle_curve: Curve

var ANGULAR_SPEED: float = 12
var curr_speed_time: float = 0.0 # [0,1] progress along curve
var acceleration_time: float = 0.5 # How long to reach full speed

var speed_curve_interpolator = CurveInterpolator.new()

func _ready():
	SPEED = 3.0
	TURN_SPEED = 2


func on_enter_action(input: InputPackage):
	if legs_sm.prev_action.action_name == Leg.Act.idle:
		speed_curve_interpolator.initialise(accelerate_from_idle_curve, acceleration_time)


func on_exit_action():
	animator_manager.reset_global_speed_scale()
	curr_speed_time = 0


func update(input: InputPackage, delta: float):
	process_input_vector(input, delta)


func process_input_vector(input: InputPackage, delta: float):
	var input_direction := velocity_by_input(input, delta).normalized()

	var CURVE_SPEED = 1
	# Handle acceleration
	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			if input_direction.length() > 0 and not speed_curve_interpolator.is_complete():
				CURVE_SPEED = speed_curve_interpolator.update(delta)

	# print(pp.s(" curr_speed_time: ", curr_speed_time, " CURVE_SPEED", CURVE_SPEED))
	
	var face_dir = player.basis.z
	var angle = face_dir.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= ANGULAR_SPEED * delta:
		var face_dir_rotated := face_dir.rotated(Vector3.UP, sign(angle) * ANGULAR_SPEED * delta)
		player.velocity = face_dir_rotated * TURN_SPEED * CURVE_SPEED
		player.rotate_y(sign(angle) * ANGULAR_SPEED * delta)
	else:
		var face_dir_rotated := face_dir.rotated(Vector3.UP, angle)
		player.velocity = face_dir_rotated * SPEED * CURVE_SPEED
		player.rotate_y(angle)

	animator_manager.set_global_speed_scale(player.velocity.length() / SPEED)


var _dev_add_blend = 0


var _next_anim_correction = 0.08

## overrides
func animate(): # ▶️
	var blend_time := default_blend_time
	var start_time_offset := 0.0
	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			blend_time = 0.3 + _dev_add_blend # 0.3 WORKED GOOD!!
			start_time_offset = 0.2667 # sync with idle where left leg forward
		Leg.Act.sprint:
			blend_time = 0.3 + _dev_add_blend
			var r = sync_with_prev_loco_anim(_next_anim_correction)
			if r != -1:
				start_time_offset = r
	print("~~~", start_time_offset)
	print_.lsm_action_anim(action_name, anim_name, legs_sm.prev_action.action_name, blend_time, start_time_offset, 8)
	animator_manager.set_anim_to_play(anim_id, blend_time, start_time_offset)


func _input(event):
	SPEED = u._dev_change_param(event, SPEED, "SPEED", 6, "dev_speed_down", "dev_speed_up")
	_dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
	_next_anim_correction = u._dev_change_t34_param(event, _next_anim_correction, "_next_anim_correction", 0.02)
