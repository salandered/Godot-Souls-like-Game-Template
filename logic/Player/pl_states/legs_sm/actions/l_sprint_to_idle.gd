extends LegsAction

var ANGULAR_SPEED: float = 2.0 # Allow slight turning while stopping

var fade_interpolator = FloatLinearInterpolator.new()
var fade_time: float = 0.1 # How long to fade extra velocity
var extra_speed: float = 0.0 # Not vector!

func on_enter_action(input: InputPackage) -> void:
	var prev_speed = legs_sm.transfer_data.get_by_key_if_action(Leg.Act.run, "manual_speed")
	if prev_speed and prev_speed is float:
		var rm_start_speed = calculate_animation_start_velocity()
		extra_speed = max(0.0, prev_speed - rm_start_speed) # Just the number
		fade_interpolator.initialise(1.0, 0.0, fade_time)
		print_.lsm_action(action_name + pp.on_ent, "prev: %.2f, rm_start: %.2f, extra: %.2f" % [prev_speed, rm_start_speed, extra_speed])
	else:
		extra_speed = 0.0
		fade_interpolator.initialise(0.0, 0.0, 0.0)

func on_exit_action() -> void:
	# print("[RUN_STOP] on_exit: fade_complete=%s extra_vel_len=%.2f" % [
	# 	fade_interpolator.is_complete(), extra_velocity.length()
	# ])
	animator_manager.reset_global_speed_scale()

func calculate_animation_start_velocity() -> float:
	var native = anim.native_anim
	var root_track_path = "%GeneralSkeleton:Root"
	var pos_track = native.find_track(root_track_path, Animation.TYPE_POSITION_3D)
	
	if pos_track == -1 or native.track_get_key_count(pos_track) <= 1:
		return 0.0
	
	# Sample at start and a small delta to get initial velocity
	var sample_delta = 0.016 # One frame at 60fps
	var start_time = anim.start_time
	var pos_at_start = native.position_track_interpolate(pos_track, start_time)
	var pos_at_delta = native.position_track_interpolate(pos_track, start_time + sample_delta)
	
	var velocity = (pos_at_delta - pos_at_start) / sample_delta
	velocity.y = 0 # Ignore vertical
	
	var result = velocity.length() * anim.speed_scale
	# print("[RUN_STOP] calc_start_vel: pos_start=%s pos_delta=%s -> vel=%.2f" % [
	# 	pp.vec3(pos_at_start), pp.vec3(pos_at_delta), result
	# ])
	
	return result

func update(input: InputPackage, delta: float):
	process_input_vector(input, delta)
	_move_with_root(delta)


func process_input_vector(input: InputPackage, delta: float):
	var input_direction := velocity_by_input(input, delta).normalized()
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= ANGULAR_SPEED * delta:
		player.rotate_y(sign(angle) * ANGULAR_SPEED * delta)
	else:
		player.rotate_y(angle)


func _move_with_root(delta: float) -> void:
	var root_vel := animator_manager.get_root_velocity()
	# print_.prefix("~~", "root_vel " + pp.vec3(root_vel))
	var fade_factor = fade_interpolator.update(delta)
	var extra_vel_local = Vector3(0, 0, extra_speed * fade_factor) # Animation +Z
	player.velocity = player.get_quaternion() * (root_vel + extra_vel_local)

	# print("[RUN_STOP] root_vel: %s (%.2f) | fade: %.2f | extra: %s (%.2f) | final: %s (%.2f)" % [
	# 	pp.vec3(root_vel), root_vel.length(),
	# 	fade_factor,
	# 	pp.vec3(current_extra), current_extra.length(),
	# 	pp.vec3(player.velocity), player.velocity.length()
	# ])

var _dev_add_blend = -0.2

func animate(): # ▶️
	var blend_time := default_blend_time
	var start_time_offset := 0.0
	
	match legs_sm.prev_action.action_name:
		Leg.Act.run:
			blend_time = 0.2 + _dev_add_blend
	
	__log_anim(blend_time, start_time_offset)
	animator_manager.set_anim_to_play(anim_id, blend_time, start_time_offset)


func _input(event):
	_dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
	# _next_anim_correction = u._dev_change_t34_param(event, _next_anim_correction, "_next_anim_correction", 0.02)
