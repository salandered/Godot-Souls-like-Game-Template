extends LegsAction

var ANGULAR_SPEED: float = 10
var TARGET_SPEED: float = 5.0
var SPEED_LERP_TIME: float = 0.5 # Time to interpolate to target speed


func _ready():
	SPEED = 5.0
	TURN_SPEED = 3.2

var speed_interpolator = FloatLinearInterpolator.new()

func on_enter_action(input: InputPackage):
	# means no interpolation. Will be returning constant
	speed_interpolator.initialise(TARGET_SPEED, TARGET_SPEED, 0.0)
	match legs_sm.prev_action.action_name:
		Leg.Act.idle_to_sprint:
			var start_speed = legs_sm.transfer_data.get_by_key_if_action(Leg.Act.idle_to_sprint, "rm_speed")
			if start_speed:
				speed_interpolator.initialise(start_speed, TARGET_SPEED, SPEED_LERP_TIME)
		# Leg.Act.legs_action_run: # do later

	print_.lsm_action(action_name + pp.on_ent, "")


func on_exit_action():
	animator_manager.reset_global_speed_scale()


func update(input: InputPackage, delta: float):
	SPEED = speed_interpolator.update(delta)
	process_input_vector(input, delta)


func process_input_vector(input: InputPackage, delta: float):
	var input_direction := velocity_by_input(input, delta).normalized()
	var face_dir = player.basis.z
	var angle = face_dir.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= ANGULAR_SPEED * delta:
		var face_dir_rotated = face_dir.rotated(Vector3.UP, sign(angle) * ANGULAR_SPEED * delta)
		player.velocity = face_dir_rotated * TURN_SPEED
		player.rotate_y(sign(angle) * ANGULAR_SPEED * delta)
	else:
		player.velocity = face_dir.rotated(Vector3.UP, angle) * SPEED
		player.rotate_y(angle)
	
	animator_manager.set_global_speed_scale(player.velocity.length() / SPEED)


var _dev_add_blend = 0
var _next_anim_correction = 0.12

func animate(): # ▶️
	var blend_time := default_blend_time
	var start_time_offset := 0.0
	match legs_sm.prev_action.action_name:
		Leg.Act.idle_to_sprint:
			blend_time = 0.6
			start_time_offset = 0.5
		Leg.Act.run:
			blend_time = 0.3 + _dev_add_blend
			var r = sync_with_prev_loco_anim(_next_anim_correction)
			if r != -1:
				start_time_offset = r
	print_.lsm_action_anim(action_name, anim_name, legs_sm.prev_action.action_name, blend_time, start_time_offset, 8)
	animator_manager.set_anim_to_play(anim_id, blend_time, start_time_offset)


func _input(event):
	SPEED = u._dev_change_param(event, SPEED, "SPEED", 6, "dev_speed_down", "dev_speed_up")
	_dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)

	_next_anim_correction = u._dev_change_t67_param(event, _next_anim_correction, "_next_anim_correction", 0.02)
